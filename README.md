
# REST server for SPA apps authentication

[![build status](https://api.travis-ci.org/vencax/node-spa-auth.svg)](https://travis-ci.org/vencax/node-spa-auth)

Tested with angular or react, but supposing that all other SPA frameworks have similar possibilities.
Provides authentication based on [jsonwebtoken (JWT)](http://jwt.io/).
Is express pluggable - provides express compatible handlers.
For example see: [app.js](test/app.js#L38)

## Install

	npm install node-spa-auth --save

## Configuration

Config is performed through few environment variables:

- EMAIL_TRANSPORTER_USER: email from who emails are sent (default: 'team@' + hostname)
- EMAIL_TEMPLATE_DIR: directory where email templates are (default: emailTemplates in this project)
- EMAIL_VALIDATION_TOKEN_DURATION: duration (in minutes) of tokens used in emails (default 2 days)
- FALLBACKLANG: code of fallback language for email template (default en)
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
See [sequelize_manip.js](test/sequelize_manip.js) what methodes such object MUST provide.

If you want to give a feedback, [raise an issue](https://github.com/vencax/node-spa-auth/issues).
