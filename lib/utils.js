const crypto = require('crypto')
const jwt = require('jsonwebtoken')

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

// ----------------- register stuff ----------------------
const EMAIL_TOKEN_DURATION = parseInt(process.env.EMAIL_VALIDATION_TOKEN_DURATION) || '2 days'

const jwtOpts4register = {
  expiresIn: EMAIL_TOKEN_DURATION,
  algorithm: 'HS512'
}

exports.sign4register = (content) => {
  return jwt.sign(content, process.env.SERVER_SECRET_4_EMAILS, jwtOpts4register)
}
exports.verify4register = (token, createError) => {
  return new Promise((resolve, reject) => {
    jwt.verify(token, process.env.SERVER_SECRET_4_EMAILS, jwtOpts4register, (err, decoded) => {
      if (err) {
        reject(createError(err.message, 401))
      }
      resolve(decoded)
    })
  })
}

// ----------------- login stuff ----------------------
const tokenExpiresIn = parseInt(process.env.TOKEN_VALIDITY_IN_MINS) * 60 || 24 * 60 * 60
console.log(`token validity interval: ${tokenExpiresIn} secs`)

const jwtOpts4login = {
  expiresIn: tokenExpiresIn,
  algorithm: process.env.JWT_ALGORITHM || 'HS512'
}
exports.sign4login = (content) => {
  return jwt.sign(content, process.env.SERVER_SECRET, jwtOpts4login)
}
