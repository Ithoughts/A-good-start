//
//  HYLHaoYuLeListContainerViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLHaoYuLeListContainerViewController.h"

#import "UIView+Additions.h"

//
#import "HYLMenuViewController.h"

// md5 加密
#import <CommonCrypto/CommonDigest.h>

#import "HYLTabBarController.h"
#import "AppDelegate.h"


#define     SCREEN_HEIGHT           [[UIScreen mainScreen]bounds].size.height
#define     SCREEN_WIDTH            [[UIScreen mainScreen]bounds].size.width
#define     ORIGINAL_MAX_WIDTH      640.0f

@interface HYLHaoYuLeListContainerViewController ()<ViewPagerDataSource, ViewPagerDelegate, HYLTitlePagerViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation HYLHaoYuLeListContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = self;
    self.delegate = self;
    self.manualLoadData = YES;
    self.currentIndex = 0;
    
    [self setupLeftMenuButton]; // 左侧视图
    
    self.navigationItem.titleView = self.pagingTitleView;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
   
    [self reloadData];
}

#pragma mark - 注册通知

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarTappedAction:)
                                                 name:@"DidTapStatusBar"
                                               object:nil];
}

#pragma mark - 注销通知

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidTapStatusBar" object:nil];
}

#pragma mark - 通知响应

- (void)statusBarTappedAction:(NSNotification*)notification {
    
    if (self.currentIndex == 0 && self.tuiJieListVC) {
        
        [self.tuiJieListVC.tableView setContentOffset:CGPointZero animated:YES];
        
    } else if (self.currentIndex == 1 && self.touTiaoListVC) {
        
        [self.touTiaoListVC.tableView setContentOffset:CGPointZero animated:YES];
        
    } else if (self.currentIndex == 2 && self.yuanChuangListVC) {
        
        [self.yuanChuangListVC.tableView setContentOffset:CGPointZero animated:YES];
    }
}

#pragma mark - 导航栏左侧按钮

-(void)setupLeftMenuButton
{
    UIImage *leftImage = [UIImage imageNamed:@"navi_left_item"];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
    [leftButton setImage:leftImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBarButtonItemTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

#pragma mark - 左侧图

- (void)leftBarButtonItemTouch:(UIButton *)sender
{
    HYLMenuViewController *leftMenuVC = [[HYLMenuViewController alloc] init];
    leftMenuVC.hidesBottomBarWhenPushed = YES;
    
//    leftMenuVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    HYLTabBarController *tabBarController = appDelegate.tabBarController;
    
    [tabBarController pushToViewController:leftMenuVC animated:YES];
}

#pragma mark - ViewPagerDataSource

- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager
{
    return 3;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index
{
    if (index == 0) {
        
        return [self createTuiJieVC];
        
    } else if (index == 1) {
        
        return [self createTouTiaoVC];
        
    } else {
        
        return [self createYuanChuangVC];
    }
}

#pragma mark - 创建 3个 控制器

- (UIViewController *)createTuiJieVC
{
    self.tuiJieListVC = [[HYLTuiJieViewController alloc] init];
    
    return self.tuiJieListVC;
}

- (UIViewController *)createTouTiaoVC
{
    self.touTiaoListVC = [[HYLTouTiaoViewController alloc] init];

    return self.touTiaoListVC;
}

- (UIViewController *)createYuanChuangVC
{
    self.yuanChuangListVC = [[HYLYuanChuangViewController alloc] init];
    
    return self.yuanChuangListVC;
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    self.currentIndex = index;
}

- (HYLTitlePagerView *)pagingTitleView
{
    if (!_pagingTitleView) {
        
        NSArray *titleArray = @[@"推介", @"头条", @"原创"];
        
        self.pagingTitleView = [[HYLTitlePagerView alloc] init];
        self.pagingTitleView.frame = CGRectMake(0, 0, 0, 40);
        self.pagingTitleView.font = [UIFont systemFontOfSize:18];
        
        self.pagingTitleView.width = [HYLTitlePagerView calculateTitleWidth:titleArray withFont:self.pagingTitleView.font];
        [self.pagingTitleView addObjects:titleArray];
        self.pagingTitleView.delegate = self;
    }
    
    return _pagingTitleView;
}

- (void)didTouchBWTitle:(NSUInteger)index
{
    UIPageViewControllerNavigationDirection direction;
    
    if (self.currentIndex == index) {
        
        return;
    }
    
    if (index > self.currentIndex) {
        
        direction = UIPageViewControllerNavigationDirectionForward;
        
    } else {
        
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    UIViewController *viewController = [self viewControllerAtIndex:index];
    
    if (viewController) {
        
        __weak typeof(self) weakself = self;
        
        [self.pageViewController setViewControllers:@[viewController] direction:direction animated:YES completion:^(BOOL finished) {
            
            weakself.currentIndex = index;
        }];
    }
}

- (void)setCurrentIndex:(NSInteger)index
{
    _currentIndex = index;
    [self.pagingTitleView adjustTitleViewByIndex:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    if (self.currentIndex != 0 && contentOffsetX <= SCREEN_WIDTH * 2) {
        
        contentOffsetX += SCREEN_WIDTH * self.currentIndex;
    }
    
    [self.pagingTitleView updatePageIndicatorPosition:contentOffsetX];
}

- (void)scrollEnabled:(BOOL)enabled
{
    self.scrollingLocked = !enabled;
    
    for (UIScrollView *view in self.pageViewController.view.subviews) {
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            
            view.scrollEnabled = enabled;
            
            view.bounces = enabled;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
