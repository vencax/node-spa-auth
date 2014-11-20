
var FacebookStrategy = require('passport-facebook').Strategy;

module.exports = function(app, usermanip, passport, postAuthFunc) {

  passport.use(new FacebookStrategy({
    clientID: process.env.FBCLIENTID,
    clientSecret: process.env.FBCLIENTSECRET,
    callbackURL: process.env.AUTH_URL + '/facebook/callback'
  }, function(accessToken, refreshToken, profile, done) {
    email = profile.username + '@facebook.com';
    usermanip.find(email, function(err, user) {
      if (err) {
        return done(err);
      }
      if (!user) {
        user = usermanip.build({
          email: email, name: profile.displayName, state: 1
        });
      }
      usermanip.save(user, function(err, user) {
        return done(null, user);
      });
    });
  }));

  app.get('/facebook', passport.authenticate('facebook'));

  app.get('/facebook/callback',
    passport.authenticate('facebook', {session: false}),
    postAuthFunc
  );

};
