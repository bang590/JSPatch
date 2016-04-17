include('DBTimelineViews.js')
include('DBDetailController.js')

defineClass('WBTimelineViewController: UITableViewController', [
  'loadingView', 
  'isLoading',
  'shots',
  'currPage'
], {
  init: function(){
    self = self.super().init();

    var loadingView = require('UIActivityIndicatorView').alloc().initWithActivityIndicatorStyle(2);
    loadingView.setFrame({x: (SCREEN_WIDTH - 40) / 2, y:(SCREEN_HEIGHT - 40 - 64) / 2, width:40, height:40});
    loadingView.startAnimating();
    self.view().addSubview(loadingView);
    self.setLoadingView(loadingView);

    self.tableView().setBackgroundColor(UIColor.colorWithWhite_alpha(.9, 1));
    self.tableView().setSeparatorStyle(0);
    self.setTitle('Dribbble');

    self.setShots([]);
    self.setCurrPage(1);
    self._loadShots();
    return self;
  },

  _loadShots: function() {
    self.setIsLoading(1)
    var perPage = 20;
    var slf = self;
    DBDataSource.shareInstance().loadPublicShots(self.currPage(), perPage, function(shots){
      slf.loadingView().removeFromSuperview();
      slf.setShots(slf.shots().concat(shots));
      slf.setCurrPage(slf.currPage() + 1);
      slf.setIsLoading(0);

      if (shots.length >= perPage) {
        slf.tableView().setTableFooterView(DBLoadMoreView.alloc().init());
      } else {
        slf.tableView().setTableFooterView(null);
      }
      slf.tableView().reloadData();
    }, function(){
      //fail
    })
  },
  numberOfSectionsInTableView: function(tableView) {
    return 1;
  },
  tableView_numberOfRowsInSection: function(tableView, section) {
    return self.shots().length / 2;
  },
  tableView_cellForRowAtIndexPath: function(tableView, indexPath) {
    var cell = tableView.dequeueReusableCellWithIdentifier("cell") 
    if (!cell) {
      cell = DBTimelineViewCell.alloc().initWithStyle_reuseIdentifier(0, "cell")
      var slf = self;
      cell.setTapCallback(function(item){
        slf._handleGotoItem(item);
      })
    }

    cell.renderWithItems(self.shots()[indexPath.row()*2],
                         self.shots()[indexPath.row()*2 + 1]);
    return cell
  },
  tableView_heightForRowAtIndexPath: function(tableView, indexPath) {
    return (SCREEN_WIDTH / 2) *3/4 + 30;
  },

  scrollViewDidScroll: function(scrollView) {
    var contentOffset = scrollView.contentOffset();
    var contentSize = scrollView.contentSize();
    if (!self.isLoading() && contentOffset.y - contentSize.height > -SCREEN_HEIGHT) {
      self._loadShots();
    }
  },

  _handleGotoItem: function(item) {
    var detailVC = DBDetailViewController.alloc().initWithItem(item);
    self.navigationController().pushViewController_animated(detailVC, YES);
  }
})