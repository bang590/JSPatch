include('DBDetailViews.js')
include('DBUserController.js')

defineClass('DBDetailViewController: UITableViewController', [
  'loadingView', 
  'isLoading',
  'commentsData',
  'itemData',
  'currPage'
  ], {
  initWithItem: function(item){
    self = self.super().init();
    if (self) {
      self.tableView().setSeparatorStyle(0);
      self.setTitle(item['title']);

      var headerView = DBDetailHeaderView.alloc().initWithItem(item);
      var slf = self;
      headerView.setTapUserCallback(function(user){
        slf._handleGotoUser(user);
      })
      self.tableView().setTableHeaderView(headerView);


      var loadingView = require('UIActivityIndicatorView').alloc().initWithActivityIndicatorStyle(2);
      loadingView.setFrame({x: (SCREEN_WIDTH - 40) / 2, y:headerView.frame().height + 30, width:40, height:40});
      loadingView.startAnimating();
      self.view().addSubview(loadingView);
      self.setLoadingView(loadingView);

      self.setCommentsData([]);
      self.setItemData(item);
      self.setCurrPage(1);
      self._loadComment();
    }
    return self;
  },

  _loadComment: function(){
    self.setIsLoading(1)
    var item = self.itemData();
    var perPage = 10;
    var slf = self;
    DBDataSource.shareInstance().loadComments(item['id'], self.currPage(), perPage, function(comments){
      slf.loadingView().removeFromSuperview();
      slf.setCommentsData(slf.commentsData().concat(comments));
      slf.setCurrPage(slf.currPage() + 1);
      slf.setIsLoading(0);

      if (comments.length >= perPage) {
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
    if (!self.commentsData()) return 0;
    return self.commentsData().length;
  },
  tableView_cellForRowAtIndexPath: function(tableView, indexPath) {
    var cell = tableView.dequeueReusableCellWithIdentifier("cell") 
    if (!cell) {
      cell = DBCommentViewCell.alloc().initWithStyle_reuseIdentifier(0, "cell")
      var slf = self;
      cell.setTapUserCallback(function(user){
        slf._handleGotoUser(user);
      })
    }

    cell.renderWithComment(self.commentsData()[indexPath.row()]);
    return cell
  },
  tableView_heightForRowAtIndexPath: function(tableView, indexPath) {
    var comment = self.commentsData()[indexPath.row()];
    if (!comment['contentHeight']) {
      comment['contentHeight'] = DBCommentViewCell.heightWithComment(comment);
    }
    return comment['contentHeight'];
  },

  scrollViewDidScroll: function(scrollView) {
    var contentOffset = scrollView.contentOffset();
    var contentSize = scrollView.contentSize();
    if (!self.isLoading() && self.tableView().tableFooterView() && contentOffset.y - contentSize.height > -SCREEN_HEIGHT) {
      self._loadComment();
    }
  },

  _handleGotoUser: function(user) {
    var userVC = DBUserViewController.alloc().initWithUser(user);
    self.navigationController().pushViewController_animated(userVC, YES);
  }
})