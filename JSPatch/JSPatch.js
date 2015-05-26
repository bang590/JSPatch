var global = this

;(function(){
  var clsList = {}
  var callbacks = {}
  var localMethods = {}
  var callbackID = 0
  var JSClass

  var _getJSClass = function(className) {
    if (!JSClass) {
      JSClass = function(obj, className, isSuper) {
          this.__obj = obj
          this.__isSuper = isSuper
          this.__clsName = className
      }
      JSClass.prototype.__defineGetter__('super', function(){
        if (!this.__super) {
          this.__super = new JSClass(this.__obj, this.__clsName, 1)
        }
        return this.__super
      })
    }
    return JSClass
  }

  var _toJSObj = function(meta) {
    var JSClass = _getJSClass()
    return new JSClass(meta["obj"], meta["cls"])
  }
  
  var _methodNameOCToJS = function(name) {
    name = name.replace(/\:/g, '_')
    if (name[name.length - 1] == '_') {
      return name.substr(0, name.length - 1)
    }
    return name
  }

  var _formatOCToJS = function(obj) {
     if (obj === undefined || obj === null) return null
     if (typeof obj == "object" && obj.__isObj) {
       return _toJSObj(obj)
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
          obj.apply(obj, _formatJSToOC(args))
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

  var _formatJSToOC = function(obj) {
     if (obj instanceof Object && obj.__obj) {
       return obj.__obj
     }
     if (obj instanceof Array) {
        var ret = []
        obj.forEach(function(o){
          ret.push(_formatJSToOC(o))
        })
        return ret
     }
     if (obj instanceof Object) {
        var ret = {}
        for (var key in obj) {
          if (obj.hasOwnProperty(key)) {
            ret[key] = _formatJSToOC(obj[key])
          }
        }
        return ret
     }
     return obj
  }
  
  var _methodFunc = function(instance, clsName, methodName, args, isSuper) {
    var args = _formatJSToOC(args)
    var selectorName = methodName.replace(/_/g, ":")
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
    return function(){
      var args = Array.prototype.slice.call(arguments)
      return _methodFunc(self.__obj, self.__clsName, methodName, args, self.__isSuper)
    }
  }

  var _require = function(clsName) {
     global.__defineGetter__(clsName, function(){
       return _require(clsName)
     })
    if (!clsList[clsName]) {
      clsList[clsName] = {
        __isCls: 1,
        __clsName: clsName
      }
    } 
    return clsList[clsName]
  }

  global.require = function(clsNames) {
    var lastRequire
    clsNames.split(',').forEach(function(clsName) {
      lastRequire = _require(clsName.trim())
    })
    return lastRequire
  }

  var _formatDefineMethod = function(methods, newMethods, isInst) {
    for (var methodName in methods) {
      (function(){
        var originMethod = methods[methodName]
        newMethods[methodName] = function() {
          var args = _formatOCToJS(Array.prototype.slice.call(arguments))
          if (isInst) {
            global.self = args[0]
            args.splice(0,1)
          }
          var ret = _formatJSToOC(originMethod.apply(originMethod, args))
          if (isInst) {
            global.self = null
          }
          return ret
        }
      })()
    }
  }

  var _formatLocalMethods = function(methods, ocMethods, isInst) {
    ocMethods.forEach(function(methodName){
      delete methods[methodName]
    })
    for (var methodName in methods) {
      (function(){
        var originMethod = methods[methodName]
        methods[methodName] = function() {
          var args = Array.prototype.slice.call(arguments)
          if (isInst) global.self = this
          var ret = originMethod.apply(this, args)
          if (isInst) global.self = null
          return ret
        }
      })()  
    }
  }

  global.defineClass = function(declaration, instMethods, clsMethods) {
    var newInstMethods = {}, newClsMethods = {}
    _formatDefineMethod(instMethods, newInstMethods, 1)
    _formatDefineMethod(clsMethods, newClsMethods, 0)

    var ret = _OC_defineClass(declaration, newInstMethods, newClsMethods)

    _formatLocalMethods(instMethods, ret["instMethods"], 1)
    _formatLocalMethods(clsMethods, ret["clsMethods"], 1)

    localMethods[ret["cls"]] = {
      instMethods: instMethods,
      clsMethods: clsMethods
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
  
})()