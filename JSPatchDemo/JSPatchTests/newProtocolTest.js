defineProtocol("baseTestProtocol",{
//argument type can be bool  BOOL int NSInterger float CGFloat ... any base type
       
//one argument BOOL  return int
  testProtocol:{
    paramsType:"BOOL",
    returnType:"int",
  },
       
  //one argument NSInterger  return void
    test2Protocol:{
    paramsType:"BOOL",
  //returnType:"void",//option no returnType mean void
  },
       
  //multiArguments seperated by ","
  test3Protocol_withB_withC:{
    paramsType:"BOOL , float , CGFloat",
    //returnType:"void",//option no returnType mean void
  },
})

//with new protocol  you can add basetype args method
defineClass('baseTestProtocolObject : NSObject <baseTestProtocol>' , {
  testProtocol:function(arg1){
    console.log(arg1);
    return 1;
  },
  test2Protocol: function(arg1) {
    console.log(arg1);
  },
  test3Protocol_withB_withC:function(arg1,arg2,arg3){
    console.log(arg1);
  },
})



defineProtocol("structTestProtocol",{
//argument type can be CGRect  CGSize CGPoint ... many systemstruct
//only support system struct
//custom struct see  encodeTypeTest
       
  //one argument CGRect  return int
  testProtocol:{
    paramsType:"CGRect",
    returnType:"int",
  },

  //one argument CGSize  return CGPoint
  test2Protocol:{
    paramsType:"CGSize",
    returnType:"CGPoint",
  },

  //multiArguments seperated by ","  struct & baseType mix
  test3Protocol_withB_withC:{
    paramsType:"CGRect , float , NSInteger",
    returnType:"CGSize",
  },
})

//with new protocol  you can add struct type args method
defineClass('structTestProtocolObject : NSObject <structTestProtocol>' , {
  testProtocol:function(arg1){
    console.log(arg1);
    return 1;
  },
  test2Protocol: function(arg1) {
    console.log(arg1);
    var point = {x:100,y:100};
    return point;
  },
  test3Protocol_withB_withC:function(arg1,arg2,arg3){
    console.log(arg1);
    var size = {width:100,height:100};
    return size;
  },
})


defineProtocol("objectTestProtocol",{
//argument type can be any NSObject
     
  //one argument NSString ,  return int
  //you can turn NSString to id
  testProtocol:{
    paramsType:"id",
    returnType:"int",
  },

  //you can use NSString is All ok
  test2Protocol:{
    paramsType:"NSString",
    returnType:"int",
  },

  //multiArguments seperated by ","  object & baseType mix
  test3Protocol_withB_withC:{
    paramsType:"id , NSString , NSInteger",
    returnType:"CGSize",
  },

})

//with new protocol  you can add mix type args method
defineClass('objectTestProtocolObject : NSObject <objectTestProtocol>' , {
  testProtocol:function(arg1){
    console.log(arg1);
    return 1;
  },
  test2Protocol: function(arg1) {
    console.log(arg1);
    return 1;
  },
  test3Protocol_withB_withC:function(arg1,arg2,arg3){
    console.log(arg1);
    var size = {width:100,height:100};
    return size;
    },
})



defineProtocol("specialTestProtocol",{
//argument type can be selector and block
  //one argument Selctor  must use "SEL"
  testProtocol:{
    paramsType:"SEL",
    //returnType:"int",//option no returnType mean void
  },

  //one argument bloc  must use "block"
  test2Protocol:{
    paramsType:"block",
    // returnType:"CGPoint",//option no returnType mean void
  },

  //multiArguments seperated by ","  struct & baseType mix
  test3Protocol_withB_withC:{
    paramsType:"CGFloat , block , SEL",
    // returnType:"CGSize",//option no returnType mean void
  },
})

//with new protocol  you can add mix type args method
defineClass('specialTestProtocolObject : NSObject <specialTestProtocol>' , {
  testProtocol:function(arg1){
    console.log(arg1);
  },
  test2Protocol: function(arg1) {
    console.log(arg1);
    arg1();
  },
  test3Protocol_withB_withC:function(arg1,arg2,arg3){
    console.log(arg1);
    arg2();
  },
})


defineProtocol("encodeTestProtocol",{
//use typeEncode to define complex method

  //you can write typeEncode by using runtime
  //you can input any string
  //makesure the number of args  is right
  testProtocol:{
    paramsType:"unknown",
    returnType:"something",
    typeEncode:"v12@0:4@8",
  },

  //you can write typeEncode by yourself
  //you can input any string
  //makesure the number of args  is right
  testProtocol_withB:{
    paramsType:"idontknown , mygod",
    returnType:"wooo",
    typeEncode:"@@:@@",
  },

//if your paramsType or returnType is complex
//youcan input any string just make sure number is right
//write the whole typeEncode  or  use runtime to generate typeEncode
})

//with new protocol  you can add encodetype method
defineClass('typeEncodeTestProtocolObject : NSObject <encodeTestProtocol>' , {
  testProtocol:function(arg1){
    console.log(arg1);
  },
  test2Protocol_withB: function(arg1,arg2) {
    console.log(arg1);
    var ret = "string";
    return ret;
  },
})


defineProtocol("classTestProtocol",{},{
//argument type can be any NSObject

  //one argument NSString ,  return int
  //you can turn NSString to id
  testProtocol:{
    paramsType:"id",
    returnType:"int",
  },

  //you can use NSString is All ok
  test2Protocol:{
    paramsType:"NSString",
    returnType:"int",
  },

  //multiArguments seperated by ","  object & baseType mix
  test3Protocol_withB_withC:{
    paramsType:"id , NSString , NSInteger",
    returnType:"CGSize",
  },
})

//with new protocol  you can add class method
defineClass('classTestProtocolObject : NSObject <classTestProtocol>' ,{}, {
  testProtocol:function(arg1){
    console.log(arg1);
    return 1;
  },
  test2Protocol: function(arg1) {
    console.log(arg1);
    return 1;
  },
  test3Protocol_withB_withC:function(arg1,arg2,arg3){
    console.log(arg1);
    var size = {width:100,height:100};
    return size;
  },
})

