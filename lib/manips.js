
exports.sequelize = function(db) {
  return {
    find: function(email, done) {
      db.User.find({where: {email: email}}).then(function(found) {
        return done(null, found);
      });
    },

    build: function(props) {
      return db.User.build(props);
    },

    save: function(user, done) {
      user.save().then(function(saved) {
        return done(null, saved);
      });
    },

    validPassword: function(user, passwd) {
      return user.passwd === passwd;
    }
  };
};


exports.dummy = function(dummydb) {

  var db = dummydb;

  return {
    find: function(email, done) {
      return done(null, db[email] || null);
    },

    build: function(props) {
      return props;
    },

    save: function(user, done) {
      db[user.email] = user;
      return done(null, user);
    },

    validPassword: function(user, passwd) {
      return db[user.email].password === passwd;
    }
  };
};
