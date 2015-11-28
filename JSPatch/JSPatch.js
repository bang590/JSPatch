var global = this

;(function() {

  var callbacks = {}
  var callbackID = 0

  var _formatOCToJS = function(obj) {
    if (obj === undefined || obj === null) return false
    if (typeof obj == "object") {
      if (obj.__obj) return obj
      if (obj.__isNil) return false
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
            var formatedArgs = _OC_formatJSToOC(args)
            for (var i = 0; i < args.length; i++) {
                if (args[i] === null || args[i] === undefined || args[i] === false) {
                formatedArgs.splice(i, 1, undefined)
            } else if (args[i] == nsnull) {
                formatedArgs.splice(i, 1, null)
            }
        }
        return _OC_formatOCToJS(obj.apply(obj, formatedArgs))
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
  
  var _methodFunc = function(instance, clsName, methodName, args, isSuper, isPerformSelector) {
    var selectorName = methodName
    if (!isPerformSelector) {
      methodName = methodName.replace(/__/g, "-")
      selectorName = methodName.replace(/_/g, ":").replace(/-/g, "_")
      var marchArr = selectorName.match(/:/g)
      var numOfArgs = marchArr ? marchArr.length : 0
      if (args.length > numOfArgs) {
        selectorName += ":"
      }
    }
    var ret = instance ? _OC_callI(instance, selectorName, args, isSuper):
                         _OC_callC(clsName, selectorName, args)
    return _formatOCToJS(ret)
  }

  Object.defineProperty(Object.prototype, "__c", {value: function(methodName) {
    if (this instanceof Boolean) {
      return function() {
        return false
      }
    }
    
    if (!this.__obj && !this.__clsName) {
      if (!this[methodName]) {
        throw new Error(this + '.' + methodName + ' is undefined')
      }
      return this[methodName].bind(this);
    }

    var self = this
    if (methodName == 'super') {
      return function() {
        return {__obj: self.__obj, __clsName: self.__clsName, __isSuper: 1}
      }
    }

    if (methodName.indexOf('performSelector') > -1) {
      if (methodName == 'performSelector') {
        return function(){
          var args = Array.prototype.slice.call(arguments)
          return _methodFunc(self.__obj, self.__clsName, args[0], args.splice(1), self.__isSuper, true)
        }
      } else if (methodName == 'performSelectorInOC') {
        return function(){
          var args = Array.prototype.slice.call(arguments)
          return {__isPerformInOC:1, obj:self.__obj, clsName:self.__clsName, sel: args[0], args: args[1], cb: args[2]}
        }
      }
    }
    return function(){
      var args = Array.prototype.slice.call(arguments)
      return _methodFunc(self.__obj, self.__clsName, methodName, args, self.__isSuper)
    }
  }, configurable:false, enumerable: false})

  var _require = function(clsName) {
    if (!global[clsName]) {
      global[clsName] = {
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
          var ret;
          try {
            global.self = args[0]
            args.splice(0,1)
            ret = originMethod.apply(originMethod, args)
            global.self = lastSelf
          } catch(e) {
            _OC_catch(e.message, e.stack)
          }
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
    return {args: args, cb: callback, __isBlock: 1}
  }
  
  if (global.console) {
    var jsLogger = console.log;
    global.console.log = function() {
      global._OC_log.apply(global, arguments);
      if (jsLogger) {
        jsLogger.apply(global.console, arguments);
      }
    }
  } else {
    global.console = {
      log: global._OC_log
    }
  }
  
  global.YES = 1
  global.NO = 0
  global.nsnull = _OC_null
  global._formatOCToJS = _formatOCToJS
  
})()