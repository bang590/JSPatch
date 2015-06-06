var global = this;

(function() {
  defineClass('MultithreadTestObject', {
    addValueJS: function(num) {
      self.addValue(num);
  },
    addValue: function(num) {
      self.ORIGaddValue(num);
    }
            
  });
})();