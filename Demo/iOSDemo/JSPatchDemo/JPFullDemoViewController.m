//
//  JPViewController.m
//  JSPatch
//
//  Created by RainbowColor on 15/5/2.
//  Copyright (c) 2015年 bang. All rights reserved.
//

#import "JPFullDemoViewController.h"
#import "JPTableViewCell.h"

#define windowFrame  [UIScreen mainScreen].applicationFrame

static NSString  *JPCellIdentifier = @"JPCell";

static const CGFloat kJPTableViewCellHeight = 180.0f;

typedef int (^JPBlock) (BOOL flag, int value);

typedef NS_ENUM(NSUInteger, JPEnumType) {
    JPEnumTypeOne   = 0,
    JPEnumTypeTwo   = 1,
};


@implementation JPFullDemoViewController {
    NSString *_privateString;
}

- (NSString *)JPCellIdentifier {
    return JPCellIdentifier;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.jpString = @"JP String Value";
    
   _privateString = @"JP Private String Value";
    
    self.jpArray = [[NSMutableArray alloc]initWithCapacity:10];
    for (int i = 0; i<3; i++) {
        NSString *imageName = [NSString stringWithFormat:@"Ysmd%d",i%3];
        [self.jpArray addObject:imageName];
    }
    
    self.jpDictionary = @{@"0":@"Variable Test",@"1":@"Target Test",@"2":@"Block Test"};
    
    self.jpTableView = [[UITableView alloc]initWithFrame:windowFrame style:UITableViewStylePlain];
    self.jpTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.jpTableView.delegate = self;
    self.jpTableView.dataSource = self;
    [self.view addSubview:_jpTableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *visibleCells = [self.jpTableView visibleCells];
    for (JPTableViewCell *cell in visibleCells) {
        if ([cell isKindOfClass:[JPTableViewCell class]]) {
        [cell cellOnTableView:self.jpTableView didScrollOnView:self.view];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kJPTableViewCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.jpArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JPTableViewCell *cell = (JPTableViewCell*)[tableView dequeueReusableCellWithIdentifier:JPCellIdentifier];
    if (!cell) {
        cell = (JPTableViewCell*)[[JPTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JPCellIdentifier];
    }
    cell.titleLabel.text = [_jpDictionary objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]];
    cell.subtitleLabel.text = @"Please Selected This row";
    [self sd_setImageWithIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row+1) {
        case 1:
        {
            NSLog(@"Property >>>> %@",_jpString);
            NSLog(@"Private >>>>%@",_privateString);
        }
            break;
        case 2:
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Test Alert" message:@"Test Message" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
        case 3:
        {
            [self testBlock];
        }
            break;
    }
}

+ (JPBlock)jpBlock
{
    JPBlock block = ^(BOOL flag,  int value){
        if(flag){
            return value;
        }
        return 0;
    };
    return block;
}
+ (void)execBlock:(JPBlock)blk
{
}
- (void)testBlock
{
    
    JPBlock block = [JPFullDemoViewController jpBlock];
    NSLog(@"Test Block >>>>> Value:%d",block(0,1));
}

- (void)sd_setImageWithIndexPath:(NSIndexPath*)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                JPTableViewCell *cell = (JPTableViewCell*)[self.jpTableView cellForRowAtIndexPath:indexPath];
                UIImage * image = [UIImage imageNamed:[self.jpArray objectAtIndex:indexPath.row]];
                dispatch_async(dispatch_get_main_queue(), ^{
                        cell.parallaxImage.image = image;
                });
            });
    });
}

@end


