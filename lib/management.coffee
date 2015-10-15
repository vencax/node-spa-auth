

module.exports = (usermanip) ->

  _create = (user, cb)->
    u = usermanip.build(user)
    usermanip.save(u, cb)

  _update = (id, attrs, cb)->
    usermanip.find [{id: id}], (err, user)->
      return cb(null, user) if not user
      for k, v of attrs
        user[k] = v
      usermanip.save user, cb

  _get = (id, cb)->
    usermanip.find [{id: id}], cb

  _list = (cb)->
    usermanip.list(cb)

  _delete = (id, cb)->
    usermanip.find [{id: id}], (err, user)->
      return cb(null, user) if not user
      usermanip.delete(user, cb)

  _initApp = (app)->

    app.get '/', (req, res) ->
      _list (err, results)->
        return res.status(400).send(err) if err
        res.json(results)

    app.get '/:id', (req, res) ->
      _get req.params.id, (err, user)->
        return res.status(400).send(err) if err
        return res.status(404).send(err) if not user
        delete user.passwd
        res.json(user)

    app.post '/', (req, res) ->
      _create req.body, (err, user)->
        return res.status(400).send(err) if err
        res.status(201).json(user.id)

    app.put '/:id', (req, res) ->
      _update req.params.id, req.body, (err, user)->
        return res.status(400).send(err) if err
        return res.status(404).send(err) if not user
        res.json(user)

    app.delete '/:id', (req, res) ->
      _delete req.params.id, (err, user)->
        return res.status(400).send(err) if err
        return res.status(404).send(err) if not user
        res.status(200).send('deleted')

  create: _create
  update: _update
  delete: _delete
  initApp: _initApp
