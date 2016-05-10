//
//  HYLEditProfileViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/10/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLEditProfileViewController.h"
#import <UIViewController+MMDrawerController.h>

@interface HYLEditProfileViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate>
{
    UITableView *_tableView;
}

@end

@implementation HYLEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tabBarController.tabBar.hidden = YES;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
    title.text = @"修改个人资料";
    title.font = [UIFont systemFontOfSize:18.0f];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = title;
    
    [self prepareTableView];
}

- (void)prepareTableView
{
    /*********      tableView Header View     **************/
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 120)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth * 0.5 - 30, 30, 60, 60)];
    imageView.image = [UIImage imageNamed:@"defaultImage"];
    [headerView addSubview:imageView];
    
    UILabel *replaceAvatarLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x - 30, imageView.frame.size.height + imageView.frame.origin.y + 5, 120, 30)];
    replaceAvatarLabel.text = @"更换头像";
    replaceAvatarLabel.font = [UIFont systemFontOfSize:16.0f];
    replaceAvatarLabel.textColor = [UIColor blackColor];
    replaceAvatarLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:replaceAvatarLabel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style: UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableHeaderView = headerView;
    _tableView.tableFooterView = [[UIView alloc] init];
    
    [self.view addSubview:_tableView];
    
    UIButton *determineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    determineButton.frame = CGRectMake(20, screenHeight - 64 - 70, screenWidth - 40, 40);
    [determineButton setTitle:@"确认" forState:UIControlStateNormal];
    [determineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    determineButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    determineButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [determineButton setBackgroundImage:[UIImage imageNamed:@"determineIcon"] forState:UIControlStateNormal];
    [determineButton setBackgroundImage:[UIImage imageNamed:@"determineselected"] forState:UIControlStateHighlighted];
    [determineButton addTarget:self action:@selector(determineButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:determineButton];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = rect.size.width;
    
    if (indexPath.row == 0) {
        
        UILabel *nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 30)];
        nicknameLabel.text = @"昵称";
        nicknameLabel.font = [UIFont systemFontOfSize:16.0f];
        nicknameLabel.textColor = [UIColor blackColor];
        nicknameLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:nicknameLabel];
        
        UITextField *nicknameField = [[UITextField alloc] initWithFrame:CGRectMake(nicknameLabel.frame.origin.x+nicknameLabel.frame.size.width, 10, screenWidth- (nicknameLabel.frame.origin.x+nicknameLabel.frame.size.width) - 10, 30)];
        nicknameField.delegate = self;
        nicknameField.text = @"影子的白日梦";
        nicknameField.textColor = [UIColor lightGrayColor];
        nicknameField.font = [UIFont systemFontOfSize:16.0f];
        nicknameField.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview: nicknameField];

        
    } else if (indexPath.row == 1) {
        
        UILabel *genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 30)];
        genderLabel.text = @"性别";
        genderLabel.font = [UIFont systemFontOfSize:16.0f];
        genderLabel.textColor = [UIColor blackColor];
        genderLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:genderLabel];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(genderLabel.frame.origin.x+genderLabel.frame.size.width, 10, screenWidth - (genderLabel.frame.origin.x+genderLabel.frame.size.width) - 10, 30)];
        rightLabel.text = @"女";
        rightLabel.textColor = [UIColor lightGrayColor];
        rightLabel.font = [UIFont systemFontOfSize:16.0f];
        rightLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview: rightLabel];
        
    } else if (indexPath.row == 2) {
        
        UILabel *birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 30)];
        birthdayLabel.text = @"生日";
        birthdayLabel.font = [UIFont systemFontOfSize:16.0f];
        birthdayLabel.textColor = [UIColor blackColor];
        birthdayLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:birthdayLabel];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(birthdayLabel.frame.origin.x+birthdayLabel.frame.size.width, 10, screenWidth - (birthdayLabel.frame.origin.x+birthdayLabel.frame.size.width) - 10, 30)];
        rightLabel.text = @"1991-06";
        rightLabel.textColor = [UIColor lightGrayColor];
        rightLabel.font = [UIFont systemFontOfSize:16.0f];
        rightLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview: rightLabel];
        
    } else if (indexPath.row == 3) {
        
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 30)];
        locationLabel.text = @"所在地";
        locationLabel.font = [UIFont systemFontOfSize:16.0f];
        locationLabel.textColor = [UIColor blackColor];
        locationLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:locationLabel];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(locationLabel.frame.origin.x+locationLabel.frame.size.width, 10, screenWidth - (locationLabel.frame.origin.x+locationLabel.frame.size.width) - 10, 30)];
        rightLabel.text = @"广东省-广州市";
        rightLabel.textColor = [UIColor lightGrayColor];
        rightLabel.font = [UIFont systemFontOfSize:16.0f];
        rightLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview: rightLabel];
        
    } else if (indexPath.row == 4) {
    
        UITextView *signatureTextView = [[UITextView alloc] init];
        signatureTextView.frame = CGRectMake(10, 10, screenWidth, 120);
        signatureTextView.delegate = self;
        signatureTextView.text = @"个性签名...";
        signatureTextView.font = [UIFont systemFontOfSize:16.0f];
        signatureTextView.textColor = [UIColor lightGrayColor];
        signatureTextView.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:signatureTextView];
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
    if (indexPath.row == 4) {
        return 140.0f;
    } else {
    
        return 50.0f;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        
        
    } else if (indexPath.row == 1) {
        
        
    } else if (indexPath.row == 2) {
        
        
    } else if (indexPath.row == 3) {
        
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - 确定按钮
- (void)determineButtonTapped:(UIButton *)sender
{
    NSLog(@"确定");
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        
        return NO;
        
    } else {
    
        return YES;
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
