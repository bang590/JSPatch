defineClass('JSClsA', ['prop1', 'prop2'], {
    init: function(){
        self = self.super().init();
        self.setProp1('1');
        self.setProp2('2');
        return self;
    },
    _privateMethod: function() {
        return 'P';
    },
    method: function() {
        return 'A' + self.prop1() + self.prop2();
    },
}, {
    clsMethod: function() {
        return 'A'
    },
})




defineClass('JSSuperTestA', {
    method: function(){
        return 'A'
    }
})

defineClass('JSSuperTestA1: JSSuperTestA', {
    method: function(){
        return self.super().method() + '1'
    }
})

defineClass('JSSuperTestA2: JSSuperTestA1', {
    method: function(){
        return self.super().method() + '2'
    }
})


defineJSClass('JSClassA', {
    init: function() {
        this.prop1 = 'A'
        return this
    },
    method: function() {
        return this.prop1
    }
}, {
    clsMethod: function() {
        return '1'
    }
})

defineJSClass('JSClassA1: JSClassA', {
    method: function() {
        return this.super().method() + '1'; //should be 'A1'
    }
})

defineJSClass('JSClassA2: JSClassA1', {
    method: function() {
        return this.super().method() + '2'; //should be 'A12'
    }
})


defineClass('JPJSClassTest', {}, {
    isPassA: function() {
        var o = JSClsA.alloc().init();
        return o.method() == 'A12' && o._privateMethod() == 'P' && JSClsA.clsMethod() == 'A';
    },
    isPassB: function() {
        var o = JSSuperTestA2.alloc().init();
        return o.method() == 'A12';
    },
    isPassC: function() {
        var o = JSClassA2.alloc().init();
        return o.method() == 'A12' && JSClassA.clsMethod() == '1';
    }
})

