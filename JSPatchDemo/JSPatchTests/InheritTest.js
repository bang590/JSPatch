var global = this;

(function(){
  defineClass("InheritTest01ObjectB", {
    m1:function(){
      return "JP_01ObjB_m1";
    }
  },
  {});
  }
)();


(function(){
  defineClass("InheritTest02ObjectB", {
    m1:function(){
      return "JP_02ObjB_m1";
    },
    m3:function(){
      return "JP_02ObjC_m3";
    }
  },
  {});
  defineClass("InheritTest02ObjectC", {
    m2:function(){
      return "JP_02ObjC_m2";
    },
    m3:function(){
      return self.super.m3();
    }
  },
  {});
 }
 )();

(function(){
  defineClass("InheritTest03ObjectB", {
     m1:function(){
       return "JP_03ObjB_m1";
     }
  },
  {});
  defineClass("InheritTest03ObjectC", {
     m2:function(){
       return "JP_03ObjC_m2";
     }
  },
  {});
 }
 )();