//
//  HYLLeftViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLMenuViewController.h"

#import "HYLMyCollectionViewController.h"
#import "HYLEditProfileViewController.h"
#import "HYLSettingViewController.h"
#import "HYLSignInViewController.h"

#import <UIImageView+WebCache.h>

@interface HYLMenuViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    NSArray *_imageArray;
    NSArray *_titleArray;
    
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    UIImageView *avatarImageView;
    UILabel *nicknameLabel;
    UILabel *loginLabel;
    
    NSString *token;
}

@end

@implementation HYLMenuViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    token = [defaults objectForKey:@"token"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLogin:)
                                                 name:@"logined"
                                               object:nil];
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    [self prepareNavigationBar];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.tableHeaderView = ({
        
        // 头视图
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 230.0f)];
        
        // 头像
        UIImage *avatar = [UIImage imageNamed:@"defaultImage"];
        
        avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, avatar.size.width, avatar.size.height)];
        avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        avatarImageView.image = avatar;
//        imageView.clipsToBounds = YES;
//        imageView.layer.masksToBounds = YES;
//        imageView.layer.cornerRadius = 50.0;
        avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        [view addSubview:avatarImageView];
        
        // 昵称
        nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, _screenWidth, 24)];
        nicknameLabel.text = @"未登录";
        nicknameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        nicknameLabel.backgroundColor = [UIColor clearColor];
        nicknameLabel.textColor = [UIColor blackColor];
        [nicknameLabel sizeToFit];
        nicknameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [view addSubview:nicknameLabel];
        
        view;
    });
}

#pragma mark - 通知响应

- (void)userLogin:(NSNotification *)notification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *nickName = [defaults objectForKey:@"name"];
    
    if (nickName != nil) {
        
        nicknameLabel.text = nickName;
        loginLabel.text = @"退出登录";
        [self.tableView reloadData];
    }
    
    NSString *avatar = [defaults objectForKey:@"avatar"];
    
    if (avatar != nil) {
        
        [avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatar]];
        [self.tableView reloadData];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 创建导航栏

- (void)prepareNavigationBar
{
    // bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UINavigationItem *navItem = self.navigationItem;
    
    
    // left bar button item
    UIImage  *leftImage  = [UIImage imageNamed:@"backIcon"];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
    [leftButton setImage:leftImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backTo:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    navItem.leftBarButtonItem = left;
}

#pragma mark - 返回

- (void)backTo:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    _titleArray = @[@"我的收藏", @"修改资料", @"系统设置", @"登录"];
    
    if (indexPath.row == 0) {
        
        cell = [self configureCell:cell WithImage:_imageArray[0] title:_titleArray[0]];
        
    } else if (indexPath.row == 1) {
    
        cell = [self configureCell:cell WithImage:_imageArray[1] title:_titleArray[1]];
    
    } else if (indexPath.row == 2) {
    
        cell = [self configureCell:cell WithImage:_imageArray[2] title:_titleArray[2]];
        
    } else if (indexPath.row == 3) {
        
        UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth * 0.5 - 60, 12, 24, 24)];
        leftImageView.image = [UIImage imageNamed:_imageArray[3]];
        [cell.contentView addSubview:leftImageView];
        
        loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftImageView.frame.origin.x+leftImageView.frame.size.width + 10, 10, 120, 30)];
        
        if ([nicknameLabel.text isEqualToString:@"未登录"]) {
            
            loginLabel.text = _titleArray[3];
            
        } else {
        
            loginLabel.text = @"退出登录";
        }
        
        loginLabel.textColor = [UIColor blackColor];
        loginLabel.font = [UIFont systemFontOfSize:18.0f];
        loginLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:loginLabel];
    }
    
    return cell;
}

#pragma mark - cell contentview

- (UITableViewCell *)configureCell:(UITableViewCell *)cell WithImage:(NSString *)image title:(NSString *)title
{
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth * 0.5 - 60, 12, 24, 24)];
    leftImageView.image = [UIImage imageNamed:image];
    [cell.contentView addSubview:leftImageView];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftImageView.frame.origin.x+leftImageView.frame.size.width + 10, 10, 120, 30)];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        if (token != nil) {
            
            HYLMyCollectionViewController *collectionVC = [[HYLMyCollectionViewController alloc] init];
            
            collectionVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:collectionVC animated:NO];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请先登录" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
    } else if (indexPath.row == 1) {
        
        if (token != nil) {
            
            HYLEditProfileViewController *editProfileVC = [[HYLEditProfileViewController alloc] init];
            
            editProfileVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:editProfileVC animated:NO];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请先登录" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        }
    
    } else if (indexPath.row == 2) {
        
        if (token != nil) {
        
            HYLSettingViewController *setUpVC = [[HYLSettingViewController alloc] init];
            
            setUpVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:setUpVC animated:NO];
            
        } else {
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请先登录" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        
        
    } else if (indexPath.row == 3) {
        
        if (token != nil) {
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确定要退出登录?"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                 destructiveButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
            [sheet showInView:self.view];
            
        } else {
            
            HYLSignInViewController *signInVC = [[HYLSignInViewController alloc] init];
            
            signInVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:signInVC animated:NO];
        }
    }
}


#pragma mark --- UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0)
    {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:@"user_id"];
    [userDefaults removeObjectForKey:@"name"];
    [userDefaults removeObjectForKey:@"mobile"];
    [userDefaults removeObjectForKey:@"sex"];
    [userDefaults removeObjectForKey:@"avatar"];
    [userDefaults removeObjectForKey:@"created_at"];
    [userDefaults removeObjectForKey:@"updated_at"];
    [userDefaults removeObjectForKey:@"token"];
    
    [userDefaults synchronize];

    // 弹出一个栈顶控制器，即本控制器，回到上一页
    [self.navigationController popToRootViewControllerAnimated:YES];
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
