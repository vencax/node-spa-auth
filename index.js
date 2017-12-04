
module.exports = (usermanip, sendMail, createError) => {
  const Registartion = require('./lib/registration')
  const Local = require('./lib/local')
  return {
    registration: Registartion(usermanip, sendMail, createError),
    login: Local(usermanip, createError)
  }
}
