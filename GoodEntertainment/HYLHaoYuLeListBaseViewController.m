//
//  HYLHaoYuLeListViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLHaoYuLeListBaseViewController.h"

// 时间戳
#import "HYLGetTimestamp.h"

// md5 加密
#import "HYLGetSignature.h"

// api
#import "HaoYuLeNetworkInterface.h"

//网络请求
#import <AFNetworking.h>

@interface HYLHaoYuLeListBaseViewController ()


@end

@implementation HYLHaoYuLeListBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    _page = 1; // 默认为1
//    [self haoYuLeApiRequest:_haoYuLeListType];
}

#pragma mark - 网络请求

//- (void)haoYuLeApiRequest:(HaoYuLeListType)haoYuLeListType
//{

//    switch (haoYuLeListType) {
//        case HaoYuLeListTypeTouTiao:
//            _url = kTouTiaoURL;
//            break;
//        case HaoYuLeListTypeZhuanFang:
//            _url = kZhuanFangURL;
//            break;
//        case HaoYuLeListTypeYuanChuang:
//            _url = kChongWenURL;
//            break;
//            
//        default:
//            break;
//    }
    
//    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//    
//    NSString *timestamp = [HYLGetTimestamp getTimestampString];
//    NSString *signature = [HYLGetSignature getSignature:timestamp];
//    NSString *pageString = [NSString stringWithFormat:@"%ld", (long)_page];
//    
//    [dictionary setValue:timestamp forKey:@"time"];
//    [dictionary setValue:signature forKey:@"sign"];
//    [dictionary setValue:pageString forKey:@"page"];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    [manager POST:kTouTiaoURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"reponseObject: \n%@", reponse);
//        
//    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//        
//        NSLog(@"error:\n%@", error);
//        
//    }];
//}

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
