var global = this

;(function() {

  var callbacks = {}
  var callbackID = 0
  
  var _methodNameOCToJS = function(name) {
    name = name.replace(/\:/g, '_')
    if (name[name.length - 1] == '_') {
      return name.substr(0, name.length - 1)
    }
    return name
  }

  var _formatOCToJS = function(obj) {
    if (obj === undefined || obj === null) return false
    if (typeof obj == "object") {
      if (obj.__obj) return obj
      if (obj.__isNull) return false
    }
    if (obj instanceof Array) {
      var ret = []
      obj.forEach(function(o) {
        ret.push(_formatOCToJS(o))
      })
      return ret
    }
    if (obj instanceof Function) {
      return function() {
        var args = Array.prototype.slice.call(arguments)
        return obj.apply(obj, _OC_formatJSToOC(args))
      }
    }
    if (obj instanceof Object) {
      var ret = {}
      for (var key in obj) {
        ret[key] = _formatOCToJS(obj[key])
      }
      return ret
    }
    return obj
  }
  
  var _methodFunc = function(instance, clsName, methodName, args, isSuper) {
    methodName = methodName.replace(/__/g, "-")
    var selectorName = methodName.replace(/_/g, ":").replace(/-/g, "_")
    var marchArr = selectorName.match(/:/g)
    var numOfArgs = marchArr ? marchArr.length : 0
    if (args.length > numOfArgs) {
      selectorName += ":"
    }
    var ret = instance ? _OC_callI(instance, selectorName, args, isSuper):
                         _OC_callC(clsName, selectorName, args)

    return _formatOCToJS(ret)
  }

  Object.prototype.__c = function(methodName) {
    if (this instanceof Boolean) {
      return function() {
        return false
      }
    }
    
    if (!this.__obj && !this.__clsName) {
      return this[methodName].bind(this);
    }

    var self = this
    if (methodName == 'super') {
      return function() {
        return {__obj: self.__obj, __clsName: self.__clsName, __isSuper: 1}
      }
    }
    return function(){
      var args = Array.prototype.slice.call(arguments)
      return _methodFunc(self.__obj, self.__clsName, methodName, args, self.__isSuper)
    }
  }

  var _require = function(clsName) {
    if (!global[clsName]) {
      global[clsName] = {
        __isCls: 1,
        __clsName: clsName
      }
    } 
    return global[clsName]
  }

  global.require = function(clsNames) {
    var lastRequire
    clsNames.split(',').forEach(function(clsName) {
      lastRequire = _require(clsName.trim())
    })
    return lastRequire
  }

  var _formatDefineMethods = function(methods, newMethods) {
    for (var methodName in methods) {
      (function(){
       var originMethod = methods[methodName]
        newMethods[methodName] = [originMethod.length, function() {
          var args = _formatOCToJS(Array.prototype.slice.call(arguments))
          var lastSelf = global.self
          
          global.self = args[0]
          args.splice(0,1)
          var ret = originMethod.apply(originMethod, args)
          global.self = lastSelf
          
          return ret
        }]
      })()
    }
  }

  global.defineClass = function(declaration, instMethods, clsMethods) {
    var newInstMethods = {}, newClsMethods = {}
    _formatDefineMethods(instMethods, newInstMethods)
    _formatDefineMethods(clsMethods, newClsMethods)

    var ret = _OC_defineClass(declaration, newInstMethods, newClsMethods)

    return require(ret["cls"])
  }

  global.block = function(args, cb) {
    var slf = this
    if (args instanceof Function) {
      cb = args
      args = ''
    }
    var callback = function() {
      var args = Array.prototype.slice.call(arguments)
      return cb.apply(slf, _formatOCToJS(args))
    }
    return {args: args, cb: callback}
  }
  
  global.console = {
    log: global._OC_log
  }
  
  global.YES = 1
  global.NO = 0
  
  global.__defineGetter__("nsnull", function() {
    return _formatOCToJS(_OC_null)
  });
  
})()