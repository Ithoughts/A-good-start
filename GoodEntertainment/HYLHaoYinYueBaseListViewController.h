//
//  HYLHaoYinYueListViewController.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/9/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HaoYinYueListType) {
    HaoYinYueListTypeShow = 0,
    HaoYinYueListTypeMV = 1,
    HaoYinYueListTypeBangDan = 2
};

@interface HYLHaoYinYueBaseListViewController : UIViewController

@property (nonatomic) HaoYinYueListType haoYinYueListType;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isFromHaoYinYueContainer;

@end
