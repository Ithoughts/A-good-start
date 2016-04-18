//
//  HYLHaoYuLeListContainerViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLHaoYuLeListContainerViewController.h"

//
#import "UIView+Additions.h"


//#import <MMDrawerBarButtonItem.h>
//#import <UIViewController+MMDrawerController.h>

// 左侧视图控制器
#import "HYLMyCollectionViewController.h"
#import "HYLEditProfileViewController.h"
#import "HYLSettingViewController.h"
#import "HYLSignInViewController.h"

// test
#import "HYLHaoYuLeCommonDetailViewController.h"

// md5 加密
#import <CommonCrypto/CommonDigest.h>

#define     SCREEN_HEIGHT           [[UIScreen mainScreen]bounds].size.height
#define     SCREEN_WIDTH            [[UIScreen mainScreen]bounds].size.width
#define     ORIGINAL_MAX_WIDTH      640.0f

@interface HYLHaoYuLeListContainerViewController ()<ViewPagerDataSource, ViewPagerDelegate, HYLTitlePagerViewDelegate, UIGestureRecognizerDelegate>
{
    UIView *_backgroundView;
    UIView *_topestView;
    UIImageView *_footerBackgroundImageView;
    
    // 按钮
    UIButton *_collectionButton;
    UIButton *_edictButton;
    UIButton *_settingButton;
    UIButton *_logoutButton;
}

@end

@implementation HYLHaoYuLeListContainerViewController


//#pragma mark - Button Handlers
//-(void)leftDrawerButtonPress:(id)sender {
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = self;
    self.delegate = self;
    self.manualLoadData = YES;
    self.currentIndex = 0;
    
//    [self setupLeftMenuButton];
    
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
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidTapStatusBar" object:nil];
}
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
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 35, 40);
    [leftButton setImage:[UIImage imageNamed:@"navi_left_item"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBarButtonItemTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
//    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
//    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
}

//-(void)leftDrawerButtonPress:(id)sender {
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//}

- (void)leftBarButtonItemTouch:(UIButton *)sender
{
//    NSLog(@"创建左侧视图");
    [self setupLeftView];
}

#pragma mark - 创建左侧视图

- (void)setupLeftView
{
    // bgView
    _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _backgroundView.backgroundColor = [UIColor clearColor];
    
    _topestView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width * 4/5.0, [UIScreen mainScreen].bounds.size.height - 20)];
    _topestView.backgroundColor = [UIColor whiteColor];
    [_backgroundView addSubview:_topestView];
    
    [self prepareTopestViewContentView];
    
    // 手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    tap.delegate = self;
    [_topestView addGestureRecognizer:tap];
    [self.view addSubview:_topestView];
    
}

#pragma mark - 创建左侧内容

- (void)prepareTopestViewContentView
{
    // 头视图
    [self prepareTopestViewHeaderView];
    
    // 脚视图
    [self prepareTopestViewFooterView];
}

#pragma mark - 头视图

- (void)prepareTopestViewHeaderView
{
    CGFloat topestViewWidth = _topestView.frame.size.width;
    CGFloat center = topestViewWidth*0.5;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 20, topestViewWidth, 200)];
    header.backgroundColor = [UIColor whiteColor];
    [_topestView addSubview:header];
    
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(center - 50, 30, 100, 100)];
    avatar.image = [UIImage imageNamed:@"defaultImage"];
    [header addSubview:avatar];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(center - 90, avatar.frame.origin.y + avatar.frame.size.height + 5, 180, 30)];
    nameLabel.text = @"小陈同志";
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:18.0f];
    [header addSubview:nameLabel];
    
    UILabel *sayingLabel = [[UILabel alloc] initWithFrame:CGRectMake(center - 90, nameLabel.frame.origin.y + nameLabel.frame.size.height, 180, 30)];
    sayingLabel.text = @"人生旅途";
    sayingLabel.textColor = [UIColor lightGrayColor];
    sayingLabel.textAlignment = NSTextAlignmentCenter;
    sayingLabel.font = [UIFont systemFontOfSize:15.0f];
    [header addSubview:sayingLabel];
}

#pragma mark - 脚视图
- (void)prepareTopestViewFooterView
{
    _footerBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, _topestView.frame.size.width, _topestView.frame.size.height-200)];
//    _footerBackgroundImageView.image = [UIImage imageNamed:@"personalPageBg"];
    _footerBackgroundImageView.userInteractionEnabled = YES;
    [_topestView addSubview:_footerBackgroundImageView];
    
