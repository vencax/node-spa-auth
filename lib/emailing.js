
var Handlebars = require('handlebars');
var fs = require('fs');


function _getTemplStorage() {
  var path = require('path');
  return path.dirname(path.dirname(__filename)) + '/emailTemplates/';
}
var templateStore = process.env.EMAIL_TEMPLATE_DIR || _getTemplStorage();


exports.send = function(action, email, ctx, sendMail, cb) {
  var lang = ctx.lang || 'en';
  var templateFile = templateStore + action + '.' + lang + '.hbs';
  fs.readFile(templateFile, function (err, template) {
    if (err) {
      cb(err);
    }

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
};
