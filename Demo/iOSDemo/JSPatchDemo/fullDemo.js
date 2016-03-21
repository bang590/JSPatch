require('UITableViewCell,UIAlertView,NSMutableArray,UITableView,UIScreen,JPTableViewCell,UIImage')
defineClass('JPViewController', {
            
    viewDidLoad:function(){
        self.super().viewDidLoad();
        self.setJPString('JP String Value');
        self.setValue_forKey('JP Protected String Value', '_protectedStr');
        self.setValue_forKey('JP Private String Value', '_privateString');
        self.setJPArray(NSMutableArray.alloc().initWithCapacity(10));
        for (var i = 0; i < 3; i++) {
          var imageName = 'Ysmd'+i%3;
          self.JPArray().addObject(imageName);
        }
        self.setJPDictionary({
                             '0':'Variable Test',
                             '1':'Target Test',
                             '2':'Block Test'
                             });
        self.setJPTableView(UITableView.alloc().initWithFrame_style(UIScreen.mainScreen().applicationFrame(), 0));
        self.JPTableView().setSeparatorStyle(0);
        self.JPTableView().setDelegate(self);
        self.JPTableView().setDataSource(self);
        self.view().addSubview(self.JPTableView());
    },
            
    scrollViewDidScroll: function(scrollView) {
        var visibleCells = self.JPTableView().visibleCells();
        for(var i = 0;i<self.JPTableView().visibleCells().count();i++) {
        var cell = self.JPTableView().visibleCells().objectAtIndex(i);
        if (cell.isKindOfClass(JPTableViewCell.class())) {
            cell.cellOnTableView_didScrollOnView(self.JPTableView(), self.view());
            }
        }
    },
            
    tableView_heightForRowAtIndexPath: function(tableView, indexPath) {
        return 180;
    },
            
    tableView_numberOfRowsInSection: function(tableView, section) {
        return self.JPArray().count();
    },
            
    tableView_cellForRowAtIndexPath: function(tableView, indexPath) {
        var cell =  tableView.dequeueReusableCellWithIdentifier('JPCell');
        if (!cell) {
        cell =  JPTableViewCell.alloc().initWithStyle_reuseIdentifier(0, 'JPCell');
        }
        cell.titleLabel().setText(self.JPDictionary().objectForKey(indexPath.row()+''));
        cell.subtitleLabel().setText("Please Selected This row");
        self.sd__setImageWithIndexPath(indexPath);
        return cell;
    },
            
    tableView_didSelectRowAtIndexPath: function(tableView, indexPath) {
        switch (indexPath.row() + 1) {
        case 1:
        {
        console.log('Property >>>> ',self.JPString());
        console.log('Private  >>>> ',self.valueForKey('_privateString'));
        console.log('Protected >>> ',self.valueForKey('_protectedStr'));
        }
        break;
        case 2:
        {
        var alertView = UIAlertView.alloc().initWithTitle_message_delegate_cancelButtonTitle_otherButtonTitles("Test Alert", "Test Message", self, "cancel", null, null);
        alertView.show();
        }
        break;
        case 3:
        {
        self.testBlock();
        }
        break;
        }
    },
            
    testBlock: function() {
        var blk = require('JPViewController').ocBlock();
        console.log('Test Block >>>>> Value:'+  blk(0,1));
    },
            
    sd__setImageWithIndexPath: function(indexPath) {
    dispatch_after(0.1, function() {
          dispatch_async_global_queue(function() {
               var cell = self.JPTableView().cellForRowAtIndexPath(indexPath);
               var image = UIImage.imageNamed(self.JPArray().objectAtIndex(indexPath.row()));
               dispatch_async_main(function() {
               cell.parallaxImage().setImage(image);
              });
         });
    });
    },
})

