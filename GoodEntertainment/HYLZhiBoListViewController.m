//
//  HYLZhiBoListViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLZhiBoListViewController.h"
#import "HYLZhiBoInformationViewController.h"

#import "AppDelegate.h"
#import "HYLTabBarController.h"
#import "HYLMenuViewController.h"

#import "HYLZhiBoCell.h"
#import "HYLZhiBoListModel.h"

// 网络请求
#import <AFNetworking.h>

// 图片缓存
#import <SDWebImage/UIImageView+WebCache.h>

// 时间戳
#import "HYLGetTimestamp.h"

// 签名
#import "HYLGetSignature.h"

// 接口
#import "HaoYuLeNetworkInterface.h"

#import <MJRefresh.h>

#define   KTITLEVIEWRGB(r, g, b)   [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]

@interface HYLZhiBoListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_dataArray;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HYLZhiBoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _page = 1;
    _dataArray = [[NSMutableArray alloc] init];
    
    [self hylZhiBoApiRequest];
    
    // navigation bar
    [self setupNavigationBar];
    
    // left bar Button Item
    [self setupLeftMenuButton];
    
    // title view
    [self setupTitleView];
    
    // table view
    [self prepareTableView];
}

- (void)setupNavigationBar
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
}
- (void)setupTitleView
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
    titleLabel.text = @"重温回顾";
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = KTITLEVIEWRGB(255, 199, 3);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - 导航栏左侧按钮

-(void)setupLeftMenuButton
{
    UIImage *leftImage = [UIImage imageNamed:@"navi_left_item"];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
    [leftButton setImage:leftImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftBarButtonItemTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

#pragma mark - 左侧图

- (void)leftBarButtonItemTouch:(UIButton *)sender
{
    HYLMenuViewController *leftMenuVC = [[HYLMenuViewController alloc] init];
    
    leftMenuVC.hidesBottomBarWhenPushed = YES;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    HYLTabBarController *tabBarController = appDelegate.tabBarController;
    
    [tabBarController pushToViewController:leftMenuVC animated:NO];
}

- (void)prepareTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 49 - 64)
                                              style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
//    self.tableView.mj_footer.hidden = YES;
}

#pragma mark - 下拉刷新

- (void)loadNewData
{
    _page = 1;
    
    [_dataArray removeAllObjects];
    
    [self hylZhiBoApiRequest];
}

#pragma mark - 上拉加载更多

- (void)loadMoreData
{
    _page ++;
    
    [self hylZhiBoApiRequest];
}

#pragma mark - 网络请求

- (void)hylZhiBoApiRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:[NSString stringWithFormat:@"%ld", (long)_page] forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kChongWenURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"重温: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
//        NSLog(@"status: %@", responseDic[@"status"]);
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *firstDataDic = responseDic[@"data"];
            
            NSArray *secondData = firstDataDic[@"data"];
            
            if (secondData.count > 0) {
                
                for (NSDictionary *dic in secondData) {
                    
                    HYLZhiBoListModel *model = [[HYLZhiBoListModel alloc] initWithDictionary:dic];
                    [_dataArray addObject:model];
                    
//                NSLog(@"title: %@", model.title);
//                NSLog(@"updated_at: %@", model.updated_at);
                }
                
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
    static NSString *CellIdentifier = @"ZhiBoCell";

    HYLZhiBoListModel *model = _dataArray[indexPath.row];
    
    HYLZhiBoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[HYLZhiBoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
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
    //
    HYLZhiBoListModel *model = _dataArray[indexPath.row];
    NSInteger videoId = model.videoId;
    
    HYLZhiBoInformationViewController *zhiBoInforVC = [[HYLZhiBoInformationViewController alloc] init];
    zhiBoInforVC.videoId = [NSString stringWithFormat:@"%ld", (long)videoId];
    zhiBoInforVC.zhiBoTitle = model.title;
    zhiBoInforVC.hidesBottomBarWhenPushed = YES;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    HYLTabBarController *tabBarController = appDelegate.tabBarController;
    
    [tabBarController pushToViewController:zhiBoInforVC animated:NO];
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
