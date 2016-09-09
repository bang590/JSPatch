require('UILabel, UIColor, UIFont, UIScreen, UIImageView, UIImage')

var screenWidth = UIScreen.mainScreen().bounds().width;
var screenHeight = UIScreen.mainScreen().bounds().height;

defineClass('JPDemoController: UIViewController', {
    viewDidLoad: function() {
        self.super().viewDidLoad();
        self.view().setBackgroundColor(UIColor.whiteColor());
        var size = 120;
        var imgView = UIImageView.alloc().initWithFrame({x: (screenWidth - size)/2, y: 150, width: size, height: size});
        imgView.setImage(UIImage.imageNamed('apple'))
        
        self.view().addSubview(imgView);

        var label = UILabesl.alloc().initWithFrame({x: 0, y: 310, width: screenWidth, height: 30});
        label.setText("JSPatc22h");
        label.setTextAlignment(1);
        label.setFont(UIFont.systemFontOfSize(25));
        self.view().addSubview(label);
    },
})
