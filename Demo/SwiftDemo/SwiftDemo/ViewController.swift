//
//  ViewController.swift
//  SwiftDemo
//
//  Created by KouArlen on 16/2/3.
//  Copyright © 2016年 Arlen. All rights reserved.
//

import UIKit

//@objc(ViewController)
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        
        let testObject = TestObject()
        testObject.testLog()
        
        self.testLog()
    }
    
    /**
     if your patch doesn't take effect, you should consider adding the dynamic attribute to the function
     
     http://stackoverflow.com/questions/25651081/method-swizzling-in-swift
     
     In production environment, I advise you to add the dynamic attribute to all your Custom Function.
     But you must know, this operation will reduce efficiency.
     */
    dynamic func testLog() {
        print("ViewController orig testLog")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell", forIndexPath: indexPath)
        cell.textLabel?.text = NSString(format: "cell%d", indexPath.row) as String;
        return cell
    }
}

