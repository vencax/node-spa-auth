
module.exports = (db) => {
  return {

    find: (body) => {
      const cond = []
      if (body.username) {
        cond.push({username: body.username})
      }
      if (body.email) {
        cond.push({email: body.email})
      }
      return db.models.user.find({where: {$or: cond}})
    },

    save: (user) => {
      if (user.sequelize === undefined) {
        user = db.models.user.build(user)
      }
      return user.save()
    }
  }
}
