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

//#import <MMDrawerBarButtonItem.h>
//#import <UIViewController+MMDrawerController.h>

#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import <AFNetworking.h>
#import "HaoYuLeNetworkInterface.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "HYLZhiBoCell.h"
#import "HYLZhiBoListModel.h"

#define   kTITLEVIEWRGB(r, g, b)   [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]

@interface HYLHaoJingCaiListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
}

@end

@implementation HYLHaoJingCaiListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _page = 1;
    [self hylHaoJingCaiApiRequest];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    
    // left bar Button Item
//    [self setupLeftMenuButton];
    
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

//-(void)setupLeftMenuButton {
//    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
//    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
//}
//#pragma mark - Button Handlers
//-(void)leftDrawerButtonPress:(id)sender {
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
//}

#pragma mark - 表格视图

- (void)prepareJingCaiTableView
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
            
            _dataArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dic in secondData) {
                
                HYLZhiBoListModel *model = [[HYLZhiBoListModel alloc] initWithDictionary:dic];
                [_dataArray addObject:model];
        }
            
            [_tableView reloadData];
        
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //
    HYLZhiBoListModel *model = _dataArray[indexPath.row];
    NSInteger videoId = model.videoId;
    
    HYLJingCaiDetailedInfoViewController *jingCaiDetailedVC = [[HYLJingCaiDetailedInfoViewController alloc] init];
    jingCaiDetailedVC.videoId = [NSString stringWithFormat:@"%ld", (long)videoId];
    jingCaiDetailedVC.title = model.title;
    
    jingCaiDetailedVC.hidesBottomBarWhenPushed = YES;
    
    HYLTabBarController *tabBarController = [(AppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController];
    
    [tabBarController pushToViewController:jingCaiDetailedVC animated:NO];
    
//    [self.navigationController pushViewController:jingCaiDetailedVC animated:NO];
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
