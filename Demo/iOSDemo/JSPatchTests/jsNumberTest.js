require('JPEngine').addExtensions(['JPNumber'])

defineClass('JPNumberTest', {}, {
    testJPNumNSNumber: function() {
        var oc_n = OCNumber("NSNumber", "numberWithInt:", [233])
        
        return oc_n.compare(233) == 0
    },
    testJPNumNSDecimalNumber: function() {
        var oc_n = OCNumber("NSDecimalNumber", "decimalNumberWithMantissa:exponent:isNegative:", [10, 2, 0])
        return oc_n.compare(1000) == 0
    },
    testJPNumToJS: function() {
        var oc_n = OCNumber("NSNumber", "numberWithFloat:", [0.14])
        var js_n = toJSNumber(oc_n)
        return js_n + 3 - 3.14 < 0.0001
    },
    testJPNUmToOC: function() {
        var oc_n = toOCNumber(2.14)
        return oc_n.compare(2.14) == 0
    }
})