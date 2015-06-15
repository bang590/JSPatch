var global = this

;(function(){
  var callbacks = {}
  var localMethods = {}
  var callbackID = 0
  
  var _methodNameOCToJS = function(name) {
    name = name.replace(/\:/g, '_')
    if (name[name.length - 1] == '_') {
      return name.substr(0, name.length - 1)
    }
    return name
  }

  var _formatOCToJS = function(obj) {
     if (obj === undefined || obj === null) return null
     if (typeof obj == "object") {
       if (obj.__obj) return obj
       if (obj.__isNull) return null
     }
     if (obj instanceof Array) {
        var ret = []
        obj.forEach(function(o){
          ret.push(_formatOCToJS(o))
        })
        return ret
     }
     if (obj instanceof Function) {
        return function() {
          var args = Array.prototype.slice.call(arguments)
          obj.apply(obj, _OC_formatJSToOC(args))
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

  var _getCustomMethod = function(clsName, methodName, isInstance) {
    var obj = localMethods[clsName]
    if (!obj) return undefined

    if (isInstance) {
      return obj.instMethods && obj.instMethods[methodName]
    } else {
      return obj.clsMethods && obj.clsMethods[methodName]
    }
  }

  Object.prototype.__c = function(methodName) {
    if (!this.__obj && !this.__clsName) return this[methodName].bind(this);
    var customMethod = _getCustomMethod(this.__clsName, methodName, !!this.__obj)
    if (customMethod) {
      return customMethod.bind(this)
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

  var _formatDefineMethod = function(methods, newMethods) {
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

  var _formatLocalMethods = function(methods) {
    for (var methodName in methods) {
      (function(){
        var originMethod = methods[methodName]
        methods[methodName] = function() {
          var args = Array.prototype.slice.call(arguments)
          var lastSelf = global.self
          global.self = this
          var ret = originMethod.apply(this, args)
          global.self = lastSelf
          return ret
        }
      })()  
    }
  }

  global.defineClass = function(declaration, instMethods, clsMethods, customMethods) {
    var newInstMethods = {}, newClsMethods = {}
    _formatDefineMethod(instMethods, newInstMethods)
    _formatDefineMethod(clsMethods, newClsMethods)

    var ret = _OC_defineClass(declaration, newInstMethods, newClsMethods)

    if (customMethods) {
      _formatLocalMethods(customMethods)
      localMethods[ret["cls"]] = {
        instMethods: customMethods
      }
    }

    return require(ret["cls"])
  }

  global._callCB = function(cbID, arg) {
    if (callbacks[cbID]) callbacks[cbID](arg)
  }
  global.block = function(args, cb){
    var id = callbackID++
    callbacks[id] = function(cacheIdx) {
      var args = _OC_getBlockArguments(cacheIdx)
      cb.apply(this, _formatOCToJS(args))
    }
    return {args: args, cbID: id}
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