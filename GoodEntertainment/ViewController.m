//
//  ViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/7/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
//    UIView *blackCover;
//    
//    CGFloat distance;
//    CGFloat FullDistance;
//    CGFloat Proportion;
//    
//    CGPoint centerOfLeftViewAtBeginning;
//    CGFloat proportionOfLeftView;
//    CGFloat distanceOfLeftView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    distance = 0;
//    FullDistance = 0.78;
//    Proportion = 0.77;
//    
//    proportionOfLeftView = 1;
//    distanceOfLeftView = 50;
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBG"]];
//    imageView.frame = [UIScreen mainScreen].bounds;
//    [self.view addSubview:imageView];
//    
//    _leftViewController = [[HYLMenuViewController alloc] init];
//    
//    if ( [UIScreen mainScreen].bounds.size.width > 320) {
//        proportionOfLeftView = [UIScreen mainScreen].bounds.size.width / 320;
//        distanceOfLeftView += ([UIScreen mainScreen].bounds.size.width - 320) * FullDistance / 2;
//    }
//    _leftViewController.view.center = CGPointMake(_leftViewController.view.center.x - 50, _leftViewController.view.center.y);
//    _leftViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
//    
//    
//    // 动画参数初始化
//    centerOfLeftViewAtBeginning = _leftViewController.view.center;
//    
//    // 把侧滑菜单视图加入根容器
//    [self.view addSubview:_leftViewController.view];
//    
//    // 在侧滑菜单之上增加黑色遮罩层，目的是实现视差特效
//    blackCover = [[UIView alloc] initWithFrame:CGRectOffset(self.view.frame, 0, 0)];
//    blackCover.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:blackCover];
//    
//    
//    _mainView = [[UIView alloc] initWithFrame:self.view.frame];
//    
//    UIView *tabBarView = _mainTabBarController.view;
//    [_mainView addSubview:tabBarView];
//    
//    _homeNavigationController = [[UINavigationController alloc] init];
//    
//    _homeViewController = (HYLHaoYuLeListContainerViewController *)_homeNavigationController.viewControllers.firstObject;
//    [tabBarView addSubview:_homeViewController.view];
//    [tabBarView addSubview:_homeViewController.navigationController.view];
//    [tabBarView bringSubviewToFront:_mainTabBarController.tabBar];
//    
//    
//    [self.view addSubview:_mainView];
//    
//    //
//    _homeViewController.navigationItem.leftBarButtonItem.action = @selector(showLeft);
//    
//    
//    //
////    UIPanGestureRecognizer *panGesture = _homeViewController.panGesture;
////    [panGesture addTarget:self action:@selector(pan:)];
////    [_mainView addGestureRecognizer:panGesture];
}
//
//// 展示左视图
//- (void)showLeft {
//    // 给首页 加入 点击自动关闭侧滑菜单功能
//    [_mainView addGestureRecognizer:_tapGesture];
//    
//    // 计算距离，执行菜单自动滑动动画
//    distance = self.view.center.x * (FullDistance*2 + Proportion - 1);
//
//    [self doTheAnimateWithProportion:Proportion showWhat:@"left"];
//
//    [_homeNavigationController popToRootViewControllerAnimated:YES];
//}
//
//// 展示主视图
//- (void)showHome {
//    
//    // 从首页 删除 点击自动关闭侧滑菜单功能
//    [_mainView removeGestureRecognizer:_tapGesture];
//    
//    // 计算距离，执行菜单自动滑动动画
//    distance = 0;
//    [self doTheAnimateWithProportion:1 showWhat:@"home"];
//}
//
//- (void)doTheAnimateWithProportion:(CGFloat)proportion showWhat:(NSString *)what
//{
//    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        
//        // 移动首页中心
//        _mainView.center = CGPointMake(self.view.center.x + distance, self.view.center.y);
//        // 缩放首页
//        _mainView.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
//        
//        if ([what  isEqual: @"left"]) {
//            // 移动左侧菜单的中心
//            self.leftViewController.view.center = CGPointMake(centerOfLeftViewAtBeginning.x + distanceOfLeftView, self.leftViewController.view.center.y);
//            // 缩放左侧菜单
//            self.leftViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportionOfLeftView, proportionOfLeftView);
//        }
//        // 改变黑色遮罩层的透明度，实现视差效果
//        blackCover.alpha = [what  isEqual: @"home"] ? 1 : 0;
//        
//        // 为了演示效果，在右侧菜单划出时隐藏漏出的左侧菜单，并无实际意义
//        self.leftViewController.view.alpha = [what  isEqual: @"right"] ? 0 : 1;
//        
//    } completion:nil];
//
//}
//
//
//
//// 响应 UIPanGestureRecognizer 事件
//- (void)pan:(UIPanGestureRecognizer *)recongnizer {
//    
//    CGFloat x = [recongnizer translationInView:self.view].x;
//    CGFloat trueDistance = distance + x; // 实时距离
//    CGFloat trueProportion = trueDistance / ([UIScreen mainScreen].bounds.size.width*FullDistance);
//    
//    // 如果 UIPanGestureRecognizer 结束，则激活自动停靠
//    if (recongnizer.state == UIGestureRecognizerStateEnded) {
//        
//        if (trueDistance > [UIScreen mainScreen].bounds.size.width * (Proportion / 3)) {
//            
//            [self showLeft];
//            
//        } else if (trueDistance < [UIScreen mainScreen].bounds.size.width * -(Proportion / 3)) {
//            
//        } else {
//            
//            [self showHome];
//        }
//        
//        return;
//    }
//    
//    // 计算缩放比例
//    CGFloat proportion = recongnizer.view.frame.origin.x >= 0 ? -1 : 1;
//    
//    proportion *= trueDistance / [UIScreen mainScreen].bounds.size.width;
//    proportion *= 1 - Proportion;
//    proportion /= FullDistance + Proportion/2 - 0.5;
//    proportion += 1;
//    
//    if (proportion <= Proportion) { // 若比例已经达到最小，则不再继续动画
//        return;
//    }
//    // 执行视差特效
//    blackCover.alpha = (proportion - Proportion) / (1 - Proportion);
//    // 执行平移和缩放动画
//    recongnizer.view.center = CGPointMake(self.view.center.x + trueDistance, self.view.center.y);
//    recongnizer.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
//    
//    // 执行左视图动画
//    CGFloat pro = 0.8 + (proportionOfLeftView - 0.8) * trueProportion;
//    _leftViewController.view.center = CGPointMake(centerOfLeftViewAtBeginning.x + distanceOfLeftView * trueProportion, centerOfLeftViewAtBeginning.y - (proportionOfLeftView - 1) * _leftViewController.view.frame.size.height * trueProportion / 2 );
//    _leftViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, pro, pro);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
