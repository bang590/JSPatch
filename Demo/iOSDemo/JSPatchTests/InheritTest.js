var global = this;

(function() {
  defineClass("JPInheritTest01ObjectB", {
    m1: function() {
      return "JP_01ObjB_m1";
    }
  });
 

  defineClass("JPInheritTest02ObjectB", {
    m1: function() {
      return "JP_02ObjB_m1";
    }
  });
  defineClass("JPInheritTest02ObjectC", {
    m2: function() {
      return "JP_02ObjC_m2";
    }
  });
 })();

(function(){
  defineClass("JPInheritTest02ObjectB", {
    m1:function(){
      return "JP_02ObjB_m1";
    },
    m3:function(){
      return "JP_02ObjC_m3";
    }
  },
  {});
  defineClass("JPInheritTest02ObjectC", {
    m2:function(){
      return "JP_02ObjC_m2";
    },
    m3:function(){
      return self.super().m3();
    }
  },
  {});
 })();

(function(){
  defineClass("JPInheritTest03ObjectB", {
    m1:function(){
      return "JP_03ObjB_m1";
    }
  },
  {});
  defineClass("JPInheritTest03ObjectC", {
    m2:function(){
      return "JP_03ObjC_m2";
    }
  },
  {});
 })();