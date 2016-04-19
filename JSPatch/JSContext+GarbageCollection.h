//
//  JSContext+GarbageCollection.h
//  JSPatchDemo
//
//  Created by GinVan on 16/4/18.
//  Copyright © 2016年 bang. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>


@interface JSContext (GarbageCollection)

-(void)garbageCollect;

@end
