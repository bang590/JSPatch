defineClass('SuperTestB', {
  testSuper: function() {
    self.ORIGtestSuper();
    self.super().testSuper();
  }
})