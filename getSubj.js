var casper = require('casper').create();

var x = require("casper").selectXPath;
//var sel_none_from = '//isteven-multi-select[@input-model="fromRegion"]//button[@ng-bind-html="lang.selectNone"][1]';

casper.start('https://www.learnfactsquick.com').viewport(1400,1000);
//casper.page.injectJs('C:/workspace/slimerjs/jquery.min.js');

//console.log("IM HERE??");

casper.then(function() {
  this.echo(this.getTitle());
  console.log("title: " + this.getTitle());
  this.on('error', function(msg, backtrace) {
      console.error('CasperJS error:', msg);
      this.capture('error_screenshot.png');
  });
});