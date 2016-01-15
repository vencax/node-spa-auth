
module.exports = (db) ->

  find: (condition, done) ->
    if condition.length > 1
      condition = {$or: condition}
    else
      condition = condition[0]

    db.models.user.find
      where: condition
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

  delete: (user, done)->
    user.destroy().then ()->
      done(null, 'deleted')
    .catch (err) ->
      done(err)

  list: (done)->
    db.models.user.findAll().then (found)->
      done(null, found)
