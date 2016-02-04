defineClass('SuperTestB : SuperTestA', {
  testSuper: function() {
    self.ORIGtestSuper();
    self.super().testSuper();
  }
})