//    _collectionButton = [self createButtonWithCGRECT:CGRectMake(_topestView.frame.size.width * 0.5 - 60, 5, 120, 30)
//                                                 tag:100
//                                               image:[UIImage imageNamed:@"myCollectionIcon"]
//                                               title:@"我的收藏"];
    
    _collectionButton = [self createButtonWithCGRECT:CGRectMake(_topestView.frame.size.width * 0.5 - 60, 5, 120, 30)
                                                 tag:100
                                               image:nil
                                               title:nil];
    
    [_footerBackgroundImageView addSubview:_collectionButton];
    
    [self createLineViewWithCGRECT:CGRectMake(0, _collectionButton.frame.size.height + _collectionButton.frame.origin.y + 5, _topestView.frame.size.width, 1)];
    
    
    _edictButton = [self createButtonWithCGRECT:CGRectMake(_topestView.frame.size.width * 0.5 - 60, _collectionButton.frame.origin.y + _collectionButton.frame.size.height + 5 + 5, 120, 30)
                    
                                                 tag:101
                                               image:[UIImage imageNamed:@"changeInfoIcon"]
                                               title:@"修改资料"];
    
    [_footerBackgroundImageView addSubview:_edictButton];
    
     [self createLineViewWithCGRECT:CGRectMake(0, _edictButton.frame.size.height + _edictButton.frame.origin.y + 5, _topestView.frame.size.width, 1)];
    
    
    
    _settingButton = [self createButtonWithCGRECT:CGRectMake(_topestView.frame.size.width * 0.5 - 60, _edictButton.frame.origin.y + _edictButton.frame.size.height + 5 + 5, 120, 30)
                                              tag:102
                                            image:[UIImage imageNamed:@"settingIcon"]
                                            title:@"设置"];
    
    [_footerBackgroundImageView addSubview:_settingButton];
    
     [self createLineViewWithCGRECT:CGRectMake(0, _settingButton.frame.size.height + _settingButton.frame.origin.y + 5, _topestView.frame.size.width, 1)];
    
    
    
    _logoutButton = [self createButtonWithCGRECT:CGRectMake(_topestView.frame.size.width * 0.5 - 60, _settingButton.frame.origin.y + _settingButton.frame.size.height + 5 + 5, 120, 30)
                                             tag:103
                                           image:[UIImage imageNamed:@"logoutIcon"]
                                           title:@"退出登录"];
    
    [_footerBackgroundImageView addSubview:_logoutButton];
    
    [self createLineViewWithCGRECT:CGRectMake(0, _logoutButton.frame.size.height + _logoutButton.frame.origin.y + 5, _topestView.frame.size.width, 1)];
}

#pragma mark - 创建 按钮 共用方法

- (UIButton *)createButtonWithCGRECT:(CGRect)rect tag:(NSUInteger)tag image:(UIImage *)image title:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect;
    button.tag = tag;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [button setImage:image forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0.0, button.frame.size.width-image.size.width , 0.0, 0.0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0 , 0.0, image.size.width);
    
    [button addTarget:self action:@selector(buttonsTap:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}
#pragma mark - 手势响应
- (void)tapHandle:(UIGestureRecognizer *)sender
{
    [_topestView removeFromSuperview];
}

#pragma mark - 按钮响应
- (void)buttonsTap:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
        {
//            HYLMyCollectionViewController *collectionVC = [[HYLMyCollectionViewController alloc] init];
//            [self.navigationController pushViewController:collectionVC animated:YES];
            
            HYLHaoYuLeCommonDetailViewController *test = [[HYLHaoYuLeCommonDetailViewController alloc] init];
            [self.navigationController pushViewController:test animated:YES];
        }
            break;
        case 101:
        {
            HYLEditProfileViewController *editProfileVC = [[HYLEditProfileViewController alloc] init];
            [self.navigationController pushViewController:editProfileVC animated:YES];
        
        }
            break;
        case 102:
        {
            HYLSettingViewController *setUpVC = [[HYLSettingViewController alloc] init];
            [self.navigationController pushViewController:setUpVC animated:YES];

        }
            break;
        case 103:
        {
            HYLSignInViewController *signInVC = [[HYLSignInViewController alloc] init];

            [self.navigationController pushViewController:signInVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 创建线条视图

- (void)createLineViewWithCGRECT:(CGRect)rect
{
    UIView *lineView = [[UIView alloc] initWithFrame:rect];
    lineView.backgroundColor = [UIColor whiteColor];
    
    [_footerBackgroundImageView addSubview:lineView];
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
//    self.zhuanFangListVC.haoYuLeListType = HaoYuLeListTypeZhuanFang;
//    self.zhuanFangListVC.isFromHaoYuLeContainer = YES;
    
    return self.tuiJieListVC;
}

- (UIViewController *)createTouTiaoVC
{
    self.touTiaoListVC = [[HYLTouTiaoViewController alloc] init];
//    self.touTiaoListVC.haoYuLeListType = HaoYuLeListTypeTouTiao;
//    self.touTiaoListVC.isFromHaoYuLeContainer = YES;

    return self.touTiaoListVC;
}

- (UIViewController *)createYuanChuangVC
{
    self.yuanChuangListVC = [[HYLYuanChuangViewController alloc] init];
//    self.yuanChuangListVC.haoYuLeListType = HaoYuLeListTypeYuanChuang;
//    self.yuanChuangListVC.isFromHaoYuLeContainer = YES;
    
    return self.yuanChuangListVC;
}

- (void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    self.currentIndex = index;
}

- (HYLTitlePagerView *)pagingTitleView
{
    if (!_pagingTitleView) {
        self.pagingTitleView = [[HYLTitlePagerView alloc] init];
        self.pagingTitleView.frame = CGRectMake(0, 0, 0, 40);
        self.pagingTitleView.font = [UIFont systemFontOfSize:18];
        NSArray *titleArray = @[@"推介", @"头条", @"原创"];
        self.pagingTitleView.width = [HYLTitlePagerView calculateTitleWidth:titleArray withFont:self.pagingTitleView.font];
        [self.pagingTitleView addObjects:titleArray];
        self.pagingTitleView.delegate = self;
    }
    return _pagingTitleView;
}

- (void)didTouchBWTitle:(NSUInteger)index
{
    // NSInteger index;
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
