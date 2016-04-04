include('DBTimelineViews.js')
include('DBUserViews.js')

defineClass('DBUserViewController: UITableViewController', [
  'loadingView', 
  'isLoading',
  'commentsData',
  'user',
  'shots',
  'currPage'
  ], {
  initWithUser: function(user){
    self = self.super().init();
    if (self) {
      self.tableView().setSeparatorStyle(0);
      self.tableView().setBackgroundColor(UIColor.colorWithWhite_alpha(.9, 1));
      self.setTitle(user['name']);

      var headerView = DBUserHeaderView.alloc().initWithUser(user);
      self.tableView().setTableHeaderView(headerView);

      var loadingView = require('UIActivityIndicatorView').alloc().initWithActivityIndicatorStyle(2);
      loadingView.setFrame({x: (SCREEN_WIDTH - 40) / 2, y:headerView.frame().height + 30, width:40, height:40});
      loadingView.startAnimating();
      self.view().addSubview(loadingView);
      self.setLoadingView(loadingView);

      self.setShots([]);
      self.setUser(user);
      self.setCurrPage(1);
      self._loadShots();
    }
    return self;
  },

  _loadShots: function(){
    self.setIsLoading(1)
    var user = self.user();
    var perPage = 10;
    var slf = self;
    DBDataSource.shareInstance().loadUserShots(user['id'], self.currPage(), perPage, function(newShots){
      slf.loadingView().removeFromSuperview();
      slf.setShots(slf.shots().concat(newShots));
      slf.setCurrPage(slf.currPage() + 1);
      slf.setIsLoading(0);

      if (newShots.length >= perPage) {
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
    if (!self.shots()) return 0;
    return self.shots().length / 2;
  },
  tableView_cellForRowAtIndexPath: function(tableView, indexPath) {
    var cell = tableView.dequeueReusableCellWithIdentifier("cell") 
    if (!cell) {
      cell = DBUserViewCell.alloc().initWithStyle_reuseIdentifier(0, "cell")
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
    return (SCREEN_WIDTH / 2) *3/4;
  },

  scrollViewDidScroll: function(scrollView) {
    var contentOffset = scrollView.contentOffset();
    var contentSize = scrollView.contentSize();
    if (!self.isLoading() && self.tableView().tableFooterView() && contentOffset.y - contentSize.height > -SCREEN_HEIGHT) {
      self._loadShots();
    }
  },

  _handleGotoItem: function(item) {
    if (!item.user) item.user = self.user();
    var detailVC = DBDetailViewController.alloc().initWithItem(item);
    self.navigationController().pushViewController_animated(detailVC, YES);
  }
})