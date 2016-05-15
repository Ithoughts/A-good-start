//
//  HYLCommentListViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 5/11/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLCommentListViewController.h"

#import <AFNetworking.h>
#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import "HaoYuLeNetworkInterface.h"

@interface HYLCommentListViewController ()
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
}

@end

@implementation HYLCommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    _screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [self prepareNavigationBar];
    [self HYLCommentListRequest];
}

- (void)prepareNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UINavigationItem *navItem = self.navigationItem;
    
    // left bar button item
    UIImage  *leftImage  = [UIImage imageNamed:@"backIcon"];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
    [leftButton setImage:leftImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    navItem.leftBarButtonItem = left;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    titleLabel.text = @"评论";
    titleLabel.font = [UIFont systemFontOfSize:20.0f];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    navItem.titleView = titleLabel;
}

#pragma mark - 返回

- (void)goBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 网络请求

- (void)HYLCommentListRequest
{
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setValue:timestamp      forKey:@"time"];
    [dictionary setValue:signature      forKey:@"sign"];
    [dictionary setValue:self.videoId   forKey:@"id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kGetVideoCommentURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"评论列表: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            
        } else {
            
            UIImage *backgroundImage = [UIImage imageNamed:@"tip"];
            
            // 标签
            UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - 60, self.view.frame.size.height * 0.5 - backgroundImage.size.height*0.5-30, 120, 30)];
            tipLabel.text = @"暂无评论";
            tipLabel.font = [UIFont systemFontOfSize:16.0f];
            tipLabel.textColor = [UIColor blackColor];
            tipLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:tipLabel];
            
            // 背景
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
            imageView.image = backgroundImage;
            imageView.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
            [self.view addSubview:imageView];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
//        NSLog(@"error: %@", error);
        
    }];
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
