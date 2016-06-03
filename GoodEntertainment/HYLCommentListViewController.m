//
//  HYLCommentListViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 5/11/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLCommentListViewController.h"
#import "HYLCommentCell.h"
#import "HYLCommentModel.h"

#import "HYLSignInViewController.h"

#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import "HaoYuLeNetworkInterface.h"

#import <MJRefresh/MJRefresh.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface HYLCommentListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    NSMutableArray *_dataArray;
    UITableView *_tableView;
    
    NSString *_token;
}

@end

@implementation HYLCommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    _page = 1;
    _dataArray = [[NSMutableArray alloc] init];
    
    [self prepareNavigationBar];
    [self HYLCommentListRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _token = [defaults objectForKey:@"token"];
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

#pragma mark - 表视图

- (void)prepareTableView
{
    _tableView = [[UITableView alloc ]initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight - 64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    
//    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
//    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        [weakSelf loadMoreData];
//    }];
}

#pragma mark - 下拉刷新

- (void)loadNewData
{
    self.page = 1;
    
    [_dataArray removeAllObjects];
    
    [self HYLCommentListRequest];
}

//#pragma mark - 上拉加载更多
//
//- (void)loadMoreData
//{
//    self.page ++;
//    
//    [self HYLCommentListRequest];
//}

#pragma mark - 返回

- (void)goBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 获取评论列表，网络请求

- (void)HYLCommentListRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];

    [dictionary setValue:timestamp      forKey:@"time"];
    [dictionary setValue:signature      forKey:@"sign"];
    [dictionary setValue:self.videoId   forKey:@"video_id"];
    [dictionary setValue:[NSString stringWithFormat:@"%ld", _page] forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kGetVideoCommentURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"评论列表: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSArray *dataArray = responseDic[@"data"];
            
            if (dataArray.count > 0) {
                
                for (NSDictionary *dic in dataArray) {
                    
                    HYLCommentModel *model = [[HYLCommentModel alloc] init];
                    
                    
                    model.content    = dic[@"content"];
                    model.like_count = dic[@"like_count"];
                    model.created_at = dic[@"created_at"];
                    model.comment_id = [NSString stringWithFormat:@"%@", dic[@"id"]];
                    
                    NSDictionary *user = dic[@"user"];
                    
                    model.name         = user[@"name"];
                    model.avatar       = user[@"avatar"];
                    
                    [_dataArray addObject:model];
                }
                
                [self prepareTableView];
                
                [_tableView reloadData];
                
                // 拿到当前的下拉刷新控件，结束刷新状态
                [_tableView.mj_header endRefreshing];
                
                // 拿到当前的上拉刷新控件，结束刷新状态
                [_tableView.mj_footer endRefreshing];
                
            } else {
                
                UIImage *backgroundImage = [UIImage imageNamed:@"tip"];
                
                // 背景
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
                imageView.image = backgroundImage;
                imageView.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
                [self.view addSubview:imageView];
                
                // 标签
                UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - 60, imageView.frame.origin.y + imageView.frame.size.height + 5, 120, 30)];
                tipLabel.text = @"暂无评论";
                tipLabel.font = [UIFont systemFontOfSize:16.0f];
                tipLabel.textColor = [UIColor blackColor];
                tipLabel.textAlignment = NSTextAlignmentCenter;
                [self.view addSubview:tipLabel];
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
    static NSString *CellIdentifier = @"commentCell";

    HYLCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {

        cell = [[HYLCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    HYLCommentModel *model    = _dataArray[indexPath.row];
    
    cell.titleLabel.text      = model.name;
    cell.created_atLabel.text = model.created_at;
    cell.contentLabel.text    = model.content;
    
    [cell.avatar sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"defaultImage"]];
    
    if (model.like_count.integerValue > 0) {
        
        [cell.like_countButton setImage:[UIImage imageNamed:@"dianzanle"] forState:UIControlStateNormal];
        
    } else {
    
        [cell.like_countButton setImage:[UIImage imageNamed:@"dianzan"] forState:UIControlStateNormal];
    }
    
    cell.like_countButton.tag = indexPath.row + 1000;
    cell.like_countButton.userInteractionEnabled = YES;
    cell.like_countLabel.text = model.like_count;
    
    [cell.like_countButton addTarget:self action:@selector(dianzanAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

#pragma mark - 点赞请求

- (void)dianzanAction:(UIButton *)sender
{
    if (_token != nil && _token.length > 0) {
        
        NSInteger buttonTag = sender.tag - 1000;
        HYLCommentModel *model = _dataArray[buttonTag];
        
        NSString *comment_id = model.comment_id;
        
        //
        NSString *timestamp = [HYLGetTimestamp getTimestampString];
        NSString *signature = [HYLGetSignature getSignature:timestamp];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        
        [dictionary setValue:timestamp          forKey:@"time"];
        [dictionary setValue:signature          forKey:@"sign"];
        [dictionary setValue:comment_id         forKey:@"comment_id"];
        
        // HTTP Basic Authorization 认证机制
        NSString *authorization = [NSString stringWithFormat:@"Basic %@", _token];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
        
        [manager POST:kLikeCommentURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"点赞返回: %@", reponse);
            
            NSError *error = nil;
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
            
            NSString *message = responseDic[@"message"];
            
            if ([responseDic[@"status"]  isEqual: @1]) {
                
                [self loadNewData];
                
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD showSuccessWithStatus:message];
                
            } else {
                
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD showErrorWithStatus:message];
            }
            
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            
            NSLog(@"error: %@", error);
            
        }];

    } else {
    
        HYLSignInViewController *loginVC = [[HYLSignInViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
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
