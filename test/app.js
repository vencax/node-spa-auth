
const bodyParser = require('body-parser')
const express = require('express')
const Sequelize = require('sequelize')

const DB_URL = process.env.DATABASE_URL || 'sqlite:'
const sequelize = new Sequelize(DB_URL, {dialect: 'sqlite'})

// User model
const User = sequelize.define('user', {
  username: {
    type: Sequelize.STRING,
    allowNull: false,
    unique: true
  },
  name: Sequelize.STRING,
  email: Sequelize.STRING,
  password: Sequelize.STRING,
  gid: {
    type: Sequelize.INTEGER,
    allowNull: false
  },
  status: {
    type: Sequelize.ENUM('enabled', 'disabled'),
    defaultValue: 'enabled'
  }
}, {
  tableName: 'users'
})
sequelize.models = {
  user: User
}

module.exports = (g) => sequelize.sync({logging: console.log})
.then(() => {
  const manip = g.manip = require('./sequelize_manip')(sequelize)

  // now actually construct the API
  const authMod = require('../index')
  const auth = authMod(manip, g.sendMail, g.createError)

  const app = express()
  app.post('/login', bodyParser.json(), auth.login)

  const registration = express()
  registration.use(bodyParser.json())
  registration.post('/', auth.registration.register)
  registration.get('/verify', auth.registration.verify)
  registration.put('/setpasswd', auth.registration.setpasswd)
  registration.put('/forgotten', auth.registration.requestforgotten)
  app.use('/register', registration)

  function _generalErrorHandler (err, req, res, next) {
    res.status(err.status || 400).send(err.message || err)
    console.log('---------------------------------------------------------')
    console.log(err)
    console.log('---------------------------------------------------------')
  }
  app.use(_generalErrorHandler)

  return app
})
