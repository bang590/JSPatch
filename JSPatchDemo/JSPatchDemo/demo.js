defineClass('JPViewController', {
//  viewDidLoad: function() {
//    self.super.viewDidLoad();
//    var width = require('UIScreen').mainScreen().bounds().width
//    var btn = require('UIButton').alloc().initWithFrame({x:0, y:100, width:width, height:50})
//    btn.setTitle_forState('Push JPTableViewController', 0)
//    btn.addTarget_action_forControlEvents(self, 'testNilBlock:', 1 << 6)  //Test nil selector
//    btn.setBackgroundColor(require('UIColor').grayColor())
//    self.view().addSubview(btn)
//  },      

  handleBtn: function(sender) {
    var tableViewCtrl = JPTableViewController.alloc().init()
    self.navigationController().pushViewController_animated(tableViewCtrl, YES)
  },

//  testNilBlock: function(sender) {
//    var url     = require('NSURL').URLWithString("http://www.baidu.com")
//    var request = require('NSURLRequest').requestWithURL(url)
//    var queue   = require('NSOperationQueue').alloc().init()
//    require('NSURLConnection').sendAsynchronousRequest_queue_completionHandler(request,queue,undefined)
//
//  }
})

defineClass('JPTableViewController : UITableViewController', {
  dataSource: function() {
    var data = self.getProp('data')
    if (data) return data;
    var data = [];
    for (var i = 0; i < 20; i ++) {
      data.push("cell from js " + i);
    }
    self.setProp_forKey(data, 'data')
    return data;
  },
  numberOfSectionsInTableView: function(tableView) {
    return 1;
  },
  tableView_numberOfRowsInSection: function(tableView, section) {
    return self.dataSource().length;
  },
  tableView_cellForRowAtIndexPath: function(tableView, indexPath) {
    var cell = tableView.dequeueReusableCellWithIdentifier("cell") 
    if (!cell) {
      cell = require('UITableViewCell').alloc().initWithStyle_reuseIdentifier(0, "cell")
    }
    cell.textLabel().setText(self.dataSource()[indexPath.row()])
    return cell
  },
  tableView_heightForRowAtIndexPath: function(tableView, indexPath) {
    return 60
  },
  tableView_didSelectRowAtIndexPath: function(tableView, indexPath) {
     var alertView = require('UIAlertView').alloc().initWithTitle_message_delegate_cancelButtonTitle_otherButtonTitles("Alert",self.dataSource()[indexPath.row()],undefined,"OK",undefined);
//     alertView.setTitle('Alert')
//     alertView.setMessage(self.dataSource()[indexPath.row()])
//     alertView.addButtonWithTitle('OK')
     alertView.show()
  }
})