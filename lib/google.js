var GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;


module.exports = function(app, usermanip, passport, postAuthFunc) {

  passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLECLIENTID,
    clientSecret: process.env.GOOGLECLIENTSECRET,
    callbackURL: process.env.AUTH_URL + "/google/callback"
  },
  function(accessToken, refreshToken, profile, done) {
    if(!profile.emails || profile.emails.length === 0) {
      // in case we didnot recevied email ...
      email = 'unknown@gmail.com';
    } else {
      email = profile.emails[0].value;
    }
    usermanip.find(email, function(err, user) {
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

  app.get('/google', passport.authenticate('google', {
    scope: [
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email'
    ]
  }));

  app.get('/google/callback',
    passport.authenticate('google', {session: false}),
    postAuthFunc
  );

};
