defineClass("newBlockTest", {
testJSBlockToOCCall: function() {
    self.performBlock(block("CGFloat, int, CGPoint, double, CGFloat, NSNumber*, NSString*, NSInteger", function(arg1, arg2, arg3, arg4, arg5, arg6, arg7) {
        return arg1 + arg2.x + arg2.y + arg3 + arg4 + arg5 + arg6.doubleValue() + arg7;
    }));
}
}, {});
