
var Handlebars = require('handlebars');
var fs = require('fs');


function _getTemplStorage() {
  var path = require('path');
  return path.dirname(path.dirname(__filename)) + '/emailTemplates/';
}
var templateStore = process.env.EMAIL_TEMPLATE_DIR || _getTemplStorage();


exports.send = function(action, email, ctx, sendMail, cb) {

  function _send(templateFile, cb) {
    fs.readFile(templateFile, function (err, template) {
      if (err) { return cb(err); }

      sendMail({
        from: process.env.EMAIL_TRANSPORTER_USER || 'admin@localhost',
        to: email,
        subject: ctx.project + '!',
        text: Handlebars.compile(template.toString())(ctx)
      }, function(err, info) {
        if(err) {
          cb(err);
        } else {
          cb(null, info);
        }
      });
    });
  }

  var lang = ctx.lang || 'en';
  var templateFile = templateStore + action + '.' + lang + '.hbs';

  _send(templateFile, function(err, info) {
    if (err) {
      // try english
      templateFile = templateStore + action + '.en.hbs';
      _send(templateFile, cb);
    } else {
      cb(null, info);
    }
  });
};
