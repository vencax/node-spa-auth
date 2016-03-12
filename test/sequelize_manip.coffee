
module.exports = (db) ->

  find: (body, done) ->
    cond = []
    if body.username
      cond.push({uname: body.username})
    if body.email
      cond.push({email: body.email})

    db.models.user.find
      where: $or: cond
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
