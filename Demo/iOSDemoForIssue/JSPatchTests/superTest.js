defineClass('JPJSSuperTestA1 : JPSuperTestA', {
    method: function() {
        var str = self.super().method().toJS();
        return str + '1';
    }
})


defineClass('JPJSSuperTestA2 : JPJSSuperTestA1', {
    method: function() {
        var str = self.super().method();
        return str + '2';
    }
})




defineClass('JPJSSuperTestB2 : JPSuperTestB1', {
    method: function() {
        var str = self.super().method().toJS();
        return str + '2';
    }
})


defineClass('JPJSSuperTestB3 : JPJSSuperTestB2', {
    method: function() {
        var str = self.super().method();
        return str + '3';
    }
})

defineClass('JPSuperTestC1', {
    method: function() {
        var ret = self.ORIGmethod().toJS();  //should be C1
        console.log("ttttt: " + ret + self.super().method().toJS())
        return ret + self.super().method().toJS(); //should be C1C
    }
})




defineClass('JPSuperTestResult', {}, {
    isPassA: function() {
        var o = JPJSSuperTestA2.alloc().init();
        return o.method() == 'A12';
    },
    isPassB: function (){
        var o2 = JPJSSuperTestB2.alloc().init();
        var o3 = JPJSSuperTestB3.alloc().init();
        return o2.method() == 'B12' && o3.method() == 'B123';
    }
})

