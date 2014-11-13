LocalStrategy = require('passport-local').Strategy;


module.exports = function(app, usermanip, passport, embedToken, bodyParser) {

  var _verifyUser = function(username, password, done) {
    usermanip.find(username, function(err, user) {
      if (err) {
        return done(err);
      }
      if (!user) {
        return done(null, false, { message: 'Incorrect username.' });
      }
      if (!usermanip.validPassword(user, password)) {
        return done(null, false, { message: 'Incorrect password.' });
      }
      return done(null, user);
    });
  };

  passport.use(new LocalStrategy(_verifyUser));

  app.use(bodyParser.json());
  app.post('/login',
    passport.authenticate('local', {session: false}),
    function(req, res) {
      embedToken(req.user);
      res.send(req.user);
    });

  // ---------------------------------------------------------------------------

  app.post('/check', function(req, res) {
    usermanip.find(req.body.email, function(err, user) {
      if(user) {
        return res.send([0]);
      } else {
        return res.send([]);
      }
    });
  });

  app.post('/register', function(req, res) {
    usermanip.find(req.body.email, function(err, user) {
      if(user) {
        return res.status(400).send('Already exists');
      }
      user = usermanip.build(req.body);

      usermanip.save(user, function(err, saved) {
        if(err) {
          return res.status(400).send(err);
        }
        return res.status(201).send(saved);
      });
    });
  });


};
