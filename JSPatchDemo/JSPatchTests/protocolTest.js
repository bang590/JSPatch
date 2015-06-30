var global = this;

(function() {
  defineClass("JPTestProtocolObject : NSObject <JPTestProtocol, JPTestProtocol2>", {
    protocolWithDouble_dict: function(num, dict) {
      if (dict.objectForKey("name").toJS() == "JSPatch" && num - 4.2 < 0.001) {
        return num
      }
      return 0
    },
    protocolWithInt: function(num) {
      return num
    }
  }, {
    classProtocolWithString_int: function(str, num) {
      if (num == 42) return str
      return null
    }
  })
})();