//
//  HYLMyCollectionViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/10/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLMyCollectionViewController.h"
#import "HYLZhiBoCell.h"
//#import "HYLZhiBoListModel.h"
#import "HYLCollectionModel.h"

#import "AppDelegate.h"
#import "HYLTabBarController.h"

#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import <AFNetworking.h>
#import "HaoYuLeNetworkInterface.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <MJRefresh.h>

@interface HYLMyCollectionViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_dataArray;
    NSInteger _page;
    NSString *_token;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HYLMyCollectionViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    _token                   = [defaults objectForKey:@"token"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _page = 1;
    _dataArray = [[NSMutableArray alloc] init];
    
    _token = @"MTU4MTU4MzU2NjU6MTIzNDU2";
    
    [self HYLCollectionApiRequest];
    [self prepareCollectionNaviBar];
    [self prepareCollectionTableView];
}

#pragma mark - 导航栏

- (void)prepareCollectionNaviBar
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    titleLabel.text = @"我的收藏";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:18.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

#pragma mark - 表格视图

- (void)prepareCollectionTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
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
//    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        
//        [weakSelf loadMoreData];
//        
//    }];
}

#pragma mark - 返回

- (void)goBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 下拉刷新

- (void)loadNewData
{
    _page = 1;
    [_dataArray removeAllObjects];
    
    [self HYLCollectionApiRequest];
}

#pragma mark - 上拉加载更多

//- (void)loadMoreData
//{
//    _page ++;
//    
//    [self HYLCollectionApiRequest];
//}

#pragma mark - 网络请求

- (void)HYLCollectionApiRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:[NSString stringWithFormat:@"%ld", (long)_page] forKey:@"page"];
    
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", _token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    [manager POST:kGetUserFavoriteURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"收藏返回: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
        
            NSArray  *data = responseDic[@"data"];
            
            if (data.count > 0) {
                
                for (NSDictionary *dic in data) {
                    
                    HYLCollectionModel *model = [[HYLCollectionModel alloc] init];
                    model.videoId = [dic[@"id"] integerValue];
                    model.title = dic[@"title"];
                    model.video_info_id = dic[@"video_info_id"];
                    model.author = dic[@"author"];
                    model.view_count = dic[@"view_count"];
                    model.comment_count = dic[@"comment_count"];
                    model.like_count = dic[@"like_count"];
                    model.created_at = dic[@"created_at"];
                    
                    //
                    NSDictionary *video_info = dic[@"video_info"];
                    
                    model.video_info_id = video_info[@"id"];
                    model.url = video_info[@"url"];
                    model.cover_url = video_info[@"cover_url"];
                    model.cover_width = video_info[@"cover_width"];
                    model.cover_height = video_info[@"cover_height"];
                    
                    [_dataArray addObject:model];
                }
                
                // 刷新表格
                [self.tableView reloadData];
                
                // 拿到当前的下拉刷新控件，结束刷新状态
                [self.tableView.mj_header endRefreshing];
                
                // 拿到当前的上拉刷新控件，结束刷新状态
//                [self.tableView.mj_footer endRefreshing];
            
            } else {
        
                // 刷新表格
                [self.tableView reloadData];
                
                // 拿到当前的上拉刷新控件，变为没有更多数据的状态
//                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                
                // 隐藏当前的上拉刷新控件
//                self.tableView.mj_footer.hidden = YES;
            }
            
        } else {
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error:%@", error);
        
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
    
    HYLZhiBoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[HYLZhiBoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (_dataArray.count > indexPath.row) {
        
        HYLCollectionModel *model = _dataArray[indexPath.row];
        
        cell.title.text = model.title;
        
        CGFloat imageHeight = model.cover_height.floatValue;
        CGFloat imageWidth  = model.cover_width.floatValue;
        CGFloat trueHeight = [UIScreen mainScreen].bounds.size.width * (imageHeight/imageWidth);
        
        cell.videoImage.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, trueHeight);
        cell.title.center = cell.videoImage.center;
        [cell.videoImage sd_setImageWithURL:[NSURL URLWithString:model.cover_url] placeholderImage:[UIImage imageNamed:@"defaultload"]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat imageHeight;
    CGFloat imageWidth;
    
    if (_dataArray.count > indexPath.row) {
        
        HYLCollectionModel *model = _dataArray[indexPath.row];
        imageHeight = model.cover_height.floatValue;
        imageWidth  = model.cover_width.floatValue;
    }
    
    return [HYLZhiBoCell getImageViewWidth:imageWidth height:imageHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
