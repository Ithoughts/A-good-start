//
//  HYLHaoYuLeListContainerViewController.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewPagerController.h"

#import "HYLTitlePagerView.h"

#import "HYLTouTiaoViewController.h"
#import "HYLTuiJieViewController.h"
#import "HYLYuanChuangViewController.h"

@interface HYLHaoYuLeListContainerViewController : ViewPagerController

@property (nonatomic, strong) HYLTuiJieViewController *zhuanFangListVC;
@property (nonatomic, strong) HYLTouTiaoViewController *touTiaoListVC;
@property (nonatomic, strong) HYLYuanChuangViewController *yuanChuangListVC;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) HYLTitlePagerView *pagingTitleView;

@end
