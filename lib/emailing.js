const Handlebars = require('handlebars')
const path = require('path')
const fs = require('fs-extra')
const templateStore = process.env.EMAIL_TEMPLATE_DIR ||
  path.join(path.dirname(__dirname), 'emailTemplates')

function _getTemplate (action, lang) {
  const templateFile = path.join(templateStore, action + '.' + lang + '.hbs')
  return fs.pathExists(templateFile)
  .then(exists => {
    if (!exists) {
      const enFile = path.join(templateStore, action + '.en.hbs')
      return fs.readFile(enFile)
    } else {
      return fs.readFile(templateFile)
    }
  })
}

exports.send = (action, email, ctx, host, sendMail) => {
  return _getTemplate(action, ctx.lang || 'en')
  .then(template => {
    return sendMail({
      from: process.env.EMAIL_TRANSPORTER_USER || 'team@' + host,
      to: email,
      subject: ctx.project + '!',
      text: Handlebars.compile(template.toString())(ctx)
    })
  })
}
