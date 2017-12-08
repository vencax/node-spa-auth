
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
        .then(found => found ? found.toJSON() : null)
    },

    save: (user) => {
      if (user.id === undefined) {
        return db.models.user.create(user)
      } else {
        return db.models.user.update(user, {where: {id: user.id}})
      }
    }
  }
}
