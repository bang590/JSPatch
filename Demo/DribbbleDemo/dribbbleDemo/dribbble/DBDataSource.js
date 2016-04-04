var _dataSourceShareInstance;
defineJSClass('DBDataSource', {
  init: function(){
    this.dribbbleHost = 'https://api.dribbble.com/v1';
    this.requestManager = require('AFHTTPRequestOperationManager').manager();
    this.requestManager.requestSerializer().setValue_forHTTPHeaderField('Bearer deeb37c0823d3866650db12df9e36730a0453a5a7b8e6493e0ac5ece15929613', 'Authorization');
    return this;
  },

  _get: function(path, params, succ, fail){
    var url = this.dribbbleHost + path
    this.requestManager.GET_parameters_success_failure(url, params, 
      block('AFHTTPRequestOperation *, id', function(operation, responseObject) {
          if (succ) succ(responseObject);
      }), 
      block('AFHTTPRequestOperation *, NSError *', function(operation, error) {
          if (fail) fail(error);
      })
    );
  },
  loadPublicShots: function(page, per_page, succ, fail) {
    var path = '/shots';
    this._get(path, {page: page, per_page:per_page}, succ, fail)
  },
  loadComments: function(id, page, per_page, succ, fail) {
    var path = '/shots/' + id + '/comments';
    this._get(path, {page: page, per_page:per_page}, succ, fail)
  },

  loadUserShots: function(userId, page, per_page, succ, fail) {
    var path = '/users/' + userId + '/shots';
    this._get(path, {page: page, per_page:per_page}, succ, fail)
  },

}, {
  shareInstance: function(){
    if (!_dataSourceShareInstance) {
      _dataSourceShareInstance = DBDataSource.alloc().init();
    }
    return _dataSourceShareInstance;
  },
})


/*item struct:

{
    "id": 2619381,
    "title": "Seaborn Oyster Co.",
    "description": null,
    "width": 400,
    "height": 300,
    "images": {
      "hidpi": "https://d13yacurqjgara.cloudfront.net/users/52758/screenshots/2619381/seaborn_oyster_co_j_fletcher.jpg",
      "normal": "https://d13yacurqjgara.cloudfront.net/users/52758/screenshots/2619381/seaborn_oyster_co_j_fletcher_1x.jpg",
      "teaser": "https://d13yacurqjgara.cloudfront.net/users/52758/screenshots/2619381/seaborn_oyster_co_j_fletcher_teaser.jpg"
    },
    "views_count": 2166,
    "likes_count": 235,
    "comments_count": 2,
    "attachments_count": 0,
    "rebounds_count": 0,
    "buckets_count": 11,
    "created_at": "2016-03-29T17:12:41Z",
    "updated_at": "2016-03-29T17:12:53Z",
    "html_url": "https://dribbble.com/shots/2619381-Seaborn-Oyster-Co",
    "attachments_url": "https://api.dribbble.com/v1/shots/2619381/attachments",
    "buckets_url": "https://api.dribbble.com/v1/shots/2619381/buckets",
    "comments_url": "https://api.dribbble.com/v1/shots/2619381/comments",
    "likes_url": "https://api.dribbble.com/v1/shots/2619381/likes",
    "projects_url": "https://api.dribbble.com/v1/shots/2619381/projects",
    "rebounds_url": "https://api.dribbble.com/v1/shots/2619381/rebounds",
    "animated": false,
    "tags": [
      "charleston",
      "company",
      "ocean",
      "oyster",
      "sea",
      "wave"
    ],
    "user": {
      "id": 52758,
      "name": "Jay Fletcher",
      "username": "jfletcherdesign",
      "html_url": "https://dribbble.com/jfletcherdesign",
      "avatar_url": "https://d13yacurqjgara.cloudfront.net/users/52758/avatars/normal/J_FLETCHER_DESIGN_LOGO-01.jpg?1401983283",
      "bio": "",
      "location": "Charleston, SC",
      "links": {
        "web": "http://www.jfletcherdesign.com",
        "twitter": "https://twitter.com/jfletcherdesign"
      },
      "buckets_count": 0,
      "comments_received_count": 5239,
      "followers_count": 13803,
      "followings_count": 558,
      "likes_count": 6531,
      "likes_received_count": 104895,
      "projects_count": 10,
      "rebounds_received_count": 325,
      "shots_count": 481,
      "teams_count": 0,
      "can_upload_shot": true,
      "type": "Player",
      "pro": true,
      "buckets_url": "https://api.dribbble.com/v1/users/52758/buckets",
      "followers_url": "https://api.dribbble.com/v1/users/52758/followers",
      "following_url": "https://api.dribbble.com/v1/users/52758/following",
      "likes_url": "https://api.dribbble.com/v1/users/52758/likes",
      "projects_url": "https://api.dribbble.com/v1/users/52758/projects",
      "shots_url": "https://api.dribbble.com/v1/users/52758/shots",
      "teams_url": "https://api.dribbble.com/v1/users/52758/teams",
      "created_at": "2011-08-13T23:30:38Z",
      "updated_at": "2016-03-29T17:12:53Z"
    },
    "team": null
  },

  */