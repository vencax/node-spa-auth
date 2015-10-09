
exports.sequelize = (db) ->

  find: (uname, done) ->
    db.models.user.find
      where: uname: uname
    .then (found) ->
      return done(null, found)
    .catch (err) ->
      done(err)
  build: (props) ->
    db.models.user.build props
  save: (user, done) ->
    user.save().then (saved) ->
      return done(null, user)
    .catch (err) ->
      done(err)
  validPassword: (user, passwd) ->
    user.passwd == passwd
