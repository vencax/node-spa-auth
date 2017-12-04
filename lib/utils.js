const crypto = require('crypto')

exports.createPasswordHash = (passwd) => {
  return crypto.createHmac('sha256', passwd).digest('hex')
}

exports.validPassword = (user, passwd) => {
  return crypto.createHmac('sha256', passwd).digest('hex') === user.password
}

exports.getClientLang = (req) => {
  try {
    return req.headers['accept-language'].split('')[0].split(',')[0]
  } catch (_) {
    return process.env.FALLBACKLANG || 'en'
  }
}
