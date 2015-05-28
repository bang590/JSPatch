defineClass('AppDelegate', {
    buttonJavaScriptTestAction: function(sender) {
        self.setClickCount(self.clickCount() + 1);
        
        sender.setTitle("Clicked " + self.clickCount() + " times");
        
        self.tableView().reloadData();
    },
            
    numberOfRowsInTableView: function(tableView) {
        return self.clickCount();
    },
            
    tableView_viewForTableColumn_row: function(tableView, tableColumn, row) {
        var view = tableView.makeViewWithIdentifier_owner("TABLEVIEW_CELL", self);
        
        view.textField().setStringValue("Clicked " + (row + 1) + " times");
        
        return view;
    }
});