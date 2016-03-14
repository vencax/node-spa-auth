
# REST server for SPA apps authentication

[![build status](https://api.travis-ci.org/vencax/node-spa-auth.svg)](https://travis-ci.org/vencax/node-spa-auth)

Tested with angular, but supposing that all other SPA frameworks have similar possibilities.
Based on [passport](http://passportjs.org/), social auths included.
Provides authentication based on [jsonwebtoken (JWT)](http://jwt.io/).
Is express pluggable.

## Install

	npm install node-spa-auth --save

## Configuration

Config is performed through few environment variables:

- EMAIL_TRANSPORTER_USER: email from who emails are sent (default: 'team@' + hostname)
- EMAIL_TEMPLATE_DIR: directory where email templates are (default: emailTemplates in this project)
- EMAIL_VALIDATION_TOKEN_DURATION: duration (in minutes) of tokens used in emails (default 2 days)
- FALLBACKLANG: code of fallback language for email template (default en)
- DEFAULT_GID: default GID of registered users (default 1)
- CHPASSWDLINK: url with chage password form (default /changepwd)
- PROJECT_NAME: name of your project or team used in email templates (default hostname)
- TOKEN_VALIDITY_IN_MINS: duration of JWT token in minutes (default 24h)
- SERVERURL: url of server (default <protocol>://<host>)
- SET_PWD_AFTER_VERIFICATION: switch if user is redirect to password setting page after sucessful verification. (default no)

Rest of env vars are probably defined due to other parts of your app.
If not, define following:

- SERVER_SECRET: random string

## Dependencies

NOTE: this lib DO NOT care how the user is stored.
Instead it recieve usermanip object for all user manipulations.
See [sequelize_manip.coffee](test/sequelize_manip.coffee) what methodes such object MUST provide.

## Routes provided

- /login : POST (username, password), performs local users login
- /check : POST (email), checks if given email is already registered (can be used on registration form)
- /register : POST (username, name, email, password), register new user
- /userverify : GET, completes user registration process (the link in email)
- /setpasswd: POST (password, sptoken query param), change password form
- /requestforgotten: POST (email), for requesting reset of pwd

If you want to give a feedback, [raise an issue](https://github.com/vencax/node-spa-auth/issues).
