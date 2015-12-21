defineProtocol('JPTestObjectProtocol',{
  testProtocol:{
    paramsType:"BOOL",
    returnType:"int",
  },
  testProtocol_withB:{
    paramsType:"id,CGSize",
    returnType:"NSInteger",
  },
  //you can use your classname or id  both is OK
  testProtocol_withB_withC:{
    paramsType:"CGRect,float,NSArray",
    returnType:"id",
  },
  //block SEL ok
  testProtocol_withBlock_withSEL:{
    paramsType:"CGFloat,block,SEL",
    returnType:"void",
  },
  //some unsupport type  you can use typeEncode
  //make sure paramsType's number is right
  testProtocolConstumStruct:{
    paramsType:"unknown",
    returnType:"int",
    typeEncode:"i32@0:8{CGVector=dd}16",//or "i@:{CGVector=dd}"
  },
},{
  testClassMethod: {
    paramsType:"BOOL",
    returnType:"void",
  },
});

//with new protocol  you can add no-id args method
defineClass('JPTestObject : NSObject <JPTestObjectProtocol>', {
  testProtocolConstumStruct:function(oye){
    return 6;
  },
  testProtocol: function(oye) {
    return 1;
  },
  testProtocol_withB:function(str,size){
    return 3;
  },
  testProtocol_withB_withC:function(rect,f,arr){
    return "4";
  },
  testProtocol_withBlock_withSEL:function(f,b,s){
    console.log("5")
  },
},{
  testClassMethod: function(oye) {
    console.log("7")
  },    
});



