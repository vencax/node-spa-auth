var TwitterStrategy = require('passport-twitter').Strategy;


module.exports = function(app, usermanip, passport, embedToken) {

  passport.use(new TwitterStrategy({
    consumerKey: process.env.TWITTERCONSUMERKEY,
    consumerSecret: process.env.TWITTERCONSUMERSECRET,
    callbackURL: "http://mhd.vxk.cz/auth/twitter/callback"
  }, function(accessToken, refreshToken, profile, done) {
    email = profile.username + '@twitter.com';
    usermanip.find(email, function(err, user) {
      if (!user) {
        user = usermanip.create({email: email, name: profile.displayName});
      }
      usermanip.save(user, function(err, user) {
        return done(null, user);
      })
    });
  }));

  var session = require('express-session')
  app.use(session({
    secret: 'keyboard cat', saveUninitialized: true, resave: true
  }));

  app.get('/twitter', passport.authenticate('twitter'));

  app.get('/twitter/callback',
    passport.authenticate('twitter', {session: false}),
    function(req, res) {
      embedToken(req.user);
      res.cookie('mysetuser', JSON.stringify(req.user), { maxAge: 9000 });
      res.redirect('/login');
    });

};
