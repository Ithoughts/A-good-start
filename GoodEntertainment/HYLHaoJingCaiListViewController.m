//
//  HYLHaoXiChangListViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLHaoJingCaiListViewController.h"

#import "HYLJingCaiDetailedInfoViewController.h"

#import "AppDelegate.h"
#import "HYLTabBarController.h"
#import "HYLMenuViewController.h"

#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import <AFNetworking.h>
#import "HaoYuLeNetworkInterface.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "HYLZhiBoCell.h"
#import "HYLZhiBoListModel.h"

#import <MJRefresh.h>

#define   kTITLEVIEWRGB(r, g, b)   [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]

@interface HYLHaoJingCaiListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_dataArray;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HYLHaoJingCaiListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _page = 1;
    _dataArray = [[NSMutableArray alloc] init];
    [self hylHaoJingCaiApiRequest];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    
    // left bar Button Item
    [self setupLeftMenuButton];
    
    // title view
    [self setupTitleView];
    
    // table view
    [self prepareJingCaiTableView];
}

- (void)setupTitleView
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    titleLabel.text = @"好精彩";
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = kTITLEVIEWRGB(255, 199, 3);
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


#pragma mark - 表格视图

- (void)prepareJingCaiTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 49 - 64)
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
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
}

#pragma mark - 下拉刷新

- (void)loadNewData
{
    _page = 1;
    [_dataArray removeAllObjects];
    
    [self hylHaoJingCaiApiRequest];
}

#pragma mark - 上拉加载更多

- (void)loadMoreData
{
    _page ++;
    
    [self hylHaoJingCaiApiRequest];
}

#pragma mark - 网络请求

- (void)hylHaoJingCaiApiRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:[NSString stringWithFormat:@"%ld", (long)_page] forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kJingCaiURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject
//                                                  encoding:NSUTF8StringEncoding];
//        NSLog(@"好精彩: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *firstDataDic = responseDic[@"data"];
            
            NSArray *secondData = firstDataDic[@"data"];
            
            if (secondData.count > 0) {
                
                for (NSDictionary *dic in secondData) {
                    
                    HYLZhiBoListModel *model = [[HYLZhiBoListModel alloc] initWithDictionary:dic];
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
        
        HYLZhiBoListModel *model = _dataArray[indexPath.row];
        cell.title.text = model.title;
        cell.updated_at.text = model.updated_at;
        
        CGFloat imageHeight = model.video_info.cover_height.floatValue;
        CGFloat imageWidth  = model.video_info.cover_width.floatValue;
        CGFloat trueHeight  = [UIScreen mainScreen].bounds.size.width * (imageHeight/imageWidth);
        
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
        imageWidth  = model.video_info.cover_width.floatValue;
    }
    
    return [HYLZhiBoCell getImageViewWidth:imageWidth height:imageHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //
    HYLZhiBoListModel *model = _dataArray[indexPath.row];
    NSInteger videoId = model.videoId;
    
    CGFloat imageHeight = model.video_info.cover_height.floatValue;
    CGFloat imageWidth  = model.video_info.cover_width.floatValue;
    
    HYLJingCaiDetailedInfoViewController *jingCaiDetailedVC = [[HYLJingCaiDetailedInfoViewController alloc] init];
    jingCaiDetailedVC.videoId = [NSString stringWithFormat:@"%ld", (long)videoId];
    jingCaiDetailedVC.imageWidth = imageWidth;
    jingCaiDetailedVC.imageHeight = imageHeight;
    jingCaiDetailedVC.jingCaiTitle = model.title;
    
    //
    jingCaiDetailedVC.hidesBottomBarWhenPushed = YES;
    
    //
    HYLTabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController];
    [tabBarController pushToViewController:jingCaiDetailedVC animated:NO];
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
