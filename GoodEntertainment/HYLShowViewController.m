//
//  HYLShowViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/29/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLShowViewController.h"

// 签名
#import "HYLGetSignature.h"

// 时间戳
#import "HYLGetTimestamp.h"

// api 接口
#import "HaoYuLeNetworkInterface.h"

// 网络请求
#import <AFNetworking.h>

@interface HYLShowViewController ()

@end

@implementation HYLShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _page = 1;
    
    [self hylShowApiRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hylShowApiRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:[NSString stringWithFormat:@"%ld", (long)_page] forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kShowListURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"show: %@", reponse);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        
    }];
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
