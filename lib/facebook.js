
var FacebookStrategy = require('passport-facebook').Strategy;

module.exports = function(app, usermanip, passport, embedToken) {

  passport.use(new FacebookStrategy({
    clientID: process.env.FBCLIENTID,
    clientSecret: process.env.FBCLIENTSECRET,
    callbackURL: 'http://mhd.vxk.cz/auth/facebook/callback'
  }, function(accessToken, refreshToken, profile, done) {
    email = profile.username + '@facebook.com';
    usermanip.find(email, function(err, user) {
      if (!user) {
        user = usermanip.create({email: email, name: profile.displayName});
      }
      usermanip.save(user, function(err, user) {
        return done(null, user);
      })
    });
  }));

  app.get('/facebook', passport.authenticate('facebook'));

  app.get('/facebook/callback',
    passport.authenticate('facebook', {session: false}),
    function(req, res) {
      embedToken(req.user);
      res.cookie('mysetuser', JSON.stringify(req.user), { maxAge: 9000 });
      res.redirect('/login');
    });

};
