const jwt = require('jsonwebtoken')
const Emailing = require('./emailing')
const Utils = require('./utils')

const CLIENTURL = process.env.CLIENTAPPURL || ''
const EMAIL_TOKEN_DURATION = parseInt(process.env.EMAIL_VALIDATION_TOKEN_DURATION) || '2 days'

if (process.env.DEFAULT_GID === void 0) {
  throw new Error('set DEFAULT_GID!')
}
const DEFAULT_GID = parseInt(process.env.DEFAULT_GID)

module.exports = function (usermanip, sendMail, createError) {
  //
  function createToken (action, user) {
    const content = {
      action: action,
      email: user.email
    }
    return jwt.sign(content, process.env.SERVER_SECRET, {
      expiresIn: EMAIL_TOKEN_DURATION
    })
  }

  function _sendEmail (action, user, req) {
    const token = createToken(action, user)
    const serverAddr = process.env.SERVERURL || req.protocol + '://' + req.get('host')
    const linkAct = action === 'reset'
      ? CLIENTURL + '/changepwd'
      : serverAddr + req.baseUrl + '/verify'

    const ctx = {
      fullName: user.name,
      project: process.env.PROJECT_NAME || req.hostname,
      link: linkAct + '?sptoken=' + token,
      lang: Utils.getClientLang(req)
    }
    return Emailing.send(action, user.email, ctx, serverAddr, sendMail)
  }

  function _register (req, res, next) {
    return usermanip.find({
      username: req.body.username,
      email: req.body.email
    })
    .then((user) => {
      if (user) {
        throw createError(400, 'already exists')
      }
      user = Object.assign(req.body, {
        password: Utils.createPasswordHash(req.body.password),
        gid: DEFAULT_GID,
        status: 'disabled'
      })
      return usermanip.save(user)
    })
    .then((saveduser) => {
      return _sendEmail('verify', saveduser, req)
    })
    .then((send) => {
      return res.status(201).json({message: 'verification email sent'})
    })
    .catch(next)
  }

  function _userverify (req, res, next) {
    var token = req.query.sptoken
    return jwt.verify(token, process.env.SERVER_SECRET, (err, decoded) => {
      if (err) {
        return res.status(401).json({message: 'token not valid'})
      }
      return usermanip.find({email: decoded.email})
      .then((user) => {
        if (!user) {
          throw createError(404, 'user not found')
        }
        user.status = 'enabled'
        return usermanip.save(user)
      })
      .then((saveduser) => {
        let url
        if (process.env.SET_PWD_AFTER_VERIFICATION) {
          const token = createToken('reset', saveduser)
          url = `${CLIENTURL}/changepwd?sptoken=${token}`
        } else {
          url = `${CLIENTURL}/login`
        }
        return res.redirect(url)
      })
      .catch(next)
    })
  }

  function _setpasswd (req, res, next) {
    var token = req.query.sptoken
    jwt.verify(token, process.env.SERVER_SECRET, (err, decoded) => {
      if (err) {
        return next(createError(401, 'token not valid'))
      }
      return usermanip.find({email: decoded.email})
      .then((user) => {
        if (!user) {
          throw createError(404, 'user not found')
        }
        user.password = Utils.createPasswordHash(req.body.password)
        return usermanip.save(user)
      })
      .then((user) => {
        res.status(200).json({message: 'password changed'})
      })
      .catch(next)
    })
  }

  function _requestforgotten (req, res, next) {
    return usermanip.find({email: req.body.email})
    .then(user => {
      if (!user) {
        throw createError(404, 'user not found')
      }
      return _sendEmail('reset', user, req)
    })
    .then(() => {
      return res.json({message: 'mail with instructions sent'})
    })
    .catch(next)
  }

  return {
    register: _register,  // POST
    verify: _userverify,  // GET
    setpasswd: _setpasswd,  // GET
    requestforgotten: _requestforgotten // PUT
  }
}
