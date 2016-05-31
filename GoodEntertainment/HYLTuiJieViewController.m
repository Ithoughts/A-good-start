//
//  HYLZhuanFangViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/23/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLTuiJieViewController.h"

// model
#import "HYLZhiBoListModel.h"

// view
#import "HYLZhiBoCell.h"

// 重要
#import "HYLTabBarController.h"
#import "AppDelegate.h"

// 详情页
#import "HYLHaoYuLeCommonDetailViewController.h"

#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import <AFNetworking.h>
#import "HaoYuLeNetworkInterface.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <MJRefresh.h>

@interface HYLTuiJieViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_dataArray;
}

@end

@implementation HYLTuiJieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.page = 1;
    _dataArray = [[NSMutableArray alloc] init];
    
    [self HYLTuiJieApiRequest];
    [self prepareTuiJieTableView];
}
#pragma mark - 表格视图

- (void)prepareTuiJieTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 49 - 64)
                                              style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    
//    self.tableView.mj_footer.hidden = YES;

}

#pragma mark - 下拉刷新

- (void)loadNewData
{
    self.page = 1;
    
    [_dataArray removeAllObjects];
    
    [self HYLTuiJieApiRequest];
}

#pragma mark - 上拉加载更多

- (void)loadMoreData
{
    self.page ++;
    
    [self HYLTuiJieApiRequest];
}

#pragma mark - 网络请求

- (void)HYLTuiJieApiRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:[NSString stringWithFormat:@"%ld", (long)(self.page)] forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kTuiJieURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject
//                                                  encoding:NSUTF8StringEncoding];
//        NSLog(@"推介:%@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
//        NSLog(@"status: %@", responseDic[@"status"]);
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *firstDataDic = responseDic[@"data"];
            
            NSArray *secondData = firstDataDic[@"data"];
            
            
            if (secondData.count > 0) {
                
                for (NSDictionary *dic in secondData) {
                    
                    HYLZhiBoListModel *model = [[HYLZhiBoListModel alloc] initWithDictionary:dic];
                    [_dataArray addObject:model];
                }
                
//                [self prepareTuiJieTableView];
                
                // 刷新表格
                [self.tableView reloadData];
                
                // 拿到当前的下拉刷新控件，结束刷新状态
                [self.tableView.mj_header endRefreshing];
                
                // 拿到当前的上拉刷新控件，结束刷新状态
                [self.tableView.mj_footer endRefreshing];
                
            } else {
                
//                [self prepareTuiJieTableView];
                
                // 刷新表格
                [self.tableView reloadData];
                
                // 拿到当前的上拉刷新控件，变为没有更多数据的状态
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                
                // 隐藏当前的上拉刷新控件
                self.tableView.mj_footer.hidden = YES;
            }
            
        } else {
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TuiJieCell";
    
    HYLZhiBoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[HYLZhiBoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (_dataArray.count > indexPath.row) {
        
        HYLZhiBoListModel *model = _dataArray[indexPath.row];
        
        cell.title.text = model.title;
        cell.updated_at.text = model.updated_at;
        
        CGFloat imageHeight = model.video_info.cover_height.floatValue;
        CGFloat imageWidth = model.video_info.cover_width.floatValue;
        CGFloat trueHeight = [UIScreen mainScreen].bounds.size.width * (imageHeight/imageWidth);
        
        cell.videoImage.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, trueHeight);
        cell.title.center = CGPointMake(cell.videoImage.frame.size.width*0.5, cell.videoImage.frame.size.height*0.5-25);
        cell.updated_at.center = CGPointMake(cell.videoImage.frame.size.width*0.5, cell.videoImage.frame.size.height*0.5);
        [cell.videoImage sd_setImageWithURL:[NSURL URLWithString:model.video_info.cover_url] placeholderImage:[UIImage imageNamed:@"defaultload"]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat imageHeight;
    CGFloat imageWidth;
    
    if (_dataArray.count > indexPath.row) {
    
        HYLZhiBoListModel *model = _dataArray[indexPath.row];
        
        imageHeight = model.video_info.cover_height.floatValue;
        imageWidth = model.video_info.cover_width.floatValue;
    }
    
    return [HYLZhiBoCell getImageViewWidth:imageWidth height:imageHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HYLZhiBoListModel *model = _dataArray[indexPath.row];
    NSInteger videoId = model.videoId;
    
    CGFloat imageHeight = model.video_info.cover_height.floatValue;
    CGFloat imageWidth  = model.video_info.cover_width.floatValue;
    
    HYLHaoYuLeCommonDetailViewController *touTiaoDetailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HYLTouTiaoDetailViewController"];
    touTiaoDetailVC.videoId = [NSString stringWithFormat:@"%ld", (long)videoId];
    
    touTiaoDetailVC.imageWidth = imageWidth;
    touTiaoDetailVC.imageHeight = imageHeight;
    
    touTiaoDetailVC.hidesBottomBarWhenPushed = YES;
    
    HYLTabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController];
    [tabBarController pushToViewController:touTiaoDetailVC animated:NO];
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
