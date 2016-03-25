jwt = require 'jsonwebtoken'
emailing = require './emailing'

CLIENTURL = process.env.CLIENTAPPURL || ''
EMAIL_TOKEN_DURATION = parseInt(process.env.EMAIL_VALIDATION_TOKEN_DURATION) || "2 days"
throw new Error("set DEFAULT_GID!") if process.env.DEFAULT_GID == undefined
DEFAULT_GID = parseInt(process.env.DEFAULT_GID)


module.exports = (app, usermanip, sendMail) ->

  createToken = (action, user) ->
    content =
      action: action
      email: user.email
    return jwt.sign(
      content, process.env.SERVER_SECRET,
      expiresIn: EMAIL_TOKEN_DURATION
    )

  _getClientLang = (req)->
    try
      return req.headers['accept-language'].split(';')[0].split(',')[0]
    catch e
      return process.env.FALLBACKLANG || 'en'

  _sendEmail = (action, user, req, cb) ->
    token = createToken(action, user)
    serverAddr = process.env.SERVERURL or req.protocol + '://' + req.get('host')
    if action == 'reset'
      linkAct = CLIENTURL + '/changepwd'
    else
      linkAct = serverAddr + req.baseUrl + '/userverify'
    ctx =
      fullName: user.name
      project: process.env.PROJECT_NAME or req.hostname
      link: linkAct + '?sptoken=' + token
      lang: _getClientLang(req)
    emailing.send(action, user.email, ctx, serverAddr, sendMail, cb)

  app.post '/register', (req, res) ->
    usermanip.find
      username: req.body.username
      email: req.body.email
    , (err, user) ->
      if user
        return res.status(400).json(message: 'already exists')
      user = usermanip.build(req.body)
      user.gid = DEFAULT_GID
      user.status = 'disabled'
      usermanip.save user, (err, saved) ->
        return res.status(400).json(message: err) if err
        _sendEmail 'verify', user, req, (err) ->
          return res.status(400).json(message: err) if err
          res.status(201).json(message: 'verification email sent')

  # User clicks on the link in verification email received (token in URL)
  app.get '/userverify', (req, res) ->
    token = req.query.sptoken
    jwt.verify token, process.env.SERVER_SECRET, (err, decoded) ->
      return res.status(401).json(message: 'token not valid') if err

      usermanip.find {email: decoded.email}, (err, user) ->
        user.status = 'enabled' # verified
        usermanip.save user, (err, saved) ->
          return res.status(400).json(message: err) if err
          if process.env.SET_PWD_AFTER_VERIFICATION
            token = createToken('reset', user)
            url = "#{CLIENTURL}/changepwd?sptoken=#{token}"
          else
            url = "#{CLIENTURL}/login"
          return res.redirect(url)

  # User submits change password form (token in URL)
  app.post '/setpasswd', (req, res) ->
    token = req.query.sptoken
    jwt.verify token, process.env.SERVER_SECRET, (err, decoded) ->
      return res.status(401).json(message: 'token not valid') if err

      usermanip.find {email: decoded.email}, (err, user) ->
        user.password = usermanip.createPasswordHash(req.body.password)
        usermanip.save user, (err, saved) ->
          return res.status(400).json(message: err) if err
          res.status(200).json(message: 'password changed')

  app.post '/requestforgotten', (req, res) ->
    usermanip.find {email: req.body.email}, (err, user) ->
      return res.status(400).json(message: err) if err
      return res.status(404).json(message: 'user not found') if !user

      _sendEmail 'reset', user, req, (err) ->
        return res.status(400).json(message: err) if err
        res.json(message: 'mail with instructions sent')
