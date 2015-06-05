defineClass('JPViewController', {
  handleBtn: function(sender) {
    var tableViewCtrl = JPTableViewController.alloc().init()
    self.navigationController().pushViewController_animated(tableViewCtrl, YES)
  }
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
     var alertView = require('UIAlertView').alloc().init()
     alertView.setTitle('Alert')
     alertView.setMessage(self.dataSource()[indexPath.row()])
     alertView.addButtonWithTitle('OK')
     alertView.show()
  }
})

defineClass('MultithreadTestObject', {
            addValueJS: function(num) {
            self.addValue(num);
            },
            addValue: function(num) {
            self.ORIGaddValue(num);
            }

            });