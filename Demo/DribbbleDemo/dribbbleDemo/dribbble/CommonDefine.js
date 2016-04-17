global.SCREEN_WIDTH = require('UIScreen').mainScreen().bounds().width;
global.SCREEN_HEIGHT = require('UIScreen').mainScreen().bounds().height;

global.UIHelper = {
  bottomY: function(view) {
    var f = view.frame();
    return f.height + f.y;
  },
  rightX: function(view) {
    var f = view.frame();
    return f.width + f.x;
  },
  setWidth: function(view, width) {
    var f = view.frame();
    f.width = width
    view.setFrame(f)	
  },
  setHeight: function(view, height) {
    var f = view.frame();
    f.height = height
    view.setFrame(f)	
  },
  setX: function(view, x) {
    var f = view.frame();
    f.x = x
    view.setFrame(f)	
  },
  setY: function(view, y) {
    var f = view.frame();
    f.y = y
    view.setFrame(f)	
  }
}