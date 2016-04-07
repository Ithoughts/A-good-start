//
//  HYLHaoYuLeListViewController.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HaoYuLeListType) {
    HaoYuLeListTypeZhuanFang = 0,
    HaoYuLeListTypeTouTiao = 1,
    HaoYuLeListTypeYuanChuang = 2
};

@interface HYLHaoYuLeListBaseViewController : UIViewController

@property (nonatomic) HaoYuLeListType haoYuLeListType;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isFromHaoYuLeContainer;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign)  NSInteger page;

@end
