//
//  HYLTabBarViewController.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYLTabBarViewController : UITabBarController <UITabBarControllerDelegate>

- (void)setupTabBarItems;
- (void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)presentToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

@end
