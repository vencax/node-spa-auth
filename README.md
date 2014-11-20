
# REST server for SPA apps authentication

Tested with angular, but supposing that all other SPA FWks has similar possibilities.
Based on [passport](http://passportjs.org/), social auths included.
Provides authentication based on [jsonwebtoken (JWT)](http://jwt.io/).

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

## Dependencies

If used for local user database with sequelize, model with name **User** is expected present.

## Routes provided

TBD

If you want to give a feedback, [raise an issue](https://github.com/vencax/node-angular-server-side-auth/issues).
