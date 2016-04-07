//
//  HYLTabBarViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLTabBarViewController.h"
#import "HYLHaoYuLeListContainerViewController.h"
#import "HYLHaoJingCaiListViewController.h"
#import "HYLHaoYinYueListContainerViewController.h"
#import "HYLZhiBoListViewController.h"

#define   kTabBarRGB(r, g, b)   [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]

@interface HYLTabBarViewController ()
{
    UINavigationController *_haoYuLeNC;
    UINavigationController *_haoXiChangNC;
    UINavigationController *_haoYinYueNC;
    UINavigationController *_zhiBoNC;
}

@end

@implementation HYLTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    
    [self setupTabBarStyle];
    [self setupTabBarItems];
}

#pragma mark - 工具栏样式

- (void)setupTabBarStyle
{
    [self setDelegate:self];
    
    self.tabBar.tintColor = kTabBarRGB(255, 199, 3);
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"tabBar_background"]];
}

#pragma mark - 工具栏按钮

- (void)setupTabBarItems
{
    // 好娱乐
    HYLHaoYuLeListContainerViewController *haoYuLeListContainerVC = [[HYLHaoYuLeListContainerViewController alloc] init];
    
    _haoYuLeNC = [[UINavigationController alloc] initWithRootViewController:haoYuLeListContainerVC];
    _haoYuLeNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"好娱乐"
                                                          image:[[UIImage imageNamed:@"tabBar_haoyule_unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                  selectedImage:[UIImage imageNamed:@"tabBar_haoyule_selected.png"]];
    
    // 好戏场
    HYLHaoJingCaiListViewController *haoXingChangListVC = [[HYLHaoJingCaiListViewController alloc] init];
    
    _haoXiChangNC = [[UINavigationController alloc] initWithRootViewController:haoXingChangListVC];
    _haoXiChangNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"好精彩"
                                                             image:[[UIImage imageNamed:@"tabBar_haoxichang_unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                     selectedImage:[UIImage imageNamed:@"tabBar_haoxichang_selected.png"]];
    
    // 好音乐
    HYLHaoYinYueListContainerViewController *haoYinYueListContainerVC = [[HYLHaoYinYueListContainerViewController alloc] init];
    
    _haoYinYueNC = [[UINavigationController alloc] initWithRootViewController:haoYinYueListContainerVC];
    _haoYinYueNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"好音乐"
                                                            image:[[UIImage imageNamed:@"tabBar_haoyinyue_unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                    selectedImage:[UIImage imageNamed:@"tabBar_haoyinyue_selected.png"]];
    
    // 直播
    HYLZhiBoListViewController *zhiBoListVC = [[HYLZhiBoListViewController alloc] init];
    
    _zhiBoNC = [[UINavigationController alloc] initWithRootViewController:zhiBoListVC];
    _zhiBoNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"直播"
                                                        image:[[UIImage imageNamed:@"tabBar_zhibo_unselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                selectedImage:[UIImage imageNamed:@"tabBar_zhibo_selected.png"]];
    
    NSArray *viewControllers = @[_haoYuLeNC, _haoXiChangNC, _haoYinYueNC, _zhiBoNC];
    [self setViewControllers:viewControllers];
}

#pragma mark - Delegate - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.25];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
                                  
    [self.view.window.layer addAnimation:animation forKey:@"fadeTransition"];
    
    return YES;
}

- (void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.selectedViewController;
        [navigationController pushViewController:viewController animated:animated];
    }
}

- (void)presentToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^ __nullable)(void))completion
{
    if([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)self.selectedViewController;
        [navigationController presentViewController:viewController animated:animated completion:completion];
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
