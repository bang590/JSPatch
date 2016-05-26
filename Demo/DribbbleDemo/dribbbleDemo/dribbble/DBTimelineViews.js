var gap = 10;
var avatarSize = 40;
require('UILabel, UIColor, UIFont, UITextView');


defineClass('DBTimelineItemView: UIView', [
    'avatarImageView', 
    'nameLabel',
    'contentImageBtn',
    'tapCallback'
], {
  init: function(){
    self = self.super().init();

    var imgGap = 5;
    var width = (SCREEN_WIDTH - 10 * 3) / 2;
    self.setFrame({x: 0, y: 0, width:width, height: width * 3/4 + 30});
    self.setBackgroundColor(UIColor.whiteColor());

    var contentImageBtn = require('UIButton')
                            .alloc()
                            .initWithFrame({x: imgGap, y:imgGap, width:width - 2*imgGap, height:(width - 2*imgGap)*3/4});
    self.addSubview(contentImageBtn);
    self.setContentImageBtn(contentImageBtn);
    contentImageBtn.addTarget_action_forControlEvents(self, 'handleTap', 1 <<  6);

    var avatarSize = 18;

    var avatarImageView = require('UIImageView')
                            .alloc()
                            .initWithFrame({x:imgGap, y:contentImageBtn.frame().height + contentImageBtn.frame().y + imgGap + 2, width:avatarSize, height:avatarSize});
    self.addSubview(avatarImageView);
    self.setAvatarImageView(avatarImageView);

    var nameLabel = UILabel
                      .alloc()
                      .initWithFrame({x: imgGap + avatarSize + 5, y:avatarImageView.frame().y, width:width - avatarSize - imgGap*2 - 5 , height:avatarSize});
    nameLabel.setFont(UIFont.systemFontOfSize(12));
    nameLabel.setTextColor(UIColor.grayColor());
    self.addSubview(nameLabel);
    self.setNameLabel(nameLabel);

    return self;
  },

  handleTap: function() {
    var cb = self.tapCallback();
    if (cb) cb();
  },

  renderWithItem: function(item) {
    self.contentImageBtn().sd__setImageWithURL_forState(require('NSURL').URLWithString(item['images']['normal']), 0);
    self.avatarImageView().sd__setImageWithURL(require('NSURL').URLWithString(item['user']['avatar_url']));
    self.nameLabel().setText(item['user']['name']);
  },

})

defineClass('DBTimelineViewCell: UITableViewCell', [
    'itemView1', 
    'itemView2',
    'tapCallback',
], {
  initWithStyle_reuseIdentifier: function(style, reuseIdentifier) {
      self = self.super().initWithStyle_reuseIdentifier(style, reuseIdentifier);
      if (self) {
        self.setSelectionStyle(0);
        self.contentView().setBackgroundColor(UIColor.colorWithWhite_alpha(.9, 1));
        self._initItemView();
      }
      return self;
  },
  _initItemView: function(){
    var itemView1 = DBTimelineItemView.alloc().init();
    var itemView2 = DBTimelineItemView.alloc().init();

    itemView1.setFrame({x:gap, y: gap, width: itemView1.frame().width, height: itemView1.frame().height});
    itemView2.setFrame({x:gap*2 + itemView1.frame().width, y: gap, width: itemView2.frame().width, height: itemView2.frame().height});

    self.setItemView1(itemView1);
    self.setItemView2(itemView2);

    self.addSubview(itemView1);
    self.addSubview(itemView2);
  },
  renderWithItems: function(item1, item2) {
    if (item1) {
      self.itemView1().renderWithItem(item1);
    }
    if (item2) {
      self.itemView2().renderWithItem(item2);
    }
    self.itemView1().setHidden(!item1);
    self.itemView2().setHidden(!item2);

    var slf = self
    self.itemView1().setTapCallback(function(){
      var cb = slf.tapCallback();
      if (cb) cb(item1);
    })
    self.itemView2().setTapCallback(function(){
      var cb = slf.tapCallback();
      if (cb) cb(item2);
    })
  }
})

defineClass('DBLoadMoreView:UIView', {
  init: function(){
    self = self.super().init();
    
    var loadingView = require('UIActivityIndicatorView').alloc().initWithActivityIndicatorStyle(2);
    loadingView.startAnimating();
    loadingView.setFrame({x:(SCREEN_WIDTH - 140) / 2, y: 10, width:40, height: 40});

    var loadingLabel = require('UILabel').alloc().init();
    loadingLabel.setText('Loading...');
    loadingLabel.setFrame({x:(SCREEN_WIDTH - 140) / 2 + 40, y: 10, width:90, height: 40});
    loadingLabel.setTextColor(require('UIColor').grayColor());

    self.addSubview(loadingView);
    self.addSubview(loadingLabel);

    self.setFrame({x:0, y:0, width:SCREEN_WIDTH, height: 60});
    return self;
  },
})