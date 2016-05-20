//
//  HYLSetUpViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/10/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLSettingViewController.h"

@interface HYLSettingViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
}

@end

@implementation HYLSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    title.text = @"设置";
    title.font = [UIFont systemFontOfSize:18.0f];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = title;
    
    [self prepareTableView];
}
- (void)prepareTableView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 64) style: UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = rect.size.width;
    
    if (indexPath.row == 0) {
        
        UILabel *aboutLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 30)];
        aboutLabel.text = @"关于好娱乐";
        aboutLabel.font = [UIFont systemFontOfSize:18.0f];
        aboutLabel.textColor = [UIColor blackColor];
        aboutLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:aboutLabel];
        
        UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(aboutLabel.frame.origin.x+aboutLabel.frame.size.width, 10, screenWidth - (aboutLabel.frame.origin.x+aboutLabel.frame.size.width) - 10, 30)];
        versionLabel.text = @"1.0";
        versionLabel.textColor = [UIColor lightGrayColor];
        versionLabel.font = [UIFont systemFontOfSize:18.0f];
        versionLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview: versionLabel];
        
        
    } else if (indexPath.row == 1) {
        
        UILabel *feedbackLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 30)];
        feedbackLabel.text = @"意见反馈";
        feedbackLabel.font = [UIFont systemFontOfSize:18.0f];
        feedbackLabel.textColor = [UIColor blackColor];
        feedbackLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:feedbackLabel];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(feedbackLabel.frame.origin.x+feedbackLabel.frame.size.width, 10, screenWidth - (feedbackLabel.frame.origin.x+feedbackLabel.frame.size.width) - 10, 30)];
        rightLabel.textColor = [UIColor lightGrayColor];
        rightLabel.font = [UIFont systemFontOfSize:18.0f];
        rightLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview: rightLabel];
        

    } else if (indexPath.row == 2) {
        
        UILabel *cacheLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 30)];
        cacheLabel.text = @"清理缓存";
        cacheLabel.font = [UIFont systemFontOfSize:18.0f];
        cacheLabel.textColor = [UIColor blackColor];
        cacheLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:cacheLabel];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(cacheLabel.frame.origin.x+cacheLabel.frame.size.width, 10, screenWidth - (cacheLabel.frame.origin.x+cacheLabel.frame.size.width) - 10, 30)];
        rightLabel.text = @"";
        rightLabel.textColor = [UIColor lightGrayColor];
        rightLabel.font = [UIFont systemFontOfSize:18.0f];
        rightLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview: rightLabel];
    }
    
    return cell;
}

#pragma mark - cell contentview

- (UITableViewCell *)configureCell:(UITableViewCell *)cell WithImage:(NSString *)image title:(NSString *)title
{
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width * 0.5 - 40, 12, 24, 24)];
    leftImageView.image = [UIImage imageNamed:image];
    [cell.contentView addSubview:leftImageView];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftImageView.frame.origin.x+leftImageView.frame.size.width + 15, 10, 120, 30)];
    rightLabel.text = title;
    rightLabel.textColor = [UIColor blackColor];
    rightLabel.font = [UIFont systemFontOfSize:18.0f];
    rightLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview: rightLabel];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
    
    } else if (indexPath.row == 1) {
        
        NSLog(@"意见反馈");
        
    } else if (indexPath.row == 2) {
        
        NSLog(@"清理缓存");
    }
}

#pragma mark - 返回
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
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
