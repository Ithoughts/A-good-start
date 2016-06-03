//
//  HYLBangDanViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/29/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLBangDanViewController.h"

#import "HYLYinYueDetailCommonViewController.h"

#import "AppDelegate.h"
#import "HYLTabBarController.h"

//#import "AFNetworking.h"
#import <AFNetworking/AFNetworking.h>

// 时间戳
#import "HYLGetTimestamp.h"

// 签名
#import "HYLGetSignature.h"

// api 接口
#import "HaoYuLeNetworkInterface.h"

// 网络图片
#import <SDWebImage/UIImageView+WebCache.h>

// 自定义 cell
#import "HYLZhiBoCell.h"

// model
#import "HYLBangDanModel.h"

//#import "MJRefresh.h"
#import <MJRefresh/MJRefresh.h>


@interface HYLBangDanViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_dataArray;
    
    NSArray *_imageArray;
}

@end

@implementation HYLBangDanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageArray = @[@"one", @"two", @"three", @"four", @"five", @"six", @"seven", @"eight", @"nine"];
    
    _page = 1;
    _dataArray = [[NSMutableArray alloc] init];
    
    [self hylBangDanApiRequest];
    [self prepareBangDanTableView];
}

- (void)prepareBangDanTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 49 - 64)
                                              style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = YES;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
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
}

#pragma mark - 下拉刷新

- (void)loadNewData
{
    _page = 1;
    
    [_dataArray removeAllObjects];
    
    [self hylBangDanApiRequest];
}

#pragma mark - 上拉加载更多

- (void)loadMoreData
{
    _page ++;
    
    [self hylBangDanApiRequest];
}

- (void)hylBangDanApiRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:[NSString stringWithFormat:@"%ld", (long)_page] forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kBangDanListURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"榜单: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *firstDataDic = responseDic[@"data"];
            
            NSArray *secondData = firstDataDic[@"data"];
            
            if (secondData.count > 0) {
                
                for (NSDictionary *dic in secondData) {
                    
                    BangDanDetailInfoData *model = [[BangDanDetailInfoData alloc] initWithDictionary:dic];
                    [_dataArray addObject:model];
                }
                
                // 刷新表格
                [self.tableView reloadData];
                
                // 拿到当前的下拉刷新控件，结束刷新状态
                [self.tableView.mj_header endRefreshing];
                
                // 拿到当前的上拉刷新控件，结束刷新状态
                [self.tableView.mj_footer endRefreshing];
                
            } else {
            
                // 刷新表格
                [self.tableView reloadData];
                
                // 拿到当前的上拉刷新控件，变为没有更多数据的状态
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                
                // 隐藏当前的上拉刷新控件
                self.tableView.mj_footer.hidden = YES;
            }
            
        } else {
            
            // 拿到当前的下拉刷新控件，结束刷新状态
            [self.tableView.mj_header endRefreshing];
            
            // 拿到当前的上拉刷新控件，结束刷新状态
            [self.tableView.mj_footer endRefreshing];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error:%@", error);
        
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.mj_header endRefreshing];
        
        // 拿到当前的上拉刷新控件，结束刷新状态
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ZhiBoCell";
    
    HYLZhiBoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[HYLZhiBoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (_dataArray.count > indexPath.row) {
        
        BangDanDetailInfoData *model = _dataArray[indexPath.row];
        
        cell.title.text = model.title;
        cell.updated_at.text = model.updated_at;
        
        CGFloat imageHeight = model.video_info.cover_height.floatValue;
        CGFloat imageWidth = model.video_info.cover_width.floatValue;
        CGFloat trueHeight = [UIScreen mainScreen].bounds.size.width * (imageHeight/imageWidth);
        
        cell.videoImage.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, trueHeight);
        cell.orderImage.center = CGPointMake(40, cell.videoImage.frame.size.height*0.5-12);
        cell.title.center = CGPointMake(cell.videoImage.frame.size.width*0.5, cell.videoImage.frame.size.height*0.5-25);
        cell.updated_at.center = CGPointMake(cell.videoImage.frame.size.width*0.5, cell.videoImage.frame.size.height*0.5);
        [cell.videoImage sd_setImageWithURL:[NSURL URLWithString:model.video_info.cover_url] placeholderImage:[UIImage imageNamed:@"defaultload"]];
        
        if (indexPath.row < 9) {
            
            cell.orderImage.image = [UIImage imageNamed:_imageArray[indexPath.row]];
            
        } else {
            
            cell.orderImage.image = nil;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat imageHeight;
    CGFloat imageWidth;
    
    if (_dataArray.count > indexPath.row) {
        
        BangDanDetailInfoData *model = _dataArray[indexPath.row];
        imageHeight = model.video_info.cover_height.floatValue;
        imageWidth  = model.video_info.cover_width.floatValue;
    }
    
    return [HYLZhiBoCell getImageViewWidth:imageWidth height:imageHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BangDanDetailInfoData *model = _dataArray[indexPath.row];
    NSString *music_id = [NSString stringWithFormat:@"%ld", (long)(model.musicId)];
    
    HYLYinYueDetailCommonViewController *yinYueDetailVC = [[HYLYinYueDetailCommonViewController alloc] init];
    yinYueDetailVC.musicID = music_id;
    yinYueDetailVC.musicTitle = model.title;
    
    
    CGFloat imageHeight = model.video_info.cover_height.floatValue;
    CGFloat imageWidth  = model.video_info.cover_width.floatValue;
    
    yinYueDetailVC.imageWidth = imageWidth;
    yinYueDetailVC.imageHeight = imageHeight;
    
    yinYueDetailVC.hidesBottomBarWhenPushed = YES;
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    HYLTabBarController *tabBarController = delegate.tabBarController;
    
    [tabBarController pushToViewController:yinYueDetailVC animated:NO];
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
