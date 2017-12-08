const jwt = require('jsonwebtoken')
const urlencode = require('urlencode')
const Emailing = require('./emailing')
const Utils = require('./utils')

const CLIENTURL = process.env.CLIENTAPPURL || ''
const EMAIL_TOKEN_DURATION = parseInt(process.env.EMAIL_VALIDATION_TOKEN_DURATION) || '2 days'

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
      link: linkAct + '?sptoken=' + urlencode(token),
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
        throw createError('already exists')
      }
      user = Object.assign(req.body, {
        password: Utils.createPasswordHash(req.body.password),
        status: 'disabled'
      })
      return usermanip.save(user)
    })
    .then((saveduser) => {
      return _sendEmail('verify', saveduser, req)
    })
    .then((send) => {
      res.status(201).json({message: 'verification email sent'})
      next()
    })
    .catch(next)
  }

  function _userverify (req, res, next) {
    var token = urlencode.decode(req.query.sptoken)
    return jwt.verify(token, process.env.SERVER_SECRET, (err, decoded) => {
      if (err) {
        return res.status(401).json({message: 'token not valid'})
      }
      return usermanip.find({email: decoded.email})
      .then((user) => {
        if (!user) {
          throw createError('user not found', 404)
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
        res.redirect(url)
        next()
      })
      .catch(next)
    })
  }

  function _setpasswd (req, res, next) {
    var token = urlencode.decode(req.query.sptoken)
    jwt.verify(token, process.env.SERVER_SECRET, (err, decoded) => {
      if (err) {
        return next(createError('token not valid', 401))
      }
      return usermanip.find({email: decoded.email})
      .then((user) => {
        if (!user) {
          throw createError('user not found', 404)
        }
        user.password = Utils.createPasswordHash(req.body.password)
        return usermanip.save(user)
      })
      .then((user) => {
        res.status(200).json({message: 'password changed'})
        next()
      })
      .catch(next)
    })
  }

  function _requestforgotten (req, res, next) {
    return usermanip.find({email: req.body.email})
    .then(user => {
      if (!user) {
        throw createError('user not found', 404)
      }
      return _sendEmail('reset', user, req)
    })
    .then(() => {
      res.json({message: 'mail with instructions sent'})
      next()
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
