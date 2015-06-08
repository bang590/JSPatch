//
//  JPTableViewControllerNative.m
//  JSPatch
//
//  Created by tom on 15/6/8.
//  Copyright (c) 2015年 tom. All rights reserved.
//

#import "JPTableViewControllerNative.h"

@interface JPTableViewControllerNative(){
    NSMutableArray *dataSource;
}
@end

@implementation JPTableViewControllerNative

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initDataSource];
    }
    return self;
}

- (void)initDataSource {
    dataSource = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < 20; i++){
        [dataSource addObject:[NSString stringWithFormat:@"cell from oc %@", @(i)]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = dataSource[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


@end
