jwt = require 'jsonwebtoken'
emailing = require './emailing'

CLIENTURL = process.env.CLIENTAPPURL || ''

module.exports = (app, usermanip, sendMail) ->

  createToken = (action, user) ->
    content =
      action: action
      email: user.email
    return jwt.sign(
      content, process.env.SERVER_SECRET,
      expiresIn: process.env.EMAIL_VALIDATION_TOKEN_DURATION || 24 * 60 * 60
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
      linkAct = (process.env.CLIENTAPPURL or '') + '/changepwd'
    else
      linkAct = serverAddr + req.baseUrl + '/userverify'
    ctx =
      fullName: user.name
      project: process.env.PROJECT_NAME or req.hostname
      link: linkAct + '?sptoken=' + token
      lang: _getClientLang(req)
    emailing.send(action, user.email, ctx, serverAddr, sendMail, cb)

  app.post '/register', (req, res) ->
    usermanip.find {email: req.body.email}, (err, user) ->
      if user
        return res.status(400).send('Already exists')
      user = usermanip.build(req.body)
      user.gid = process.env.DEFAULT_GID || 1
      user.status = 'disabled'
      usermanip.save user, (err, saved) ->
        return res.status(400).send(err) if err
        _sendEmail 'verify', user, req, (err) ->
          return res.status(400).send(err) if err
          res.status(201).send 'VERIFYCATION_PWD_MAIL_SENT'

  # User clicks on the link in verification email received (token in URL)
  app.get '/userverify', (req, res) ->
    token = req.query.sptoken
    jwt.verify token, process.env.SERVER_SECRET, (err, decoded) ->
      return res.status(404).send('TOKEN_NOT_VALID') if err

      usermanip.find {email: decoded.email}, (err, user) ->
        user.status = 'enabled' # verified
        usermanip.save user, (err, saved) ->
          return res.status(400).send(err) if err
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
      return res.status(400).send('TOKEN_NOT_VALID') if err

      usermanip.find {email: decoded.email}, (err, user) ->
        user.password = req.body.password
        usermanip.save user, (err, saved) ->
          return res.status(400).send(err) if err
          res.status(200).send 'PWD_CHANGED'

  app.post '/requestforgotten', (req, res) ->
    usermanip.find {email: req.body.email}, (err, user) ->
      return res.status(400).send(err) if err
      return res.status(404).send('USER_NOT_FOUND') if !user

      _sendEmail 'reset', user, req, (err) ->
        return res.status(400).send(err) if err
        res.send 'FORGOTTEN_PWD_MAIL_SENT'
