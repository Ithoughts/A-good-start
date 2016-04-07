//
//  HYLHaoYinYueListContainerViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLHaoYinYueListContainerViewController.h"
#import "HYLHaoYinYueBaseListViewController.h"
#import "HYLTitlePagerView.h"

#import "UIView+Additions.h"
#import <MMDrawerBarButtonItem.h>
#import <UIViewController+MMDrawerController.h>

#import "HYLMVViewController.h"
#import "HYLShowViewController.h"
#import "HYLBangDanViewController.h"

#define     SCREEN_HEIGHT           [[UIScreen mainScreen]bounds].size.height
#define     SCREEN_WIDTH            [[UIScreen mainScreen]bounds].size.width
#define     ORIGINAL_MAX_WIDTH      640.0f

@interface HYLHaoYinYueListContainerViewController ()<ViewPagerDataSource, ViewPagerDelegate, HYLTitlePagerViewDelegate>

@property (nonatomic, strong) HYLShowViewController *showListVC;
@property (nonatomic, strong) HYLMVViewController *mvListVC;
@property (nonatomic, strong) HYLBangDanViewController *bangDanListVC;
@property (nonatomic, strong) HYLTitlePagerView *pagingTitleView;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation HYLHaoYinYueListContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self setupLeftMenuButton];
    self.navigationItem.titleView = self.pagingTitleView;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    
    self.dataSource = self;
    self.delegate = self;
//    self.manualLoadData = YES;
    self.currentIndex = 0;
    
    [self reloadData];
}

#pragma mark - 导航栏左侧按钮

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}
#pragma mark - Button Handlers
- (void)leftDrawerButtonPress:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - 注册通知
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarTappedAction:)
                                                 name:@"DidTapStatusBar"
                                               object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidTapStatusBar" object:nil];
}
- (void)statusBarTappedAction:(NSNotification*)notification {
    if (self.currentIndex == 0 && self.showListVC) {
        [self.showListVC.tableView setContentOffset:CGPointZero animated:YES];
    } else if (self.currentIndex == 1 && self.mvListVC) {
        [self.mvListVC.tableView setContentOffset:CGPointZero animated:YES];
    } else if (self.currentIndex == 2 && self.bangDanListVC) {
        [self.bangDanListVC.tableView setContentOffset:CGPointZero animated:YES];
    }
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return 3;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    if (index == 0) {
        return [self createShowVC];
    } else if (index == 1) {
        return [self createMVVC];
    } else {
        return [self createBangDanVC];
    }
}
- (UIViewController *)createShowVC {
    self.showListVC = [[HYLShowViewController alloc] init];
    self.showListVC.haoYinYueListType = HaoYinYueListTypeShow;
    self.showListVC.view.backgroundColor = [UIColor redColor];
    self.showListVC.isFromHaoYinYueContainer = YES;
    
    return self.showListVC;
}

- (UIViewController *)createMVVC {
    self.mvListVC = [[HYLMVViewController alloc] init];
    self.mvListVC.view.backgroundColor = [UIColor whiteColor];
    self.mvListVC.haoYinYueListType = HaoYinYueListTypeMV;
    self.mvListVC.isFromHaoYinYueContainer = YES;
    
    return self.mvListVC;
}

- (UIViewController *)createBangDanVC {
    self.bangDanListVC = [[HYLBangDanViewController alloc] init];
    self.bangDanListVC.view.backgroundColor = [UIColor blueColor];
    self.bangDanListVC.haoYinYueListType = HaoYinYueListTypeBangDan;
    self.bangDanListVC.isFromHaoYinYueContainer = YES;
    
    return self.bangDanListVC;
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index {
    self.currentIndex = index;
}

- (HYLTitlePagerView *)pagingTitleView {
    if (!_pagingTitleView) {
        self.pagingTitleView = [[HYLTitlePagerView alloc] init];
        self.pagingTitleView.frame = CGRectMake(0, 0, 0, 40);
        self.pagingTitleView.font = [UIFont systemFontOfSize:18];
        NSArray *titleArray = @[@"Show", @"MV", @"榜单"];
        self.pagingTitleView.width = [HYLTitlePagerView calculateTitleWidth:titleArray withFont:self.pagingTitleView.font];
        [self.pagingTitleView addObjects:titleArray];
        self.pagingTitleView.delegate = self;
    }
    
    return _pagingTitleView;
}

- (void)didTouchBWTitle:(NSUInteger)index {
    //  NSInteger index;
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

- (void)didReceiveMemoryWarning {
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
