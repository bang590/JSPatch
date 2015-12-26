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
//       returnType:"void",//option no returnType mean void
       },
               
//multiArguments seperated by ","
       test3Protocol_withB_withC:{
       paramsType:"BOOL , float , CGFloat",
       //       returnType:"void",//option no returnType mean void
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
       paramsType:"CGRect , float , NSInterger",
       returnType:"CGSize",
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
        paramsType:"id , NSString , NSInterger",
        returnType:"CGSize",
        },

})



defineProtocol("specialTestProtocol",{
//argument type can be selector and block
               
    //one argument Selctor  must use "SEL"
    testProtocol:{
    paramsType:"SEL",
//    returnType:"int",//option no returnType mean void
    },

    //one argument bloc  must use "block"
    test2Protocol:{
    paramsType:"block",
//    returnType:"CGPoint",//option no returnType mean void
    },

    //multiArguments seperated by ","  struct & baseType mix
    test3Protocol_withB_withC:{
    paramsType:"CGFloat , block , SEL",
//    returnType:"CGSize",//option no returnType mean void
    },

})


defineProtocol("encodeTestProtocol",{
//use typeEncode to define complex method

    //you can write typeEncode by using runtime
    //you can input any string
    //makesure the number of args  is right
    testProtocolConstumStruct:{
        paramsType:"unknown",
        returnType:"int",
        typeEncode:"i32@0:8{CGVector=dd}16",
    },

    //you can write typeEncode by yourself
    //you can input any string
    //makesure the number of args  is right
    testProtocol_withB:{
        paramsType:"idontknown , mygod",
        returnType:"wooo",
        typeEncode:"i@:@^@",
    },

    //if your paramsType or returnType is complex
    //youcan input any string just make sure number is right
    //write the whole typeEncode  or  use runtime to generate typeEncode
})



//common testcase
defineProtocol('lalalala',{
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
       xxxxx:{
               paramsType:"BOOL",
               returnType:"void",
       },
});

//with new protocol  you can add no-id args method
defineClass('lalalalaViewcontroller:UIViewController <lalalala>', {
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
            xxxxx: function(oye) {
                console.log("7")
            },
            
});



