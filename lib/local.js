const Utils = require('./utils')
const _ = require('underscore')

function _getToken (user, scope = null) {
  // req.query.scope can contain comma-separated user attrnames that shall be in token
  const tokencontent = scope ? _.pick(user, scope.split(',')) : user
  return Utils.sign4login(tokencontent)
}

module.exports = (usermanip, createError) => (req, res, next) => {
  //
  return usermanip.find({
    username: req.body.username,
    email: req.body.username
  })
  .then((user) => {
    if (!user) {
      return next(createError('incorrect credentials', 401))
    }
    if (!Utils.validPassword(user, req.body.password)) {
      return next(createError('incorrect credentials', 401))
    }
    if (user.status === 'disabled') {
      return next(createError('user disabled', 401))
    }

    function _send (user) {
      user = _.omit(user, 'password')
      res.json({
        user: user,
        token: _getToken(user, req.query.scope)
      })
      next()
    }

    if (usermanip.retrieveAditionalUserinfo) {
      return usermanip.retrieveAditionalUserinfo(user).then(_send)
    } else {
      _send(user)
    }
  })
  .catch(next)
}
