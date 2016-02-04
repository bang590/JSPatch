//
//  TestObject.swift
//  SwiftDemo
//
//  Created by KouArlen on 16/2/3.
//  Copyright © 2016年 Arlen. All rights reserved.
//

import Foundation

public class TestObject: NSObject {
    
    /**
     if your patch doesn't take effect, you should consider adding the dynamic attribute to the function
     
     http://stackoverflow.com/questions/25651081/method-swizzling-in-swift
     
     In production environment, I advise you to add the dynamic attribute to all your Custom Function.
     But you must know, this operation will reduce efficiency.
     */
    
    dynamic func testLog() {
        print("TestObject orig testLog")
    }
}
