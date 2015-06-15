var global = this;

(function() {
	
  defineClass('JPMultithreadTestObject', {
    addValueJS: function(num) {
      self.addValue(num);
    },
    addValue: function(num) {
      self.ORIGaddValue(num);
    }
  });

})();