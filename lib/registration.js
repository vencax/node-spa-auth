var jwt = require('jsonwebtoken');
var emailing = require('./emailing');


module.exports = function(app, usermanip, sendMail) {

  function _sendEmail(action, user, req, cb) {
    var content = {action: action, email: user.email};
    var token = jwt.sign(content, process.env.SERVER_SECRET, {
      expiresInMinutes: process.env.EMAIL_VALIDATION_TOKEN_DURATION || 24 * 60
    });

    var serverAddr = req.host || process.env.SERVERURL;
    var linkAct = (action === 'reset') ?
      (process.env.CLIENTAPPURL || '') + '/changepwd' :
      serverAddr + req.baseUrl + '/userverify';

    var ctx = {
      fullName: user.fullName,
      project: process.env.PROJECT_NAME || req.hostname,
      link: linkAct + '?sptoken=' + token
    };
    try {
      ctx.lang = req.headers["accept-language"].split(';')[0].split(',')[0];
    } catch(e) {
      ctx.lang = process.env.FALLBACKLANG || 'en';
    }
    emailing.send(action, user.email, ctx, serverAddr, sendMail, cb);
  }

  app.post('/register', function(req, res) {
    usermanip.find(req.body.email, function(err, user) {
      if(user) {
        return res.status(400).send('Already exists');
      }
      user = usermanip.build(req.body);

      usermanip.save(user, function(err, saved) {
        if(err) {
          return res.status(400).send(err);
        }

        _sendEmail('verify', user, req, function(err) {
          res.status(201).send('VERIFYCATION_PWD_MAIL_SENT');
        });
      });
    });
  });

  // User clicks on the link in verification email received (token in URL)
  app.get('/userverify', function(req, res) {
    var token = req.query.sptoken;

    jwt.verify(token, process.env.SERVER_SECRET, function(err, decoded) {
      if (err) {
        return res.status(404).send('TOKEN_NOT_VALID');
      }
      usermanip.find(decoded.email, function(err, user) {
        user.state = 1;  // verified

        usermanip.save(user, function(err, saved) {
          if(err) {
            return res.status(400).send(err);
          }
          return res.redirect((process.env.CLIENTAPPURL || '') + '/login');
        });
      });
    });
  });

  // User submits change password form (token in URL)
  app.post('/setpasswd', function(req, res) {

    var token = req.query.sptoken;

    jwt.verify(token, process.env.SERVER_SECRET, function(err, decoded) {
      if (err) {
        return res.status(400).send('TOKEN_NOT_VALID');
      }

      usermanip.find(decoded.email, function(err, user) {
        user.passwd = req.body.passwd;

        usermanip.save(user, function(err, saved) {
          if(err) {
            return res.status(400).send(err);
          }
          return res.status(200).send('PWD_CHANGED');
        });
      });
    });
  });

  app.post('/requestforgotten', function(req, res) {
    usermanip.find(req.body.email, function(err, user) {
      if(err) {
        return res.status(400).send(err);
      }

      if(!user) {
        return res.status(404).send('USER_NOT_FOUND');
      }

      _sendEmail('reset', user, req, function(err) {
        if(err) {
          return res.status(400).send(err);
        }
        res.send('FORGOTTEN_PWD_MAIL_SENT');
      });
    });
  });

};
