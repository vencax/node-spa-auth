
var Handlebars = require('handlebars');
var fs = require('fs');
var path = require('path');


function _getTemplStorage() {
  return path.dirname(path.dirname(__filename)) + '/emailTemplates/';
}
var templateStore = process.env.EMAIL_TEMPLATE_DIR || _getTemplStorage();


exports.send = function(action, email, ctx, host, sendMail, cb) {

  function _send(templateFile, cb) {
    fs.readFile(templateFile, function (err, template) {
      if (err) { return cb(err); }

      sendMail({
        from: process.env.EMAIL_TRANSPORTER_USER || 'team@' + host,
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
  var templateFile = path.join(templateStore, action + '.' + lang + '.hbs');

  _send(templateFile, function(err, info) {
    if (err) {
      // try english
      templateFile = templateStore + action + '.en.hbs';
      return _send(templateFile, cb);
    } else {
      cb(null, info);
    }
  });
};
