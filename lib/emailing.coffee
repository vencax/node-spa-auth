Handlebars = require 'handlebars'
path = require('path')
fs = require 'fs'

templateStore = process.env.EMAIL_TEMPLATE_DIR ||
                  path.join(path.dirname(__dirname), 'emailTemplates')


exports.send = (action, email, ctx, host, sendMail, cb) ->
  lang = ctx.lang or 'en'
  templateFile = path.join(templateStore, action + '.' + lang + '.hbs')

  _send = (templateFile, cb) ->
    fs.readFile templateFile, (err, template) ->
      return cb(err) if err

      sendMail
        from: process.env.EMAIL_TRANSPORTER_USER || 'team@' + host
        to: email
        subject: ctx.project + '!'
        text: Handlebars.compile(template.toString())(ctx)
      , cb

  _send templateFile, (err, info) ->
    if err
      # try english
      templateFile = path.join(templateStore, action + '.en.hbs')
      return _send(templateFile, cb)
    else
      cb null, info
