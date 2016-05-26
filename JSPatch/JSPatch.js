var global = this

;(function() {

  var _ocCls = {};
  var _jsCls = {};

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

  var _customMethods = {
    __c: function(methodName) {
      var slf = this

      if (slf instanceof Boolean) {
        return function() {
          return false
        }
      }
      if (slf[methodName]) {
        return slf[methodName].bind(slf);
      }

      if (!slf.__obj && !slf.__clsName) {
        throw new Error(slf + '.' + methodName + ' is undefined')
      }
      if (slf.__isSuper && slf.__clsName) {
          slf.__clsName = _OC_superClsName(slf.__obj.__realClsName ? slf.__obj.__realClsName: slf.__clsName);
      }
      var clsName = slf.__clsName
      if (clsName && _ocCls[clsName]) {
        var methodType = slf.__obj ? 'instMethods': 'clsMethods'
        if (_ocCls[clsName][methodType][methodName]) {
          slf.__isSuper = 0;
          return _ocCls[clsName][methodType][methodName].bind(slf)
        }

        if (slf.__obj && _ocCls[clsName]['props'][methodName]) {
          if (!slf.__ocProps) {
            var props = _OC_getCustomProps(slf.__obj)
            if (!props) {
              props = {}
              _OC_setCustomProps(slf.__obj, props)
            }
            slf.__ocProps = props;
          }
          var c = methodName.charCodeAt(3);
          if (methodName.length > 3 && methodName.substr(0,3) == 'set' && c >= 65 && c <= 90) {
            return function(val) {
              var propName = methodName[3].toLowerCase() + methodName.substr(4)
              slf.__ocProps[propName] = val
            }
          } else {
            return function(){ 
              return slf.__ocProps[methodName]
            }
          }
        }
      }

      return function(){
        var args = Array.prototype.slice.call(arguments)
        return _methodFunc(slf.__obj, slf.__clsName, methodName, args, slf.__isSuper)
      }
    },

    super: function() {
      var slf = this
      if (slf.__obj) {
        slf.__obj.__realClsName = slf.__realClsName;
      }
      return {__obj: slf.__obj, __clsName: slf.__clsName, __isSuper: 1}
    },

    performSelectorInOC: function() {
      var slf = this
      var args = Array.prototype.slice.call(arguments)
      return {__isPerformInOC:1, obj:slf.__obj, clsName:slf.__clsName, sel: args[0], args: args[1], cb: args[2]}
    },

    performSelector: function() {
      var slf = this
      var args = Array.prototype.slice.call(arguments)
      return _methodFunc(slf.__obj, slf.__clsName, args[0], args.splice(1), slf.__isSuper, true)
    }
  }

  for (var method in _customMethods) {
    if (_customMethods.hasOwnProperty(method)) {
      Object.defineProperty(Object.prototype, method, {value: _customMethods[method], configurable:false, enumerable: false})
    }
  }

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

  var _formatDefineMethods = function(methods, newMethods, realClsName) {
    for (var methodName in methods) {
      if (!(methods[methodName] instanceof Function)) return;
      (function(){
        var originMethod = methods[methodName]
        newMethods[methodName] = [originMethod.length, function() {
          try {
            var args = _formatOCToJS(Array.prototype.slice.call(arguments))
            var lastSelf = global.self
            global.self = args[0]
            if (global.self) global.self.__realClsName = realClsName
            args.splice(0,1)
            var ret = originMethod.apply(originMethod, args)
            global.self = lastSelf
            return ret
          } catch(e) {
            _OC_catch(e.message, e.stack)
          }
        }]
      })()
    }
  }

  var _wrapLocalMethod = function(methodName, func, realClsName) {
    return function() {
      var lastSelf = global.self
      global.self = this
      this.__realClsName = realClsName
      var ret = func.apply(this, arguments)
      global.self = lastSelf
      return ret
    }
  }

  var _setupJSMethod = function(className, methods, isInst, realClsName) {
    for (var name in methods) {
      var key = isInst ? 'instMethods': 'clsMethods',
          func = methods[name]
      _ocCls[className][key][name] = _wrapLocalMethod(name, func, realClsName)
    }
  }

  global.defineClass = function(declaration, properties, instMethods, clsMethods) {
    var newInstMethods = {}, newClsMethods = {}
    if (!(properties instanceof Array)) {
      clsMethods = instMethods
      instMethods = properties
      properties = null
    }

    var realClsName = declaration.split(':')[0].trim()

    _formatDefineMethods(instMethods, newInstMethods, realClsName)
    _formatDefineMethods(clsMethods, newClsMethods, realClsName)

    var ret = _OC_defineClass(declaration, newInstMethods, newClsMethods)
    var className = ret['cls']
    var superCls = ret['superCls']

    _ocCls[className] = {
      instMethods: {},
      clsMethods: {},
      props: {}
    }

    if (superCls.length && _ocCls[superCls]) {
      for (var funcName in _ocCls[superCls]['instMethods']) {
        _ocCls[className]['instMethods'][funcName] = _ocCls[superCls]['instMethods'][funcName]
      }
      for (var funcName in _ocCls[superCls]['clsMethods']) {
        _ocCls[className]['clsMethods'][funcName] = _ocCls[superCls]['clsMethods'][funcName]
      }
      if (_ocCls[superCls]['props']) {
        _ocCls[className]['props'] = JSON.parse(JSON.stringify(_ocCls[superCls]['props']));
      }
    }

    _setupJSMethod(className, instMethods, 1, realClsName)
    _setupJSMethod(className, clsMethods, 0, realClsName)

    if (properties) {
      properties.forEach(function(o){
        _ocCls[className]['props'][o] = 1
        _ocCls[className]['props']['set' + o.substr(0,1).toUpperCase() + o.substr(1)] = 1
      })
    }
    return require(className)
  }

  global.defineProtocol = function(declaration, instProtos , clsProtos) {
      var ret = _OC_defineProtocol(declaration, instProtos,clsProtos);
      return ret
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

  global.defineJSClass = function(declaration, instMethods, clsMethods) {
    var o = function() {},
        a = declaration.split(':'),
        clsName = a[0].trim(),
        superClsName = a[1] ? a[1].trim() : null
    o.prototype = {
      init: function() {
        if (this.super()) this.super().init()
        return this;
      },
      super: function() {
        return superClsName ? _jsCls[superClsName].prototype : null
      }
    }
    var cls = {
      alloc: function() {
        return new o;
      }
    }
    for (var methodName in instMethods) {
      o.prototype[methodName] = instMethods[methodName];
    }
    for (var methodName in clsMethods) {
      cls[methodName] = clsMethods[methodName];
    }
    global[clsName] = cls
    _jsCls[clsName] = o
  }
  
  global.YES = 1
  global.NO = 0
  global.nsnull = _OC_null
  global._formatOCToJS = _formatOCToJS
  
})()