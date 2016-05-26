include('JPDemoController.js');
defineClass('JPRootViewController', {
    showController: function() {
        var ctrl = JPDemoController.alloc().init();
        self.navigationController().pushViewController_animated(ctrl, NO);
    }
});