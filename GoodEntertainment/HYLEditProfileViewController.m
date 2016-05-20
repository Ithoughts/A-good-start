//
//  HYLEditProfileViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/10/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLEditProfileViewController.h"

#import <UIImageView+WebCache.h>

@interface HYLEditProfileViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    UITableView *_tableView;
    
    //
    UIImageView *imageView;
    UIButton *replaceAvatarButton;
    
    UITextField *nicknameField;
    UITextField *sexField;
    
    NSString *_edited_name;
    NSString *_edited_sex;
}

@end

@implementation HYLEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    title.text = @"修改个人资料";
    title.font = [UIFont systemFontOfSize:18.0f];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = title;
    
    [self prepareTableView];
}

- (void)prepareTableView
{
    CGRect screenRect    = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth  = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 220)];
    
    UIImage *image = [UIImage imageNamed:@"defaultImage"];
    
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth * 0.5 - image.size.width * 0.5, 50, image.size.width, image.size.height)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *avatar = [defaults objectForKey:@"avatar"];
    
    
    if (avatar != nil) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:avatar]];
        [_tableView reloadData];
        
    } else {
         
         imageView.image = image;
    }

    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [headerView addSubview:imageView];
    
    replaceAvatarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height + imageView.frame.origin.y + 15, [UIScreen mainScreen].bounds.size.width, 30)];
    replaceAvatarButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, imageView.frame.size.height + imageView.frame.origin.y + 15 + 0.5*replaceAvatarButton.frame.size.height);
    
    [replaceAvatarButton setTitle:@"更换头像" forState:UIControlStateNormal];
    replaceAvatarButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [replaceAvatarButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    replaceAvatarButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [replaceAvatarButton addTarget:self action:@selector(changeAvatar:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:replaceAvatarButton];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - 64) style: UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableHeaderView = headerView;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    UIButton *determineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    determineButton.frame = CGRectMake(20, screenHeight - 64 - 70, screenWidth - 40, 50);
    [determineButton setTitle:@"确认" forState:UIControlStateNormal];
    [determineButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    determineButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    determineButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [determineButton setBackgroundImage:[UIImage imageNamed:@"determineIcon"] forState:UIControlStateNormal];
    [determineButton addTarget:self action:@selector(determineButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:determineButton];
}

#pragma mark - 更换头像

- (void)changeAvatar:(UIButton *)sender
{
    NSLog(@"更换头像");
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = rect.size.width;
    
    if (indexPath.row == 0) {
        
        UILabel *nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 30)];
        nicknameLabel.text = @"昵称";
        nicknameLabel.font = [UIFont systemFontOfSize:18.0f];
        nicknameLabel.textColor = [UIColor blackColor];
        nicknameLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:nicknameLabel];
        
        nicknameField = [[UITextField alloc] initWithFrame:CGRectMake(nicknameLabel.frame.origin.x+nicknameLabel.frame.size.width-30, 10, screenWidth- (nicknameLabel.frame.origin.x+nicknameLabel.frame.size.width-30) - 10, 30)];
        nicknameField.delegate = self;
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *name = [defaults objectForKey:@"name"];
        
        if (name != nil) {
            
            nicknameField.text = name;
            
        } else {
        
            nicknameField.text = @"";
        }
        
        nicknameField.textColor = [UIColor lightGrayColor];
        nicknameField.font = [UIFont systemFontOfSize:18.0f];
        nicknameField.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview: nicknameField];

        
    } else if (indexPath.row == 1) {
        
        UILabel *genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 30)];
        genderLabel.text = @"性别";
        genderLabel.font = [UIFont systemFontOfSize:16.0f];
        genderLabel.textColor = [UIColor blackColor];
        genderLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:genderLabel];
        
        sexField = [[UITextField alloc] initWithFrame:CGRectMake(genderLabel.frame.origin.x+genderLabel.frame.size.width-30, 10, screenWidth - (genderLabel.frame.origin.x+genderLabel.frame.size.width-30) - 10, 30)];
        sexField.delegate = self;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *sex = [defaults objectForKey:@"sex"];
        
        if (sex != nil) {
            
            if ([sex isEqualToString:@"male"]) {
                
                sexField.text = @"男";
                
            } else if ([sex isEqualToString:@"female"]) {
            
                sexField.text = @"女";
            }
            
        } else {
        
            sexField.text = @"";
        }
        
        sexField.textColor = [UIColor lightGrayColor];
        sexField.font = [UIFont systemFontOfSize:18.0f];
        sexField.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview: sexField];
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

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == nicknameField) {
        _edited_name = nicknameField.text;
    }
    
    if (textField == sexField) {
        
        _edited_sex = sexField.text;
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
