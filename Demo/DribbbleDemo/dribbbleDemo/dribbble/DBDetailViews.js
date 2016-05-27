require('UIView, UIImage')
var gap = 10;
var avatarSize = 40;
defineClass('DBDetailHeaderView: UIView', ['tapUserCallback', 'itemData'], {
  initWithItem: function(item) {
    self = self.super().init();
    if (self) {
      self.setItemData(item);

      var avatarButton = require('UIButton')
                              .alloc()
                              .initWithFrame({x:gap, y:gap, width:avatarSize, height:avatarSize});
      avatarButton.addTarget_action_forControlEvents(self, 'handleTapUser', 1 <<  6);

      var nameLabel = UILabel
                        .alloc()
                        .initWithFrame({x: gap * 2 + avatarSize, y:gap, width:SCREEN_WIDTH - avatarSize - gap * 3 , height:20});
      nameLabel.setFont(UIFont.systemFontOfSize(14));

      var timeLabel = UILabel
                        .alloc()
                        .initWithFrame({x: gap * 2 + avatarSize, y:gap + 20, width:SCREEN_WIDTH - avatarSize - gap * 3 , height:20});
      timeLabel.setFont(UIFont.systemFontOfSize(12));
      timeLabel.setTextColor(UIColor.grayColor());

      var contentImageView = require('UIImageView')
                              .alloc()
                              .initWithFrame({x: gap, y:gap*2 + avatarSize, width:SCREEN_WIDTH - gap*2, height:(SCREEN_WIDTH - gap*2)*3/4});

      self.addSubview(avatarButton);
      self.addSubview(nameLabel);
      self.addSubview(timeLabel);
      self.addSubview(contentImageView);

      var panelView = self._genPanelViewWithItem(item);
      var panelFrame = panelView.frame();
      panelFrame.x = SCREEN_WIDTH - (gap + panelFrame.width);
      panelFrame.y = contentImageView.frame().y + contentImageView.frame().height + gap;
      panelView.setFrame(panelFrame);
      self.addSubview(panelView);

      avatarButton.sd__setImageWithURL_forState(require('NSURL').URLWithString(item['user']['avatar_url']), 0);
      contentImageView.sd__setImageWithURL(require('NSURL').URLWithString(item['images']['normal']));
      nameLabel.setText(item['user']['name'])

      var d = new Date(item['created_at']);
      var dateStr = d.getFullYear() + '年' + (d.getMonth() + 1) + '月' + d.getDate() + '日' + ' ' + d.getHours() + ':' + d.getMinutes();
      timeLabel.setText(dateStr);

      self.setFrame({x:0, y:0, width: SCREEN_WIDTH, height:panelView.frame().y + panelView.frame().height});
    }
    return self;
  },
  handleTapUser : function(){
    var cb = self.tapUserCallback();
    if (cb) cb(self.itemData()['user']);
  },
  _genPanelViewWithItem : function(item) {
    var panelView = UIView
                      .alloc()
                      .init();

    var iconSize = 12;
    var viewImageView = UIImageView
                          .alloc()
                          .initWithFrame({x:0, y:0, width:15, height: 15});
    viewImageView.setImage(UIImage.imageWithContentsOfFile(resourcePath('imgs/view.png')));
    panelView.addSubview(viewImageView);

    var viewLabel = self._genPanelLabel(item['views_count'], {x: UIHelper.rightX(viewImageView) + 5, y:0, width:40, height:iconSize});
    panelView.addSubview(viewLabel);



    var commentImageView = UIImageView
                          .alloc()
                          .initWithFrame({x:UIHelper.rightX(viewLabel) + 10, y:3, width:iconSize, height: iconSize});
    commentImageView.setImage(UIImage.imageWithContentsOfFile(resourcePath('imgs/comment.png')));
    panelView.addSubview(commentImageView);

    var commentLabel = self._genPanelLabel(item['comments_count'], {x: UIHelper.rightX(commentImageView) + 5, y:0, width:40, height:iconSize});
    panelView.addSubview(commentLabel);




    var likeImageView = UIImageView
                          .alloc()
                          .initWithFrame({x:UIHelper.rightX(commentLabel) + 10, y:3, width:iconSize, height: iconSize});
    likeImageView.setImage(UIImage.imageWithContentsOfFile(resourcePath('imgs/like.png')));
    panelView.addSubview(likeImageView);


    var commentLabel = self._genPanelLabel(item['likes_count'], {x: UIHelper.rightX(likeImageView) + 5, y:0, width:40, height:iconSize});
    panelView.addSubview(commentLabel);

    panelView.setFrame({x:0, y:0, width:UIHelper.rightX(commentLabel), height:40});

    return panelView;
  },
  _genPanelLabel: function(val, frame) {
    var viewLabel = UILabel.alloc().initWithFrame(frame)
    viewLabel.setText(val.toString());
    viewLabel.setFont(UIFont.systemFontOfSize(14));
    viewLabel.setTextColor(UIColor.colorWithWhite_alpha(.5, 1))
    viewLabel.sizeToFit();
    return viewLabel;
  }
})




