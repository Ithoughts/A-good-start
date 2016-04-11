//
//  HYLLeftViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLMenuViewController.h"

#import "UIViewController+MMDrawerController.h"


#import "HYLHaoYuLeCommonDetailViewController.h"

//#import "HYLMyCollectionViewController.h"
#import "HYLEditProfileViewController.h"
#import "HYLSettingViewController.h"
#import "HYLSignInViewController.h"

@interface HYLMenuViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_imageArray;
    NSArray *_titleArray;
}

@end

@implementation HYLMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.tableHeaderView = ({
        
        // 表头视图
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 220.0f)];
        
        // 头像
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"defaultImage"];
        imageView.clipsToBounds = YES;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
//        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
//        imageView.layer.borderWidth = 3.0f;

        [view addSubview:imageView];
        
        // 昵称
        UILabel *nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        nicknameLabel.text = @"影子的白日梦";
        nicknameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        nicknameLabel.backgroundColor = [UIColor clearColor];
        nicknameLabel.textColor = [UIColor blackColor];
        [nicknameLabel sizeToFit];
        nicknameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [view addSubview:nicknameLabel];
        
        // 签名
        UILabel *signatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 174, 0, 24)];
        signatureLabel.text = @"梦想只需坚持，终有一日会实现!";
        signatureLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        signatureLabel.backgroundColor = [UIColor clearColor];
        signatureLabel.textColor = [UIColor lightGrayColor];
        [signatureLabel sizeToFit];
        signatureLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [view addSubview:signatureLabel];
        
        view;
    });
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    _imageArray = @[@"myCollectionIcon", @"changeInfoIcon", @"settingIcon", @"logoutIcon"];
    _titleArray = @[@"我的收藏", @"修改资料", @"设置", @"退出登录"];
    
    if (indexPath.row == 0) {
        
        cell = [self configureCell:cell WithImage:_imageArray[0] title:_titleArray[0]];
        
    } else if (indexPath.row == 1) {
    
        cell = [self configureCell:cell WithImage:_imageArray[1] title:_titleArray[1]];
    
    } else if (indexPath.row == 2) {
    
        cell = [self configureCell:cell WithImage:_imageArray[2] title:_titleArray[2]];
        
    } else if (indexPath.row == 3) {
    
        cell = [self configureCell:cell WithImage:_imageArray[3] title:_titleArray[3]];
    }
    
    return cell;
}

#pragma mark - cell contentview
- (UITableViewCell *)configureCell:(UITableViewCell *)cell WithImage:(NSString *)image title:(NSString *)title
{
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width * 3/4.0 * 0.5 - 40, 12, 24, 24)];
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
    return 54.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
//        HYLMyCollectionViewController *collectionVC = [[HYLMyCollectionViewController alloc] init];
        HYLHaoYuLeCommonDetailViewController *test = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HYLTouTiaoDetailViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:test];
        
        [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
        
    } else if (indexPath.row == 1) {
        
        HYLEditProfileViewController *editProfileVC = [[HYLEditProfileViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editProfileVC];
        
        [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
    
    } else if (indexPath.row == 2) {
        
        HYLSettingViewController *setUpVC = [[HYLSettingViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:setUpVC];
        
        [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
    
    } else if (indexPath.row == 3) {
        
        HYLSignInViewController *signInVC = [[HYLSignInViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:signInVC];
        
        [self.mm_drawerController setCenterViewController:nav withCloseAnimation:YES completion:nil];
    }
    
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
