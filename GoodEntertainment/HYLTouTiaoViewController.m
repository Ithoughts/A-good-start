//
//  HYLTouTiaoViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/23/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLTouTiaoViewController.h"

#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import <AFNetworking.h>
#import "HaoYuLeNetworkInterface.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "HYLZhiBoCell.h"
#import "HYLZhiBoListModel.h"

#import "HYLTouTiaoDetailViewController.h"

#import "HYLHaoYuLeListContainerViewController.h"

//
#import "HYLTabBarViewController.h"
#import "AppDelegate.h"


@interface HYLTouTiaoViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
}


@end

@implementation HYLTouTiaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.page = 1;
    [self hylTouTiaoApiRequest];
    [self prepareTouTiaoTableView];
}

#pragma mark - 表格视图

- (void)prepareTouTiaoTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:_tableView];
}

#pragma mark - 网络请求

- (void)hylTouTiaoApiRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:[NSString stringWithFormat:@"%ld",self.page] forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kTouTiaoURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject
//                                                  encoding:NSUTF8StringEncoding];
//        NSLog(@"头条: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
//        NSLog(@"status: %@", responseDic[@"status"]);
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *firstDataDic = responseDic[@"data"];
            
            NSArray *secondData = firstDataDic[@"data"];
            
            _dataArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dic in secondData) {
                
                HYLZhiBoListModel *model = [[HYLZhiBoListModel alloc] initWithDictionary:dic];
                [_dataArray addObject:model];
            }
            
            [_tableView reloadData];
            
        } else {
            
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求失败"
//                                                                        message:nil
//                                                                       delegate:nil
//                                                              cancelButtonTitle:@"OK"
//                                                              otherButtonTitles:nil, nil];
//                        [alert show];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error:\n%@", error);
        
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"XiChangCell";
    
    HYLZhiBoListModel *model = _dataArray[indexPath.row];
    
    HYLZhiBoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[HYLZhiBoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.title.text = model.title;
    cell.updated_at.text = model.updated_at;
    [cell.videoImage sd_setImageWithURL:[NSURL URLWithString:model.video_info.cover_url] placeholderImage:nil];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 220.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HYLZhiBoListModel *model = _dataArray[indexPath.row];
    NSInteger videoId = model.videoId;
    
    HYLTouTiaoDetailViewController *touTiaoDetailVC = [[HYLTouTiaoDetailViewController alloc] init];
    touTiaoDetailVC.videoId = [NSString stringWithFormat:@"%ld", (long)videoId];
    
    HYLTabBarViewController *tabVC = [(AppDelegate *)[[UIApplication sharedApplication] delegate] tabBarViewController];
    [tabVC pushToViewController:touTiaoDetailVC animated:YES];
    
    NSLog(@"video id :%@", touTiaoDetailVC.videoId);
    
    [self hylTouTiaoDetailInfoApiRequest:touTiaoDetailVC.videoId];
}

#pragma mark - 网络请求

- (void)hylTouTiaoDetailInfoApiRequest:(NSString *)videoId
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:videoId forKey:@"id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kShiPinDetailURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSString *reponse = [[NSString alloc] initWithData:responseObject
                                                  encoding:NSUTF8StringEncoding];
        NSLog(@"头条详情: \n%@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
//        NSLog(@"status: %@", responseDic[@"status"]);
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
//            NSDictionary *firstDataDic = responseDic[@"data"];
//
//            NSArray *secondData = firstDataDic[@"data"];
//
//            _dataArray = [[NSMutableArray alloc] init];
//
//            for (NSDictionary *dic in secondData) {
//
//                HYLZhiBoListModel *model = [[HYLZhiBoListModel alloc] initWithDictionary:dic];
//                [_dataArray addObject:model];
//            }
//
//            [_tableView reloadData];
            
        } else {
            
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请求失败"
//                                                                        message:nil
//                                                                       delegate:nil
//                                                              cancelButtonTitle:@"OK"
//                                                              otherButtonTitles:nil, nil];
//                        [alert show];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error:\n%@", error);
        
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
