
exports.sequelize = function(db) {
  return {
    find: function(email, done) {
      db.User.find({where: {email: email}}).on('success', function(found) {
        return done(null, found);
      });
    },

    build: function(props) {
      return db.User.build(props);
    },

    save: function(user, done) {
      user.save().on('success', function(saved) {
        return done(null, saved);
      });
    },

    validPassword: function(user, passwd) {
      return user.passwd === passwd;
    }
  };
};


exports.dummy = function(dummyuser) {
  return {
    find: function(uname, done) {
      return done(null, dummyuser);
    },

    build: function(props) {
      return props;
    },

    save: function(user, done) {
      return done(null, user);
    },

    validPassword: function(user, passwd) {
      return true;
    }
  };
};
