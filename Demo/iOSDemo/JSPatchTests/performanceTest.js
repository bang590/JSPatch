var performanceTestObj = require('NSObject').alloc().init();
var largeDict = {
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
};
defineClass('JPPerformanceTest', {
    testJSCallOCEmptyMethod: function() {
        var slf = self
        for (var i = 0; i < 10000; i ++) {
            slf.emptyMethod();
        }
    },
    testJSCallOCMethodWithParamObject: function() {
        var slf = self
        for (var i = 0; i < 10000; i ++) {
            slf.methodWithParamObject(performanceTestObj);
        }
    },
    testJSCallOCMethodReturnObject: function() {
        var slf = self
        for (var i = 0; i < 10000; i ++) {
            slf.methodReturnObject();
        }
    },
    
    testJSCallJSEmptyMethod: function() {
        var slf = self
        for (var i = 0; i < 10000; i ++) {
            slf.newJSEmptyMethod();
        }
    },
    
    testJSCallJSMethodWithParam: function() {
        var slf = self
        for (var i = 0; i < 10000; i ++) {
            slf.newJSMethodWithParam(performanceTestObj);
        }
    },
    
    testJSCallJSMethodWithLargeDictionaryParam: function() {
        var slf = self
        for (var i = 0; i < 1000; i ++) {
            slf.newJSMethodWithLargeDictionaryParam(largeDict);
        }
    },
    
    testJSCallJSMethodWithLargeDictionaryParamAutoConvert: function() {
        var slf = self
        autoConvertOCType(1);
        for (var i = 0; i < 1000; i ++) {
            slf.newJSMethodWithLargeDictionaryParam(largeDict);
        }
        autoConvertOCType(0);
    },
    
    emptyMethodToOverride: function() {
        
    },
    methodWithParamObjectToOverride: function(obj) {
        
    },
    methodReturnObjectToOverride: function() {
        return performanceTestObj;
    },
    
    newJSEmptyMethod: function() {
        
    },
    
    newJSMethodWithParam: function(param) {
    
    },
    
    newJSMethodWithLargeDictionaryParam: function(dict) {
        
    },
    
    testJSCallMallocJPMemory: function() {
        require('JPEngine').addExtensions(['JPMemory'])
        for (var i = 0; i < 100000; i ++) {
            var p = malloc(10)
        }
    },
    
    testJSCallMallocJPCFunction: function() {
        require('JPEngine').addExtensions(['JPCFunction'])
        for (var i = 0; i < 100000; i ++) {
            defineCFunction("malloc", "void *, size_t")
            var p = malloc(10)
        }
    }

})