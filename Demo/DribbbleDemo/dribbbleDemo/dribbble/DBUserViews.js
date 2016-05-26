var gap = 10;

defineClass('DBUserHeaderView: UIView', {
  initWithUser: function(user) {
    self = self.super().init();
    if (self) {
      var avatarSize = 100;
      var avatarImageView = require('UIImageView')
                              .alloc()
                              .initWithFrame({x:(SCREEN_WIDTH - avatarSize) / 2, y:30, width:avatarSize, height:avatarSize});


      var nameLabel = UILabel
                        .alloc()
                        .initWithFrame({x: 0, y:UIHelper.bottomY(avatarImageView) + 10, width:SCREEN_WIDTH, height:30});
      nameLabel.setFont(UIFont.systemFontOfSize(18));
      nameLabel.setTextAlignment(1);


      var panelView = UIView
                        .alloc()
                        .initWithFrame({x:0, y:UIHelper.bottomY(nameLabel) + 10,width:SCREEN_WIDTH, height:80});

      var followerView = self._genUserDataView('follower', user['followers_count']);
      var shotsView = self._genUserDataView('shots', user['shots_count']);
      var likeView = self._genUserDataView('likes', user['likes_received_count']);

      UIHelper.setX(shotsView, UIHelper.rightX(followerView));
      UIHelper.setX(likeView, UIHelper.rightX(shotsView));

      panelView.addSubview(followerView);
      panelView.addSubview(shotsView);
      panelView.addSubview(likeView);

      self.addSubview(avatarImageView);
      self.addSubview(nameLabel);
      self.addSubview(panelView);

      avatarImageView.sd__setImageWithURL(require('NSURL').URLWithString(user['avatar_url']));
      nameLabel.setText(user['name']);

      self.setFrame({x:0, y:0, width:SCREEN_WIDTH, height: UIHelper.bottomY(panelView)});
    }
    return self;
  },
  _genUserDataView : function(name, num) {
    var width = SCREEN_WIDTH / 3
    var panelView = UIView
                      .alloc()
                      .initWithFrame({x:0,y:0,width:width,height:80});

    var numLabel = UILabel.alloc().initWithFrame({x:0,y:0,width:width,height:40})
    numLabel.setText(self._formatNum(num));
    numLabel.setFont(UIFont.systemFontOfSize(22));
    numLabel.setTextAlignment(1);

    var nameLabel = UILabel.alloc().initWithFrame({x:0,y:35,width:width,height:30})
    nameLabel.setText(name);
    nameLabel.setFont(UIFont.systemFontOfSize(15));
    nameLabel.setTextColor(UIColor.colorWithWhite_alpha(.5, 1))
    nameLabel.setTextAlignment(1);

    panelView.addSubview(numLabel);
    panelView.addSubview(nameLabel);

    return panelView;
  },
  _formatNum: function(num){
    if (num >= 1000) {
      return (num/1000).toFixed(1) + 'k'
    }
    return num ? num.toString() : 0;
  }
})




defineClass('DBUserItemView: DBTimelineItemView', {
  init: function() {
    self = self.super().init();
    self.avatarImageView().removeFromSuperview();
    self.nameLabel().removeFromSuperview();
    var width = (SCREEN_WIDTH - 10 * 3) / 2;
    self.setFrame({x: 0, y: 0, width:width, height: width * 3/4 + 5});
    return self;
  },
  renderWithItem: function(item) {
    self.contentImageBtn().sd__setImageWithURL_forState(require('NSURL').URLWithString(item['images']['normal']), 0);
  },

});



defineClass('DBUserViewCell: DBTimelineViewCell', {
  _initItemView: function() {
    var itemView1 = DBUserItemView.alloc().init();
    var itemView2 = DBUserItemView.alloc().init();

    itemView1.setFrame({x:gap, y: gap, width: itemView1.frame().width, height: itemView1.frame().height});
    itemView2.setFrame({x:gap*2 + itemView1.frame().width, y: gap, width: itemView2.frame().width, height: itemView2.frame().height});

    self.setItemView1(itemView1);
    self.setItemView2(itemView2);

    self.addSubview(itemView1);
    self.addSubview(itemView2);
  },

});



