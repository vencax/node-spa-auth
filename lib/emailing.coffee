Handlebars = require 'handlebars'
path = require('path')
fs = require 'fs'

templateStore = process.env.EMAIL_TEMPLATE_DIR || path.dirname(path.dirname(__filename)) + '/emailTemplates/'


exports.send = (action, email, ctx, host, sendMail, cb) ->
  lang = ctx.lang or 'en'
  templateFile = templateStore + action + '.' + lang + '.hbs'

  _send = (templateFile, cb) ->
    fs.readFile templateFile, (err, template) ->
      return cb(err) if err

      sendMail
        from: process.env.EMAIL_TRANSPORTER_USER || 'team@' + host
        to: email
        subject: ctx.project + '!'
        text: Handlebars.compile(template.toString())(ctx)
      , (err, info) ->
        return cb(err) if err
        cb(null, info)

  _send templateFile, (err, info) ->
    if err
      # try english
      templateFile = templateStore + action + '.en.hbs'
      return _send(templateFile, cb)
    else
      cb null, info
