//
//  AppDelegate.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/7/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYLTabBarController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// 重要
@property (strong, nonatomic) HYLTabBarController *tabBarController;

@end

