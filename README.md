
# REST server for SPA apps authentication

[![build status](https://api.travis-ci.org/vencax/node-spa-auth.svg)](https://travis-ci.org/vencax/node-spa-auth)

Tested with angular, but supposing that all other SPA frameworks have similar possibilities.
Based on [passport](http://passportjs.org/), social auths included.
Provides authentication based on [jsonwebtoken (JWT)](http://jwt.io/).
Is express pluggable.

## Install

	npm install node-spa-auth --save

## Configuration

Config is performed through few environment variables with obvious meaning:

- FBCLIENTID
- FBCLIENTSECRET
- TWITTERCONSUMERKEY
- TWITTERCONSUMERSECRET
- GOOGLECLIENTID
- GOOGLECLIENTSECRET

Presence of FBCLIENTID variable unlocks facebook authentication.
Similary for TWITTERCONSUMERKEY and GOOGLECLIENTID.

Another env var are used for registration stuff config:

- EMAIL_TRANSPORTER_USER: email from who emails are sent (default: admin@localhost)
- EMAIL_TEMPLATE_DIR: directory where email templates are (default: emailTemplates in this project)
- EMAIL_VALIDATION_TOKEN_DURATION: duration (in minutes) of tokens used in emails
- FALLBACKLANG: code of fallback language for email template
- CHPASSWDLINK: url with chage password form
- PROJECT_NAME: name of your project or team used in email templates
- TOKEN_VALIDITY_IN_MINS: duration of JWT token in minutes

Rest of env vars are probably defined due to other parts of your app.
If not, define following:

- SERVER_SECRET: random string

## CLI

Command line interface provided for user creation and modification.
Create with e.g.:
```
node manage_cli.js create \
'{"uname":"saruman","email":"saruman@mordor.io","passwd": "whisperings","gid": 0}'
```
Update with e.g.:
```
node manage_cli.js update \
'{"uname":"saruman","change":{"email":"saruman@mordor.gov","passwd": "whisper.."}}'
```

## Dependencies

NOTE: this lib DO NOT care how the user is stored.
Instead it recieve usermanip object for all user manipulations.
See [sequelize_manip.coffee](test/sequelize_manip.coffee) what methodes such object MUST provide.

## Routes provided

- /login : POST (username, password), performs local users login
- /logout : GET, performs logout
- /check : POST (email), checks if given email is already registered (can be used on registration form)
- /register : POST (name, email, password), register new user
- /userverify : GET, completes user registration process (the link in email)
- /setpasswd: POST (passwd), change password form
- /requestforgotten: POST (email), form for requesting reset of pwd

If you want to give a feedback, [raise an issue](https://github.com/vencax/node-spa-auth/issues).
