//
//  TestObject.swift
//  SwiftDemo
//
//  Created by jspatch on 16/2/3.
//  Copyright © 2016年 Arlen. All rights reserved.
//

import Foundation

/**
 After XCode 7.0(could be Swift 2.2), the Swift Class can not be marked using @objc,
 and it can't be use in objc rumtime directly. 
 So if you want to use JSPatch in your project,
 you should declare all your Swift Classes inherited from NSObject
 
 https://forums.developer.apple.com/thread/11867
 */

open class TestObject: NSObject {
    
    /**
     if your patch doesn't take effect, you should consider adding the dynamic attribute to the function
     
     http://stackoverflow.com/questions/25651081/method-swizzling-in-swift
     
     In production environment, I advise you to add the dynamic attribute to all your Custom Functions.
     But you must know, this operation will reduce efficiency.
     */
    
    dynamic func testLog() {
        print("TestObject orig testLog")
    }
}
