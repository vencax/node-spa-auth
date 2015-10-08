
# REST server for SPA apps authentication

[![build status](https://api.travis-ci.org/vencax/node-angular-server-side-auth.svg)](https://travis-ci.org/vencax/node-angular-server-side-auth)

Tested with angular, but supposing that all other SPA frameworks have similar possibilities.
Based on [passport](http://passportjs.org/), social auths included.
Provides authentication based on [jsonwebtoken (JWT)](http://jwt.io/).
Is express pluggable.

## Install

	npm install node-angular-server-side-auth --save

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

Rest of env vars are probably defined due to other parts of your app.
If not, define following:

- SERVER_SECRET: random string


## Dependencies

If used for local user database with sequelize, model with name **User** is expected present.

## Routes provided

- /login : POST (username, password), performs local users login
- /logout : GET, performs logout
- /check : POST (email), checks if given email is already registered (can be used on registration form)
- /register : POST (name, email, password), register new user
- /userverify : GET, completes user registration process (the link in email)
- /setpasswd: POST (passwd), change password form
- /requestforgotten: POST (email), form for requesting reset of pwd

If you want to give a feedback, [raise an issue](https://github.com/vencax/node-angular-server-side-auth/issues).