defineClass('DBCommentViewCell: UITableViewCell', [
    'avatarButton', 
    'nameLabel',
    'timeLabel',
    'contentLabel',
    'tapUserCallback',
    'commentData',
], {
  initWithStyle_reuseIdentifier: function(style, reuseIdentifier) {
    self = self.super().initWithStyle_reuseIdentifier(style, reuseIdentifier);
    if (self) {
      self.setSelectionStyle(0);

      var avatarButton = require('UIButton')
                              .alloc()
                              .initWithFrame({x:gap, y:gap, width:avatarSize, height:avatarSize});
      avatarButton.addTarget_action_forControlEvents(self, 'handleTapUser', 1 <<  6);

      var nameLabel = UILabel
                        .alloc()
                        .initWithFrame({x: gap * 2 + avatarSize, y:gap, width:SCREEN_WIDTH - avatarSize - gap * 3 , height:20});
      nameLabel.setFont(UIFont.systemFontOfSize(14));
      nameLabel.setTextColor(UIColor.colorWithWhite_alpha(.5, 1))

      var timeLabel = UILabel
                        .alloc()
                        .initWithFrame({x: SCREEN_WIDTH - gap - 200, y:gap, width:200 , height:20});
      timeLabel.setFont(UIFont.systemFontOfSize(12));
      timeLabel.setTextColor(UIColor.colorWithWhite_alpha(.7, 1));
      timeLabel.setTextAlignment(2);

      var contentLabel = DBCommentViewCell._genContentLabel();
      self.addSubview(avatarButton);
      self.addSubview(nameLabel);
      self.addSubview(timeLabel);
      self.addSubview(contentLabel);

      self.setAvatarButton(avatarButton);
      self.setNameLabel(nameLabel);
      self.setTimeLabel(timeLabel);
      self.setContentLabel(contentLabel);
    }
    return self;
  },
  renderWithComment: function(comment) {
    self.avatarButton().sd__setImageWithURL_forState(require('NSURL').URLWithString(comment['user']['avatar_url']), 0);
    self.nameLabel().setText(comment['user']['name'])

    var d = new Date(comment['created_at']);
    var dateStr = d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate() + '-';// + ' ' + d.getHours() + ':' + d.getMinutes();
    self.timeLabel().setText(dateStr);

    DBCommentViewCell._renderContentLabel(comment, self.contentLabel());

    self.setCommentData(comment);
  },

  handleTapUser : function(){
    var cb = self.tapUserCallback();
    if (cb) cb(self.commentData()['user']);
  },
  

}, {

  heightWithComment: function(comment) {
    var contentLabel = self._genContentLabel();
    self._renderContentLabel(comment, contentLabel);
    var contentFrame = contentLabel.frame();
    return contentFrame.height + contentFrame.y + gap;
  },

  _renderContentLabel: function(comment, contentLabel) {
    if (!comment['bodyText']) {
      comment['bodyText'] = comment['body'].replace('\n', '').replace('</p>', '\n').replace(/<[^>]+>/g,"")
    }
    contentLabel.setText(comment['bodyText']);

    var size = contentLabel.sizeThatFits({width:contentLabel.frame().width, height:1000});
    var frame = contentLabel.frame();
    frame.height = size.height;
    contentLabel.setFrame(frame);
  },

  _genContentLabel: function() {
    var contentLabel = require('UILabel')
                                  .alloc()
                                  .initWithFrame({x:gap * 2 + avatarSize, y: gap*2 + 15, width:SCREEN_WIDTH - gap * 3 - avatarSize, height:0});

    contentLabel.setFont(UIFont.systemFontOfSize(16));
    contentLabel.setNumberOfLines(0);
    return contentLabel;
  }
})