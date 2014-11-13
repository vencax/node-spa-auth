var GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;


module.exports = function(app, usermanip, passport, embedToken) {

  passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLECLIENTID,
    clientSecret: process.env.GOOGLECLIENTSECRET,
    callbackURL: "http://mhd.vxk.cz/auth/google/callback"
  },
  function(accessToken, refreshToken, profile, done) {
    usermanip.find(profile.email, function(err, user) {
      if (!user) {
        user = usermanip.create({email: email, name: profile.displayName});
      }
      usermanip.save(user, function(err, user) {
        return done(null, user);
      })
    });
  }));

  app.get('/google', passport.authenticate('google', {
    scope: 'https://www.googleapis.com/auth/userinfo.profile'
  }));

  app.get('/google/callback',
    passport.authenticate('google', {session: false}),
    function(req, res) {
      embedToken(req.user);
      res.cookie('mysetuser', JSON.stringify(req.user), { maxAge: 9000 });
      res.redirect('/login');
    });

};
