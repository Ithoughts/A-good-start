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
    
    UIImageView *_imageView;
    UIButton    *_replaceAvatarButton;
    
    UITextField *_nicknameField;
    UITextField *_sexField;
    
    NSString    *_edited_name;
    NSString    *_edited_sex;
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

#pragma mark - 表视图

- (void)prepareTableView
{
    CGRect screenRect    = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth  = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 220)];
    
    UIImage *image = [UIImage imageNamed:@"defaultImage"];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth * 0.5 - image.size.width * 0.5, 50, image.size.width, image.size.height)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString       *avatar   = [defaults objectForKey:@"avatar"];
    
    if (avatar != nil) {
        
        [_imageView sd_setImageWithURL:[NSURL URLWithString:avatar]];
        [_tableView reloadData];
        
    } else {
         
         _imageView.image = image;
    }

    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [headerView addSubview:_imageView];
    
    _replaceAvatarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _imageView.frame.size.height + _imageView.frame.origin.y + 15, [UIScreen mainScreen].bounds.size.width, 30)];
    _replaceAvatarButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, _imageView.frame.size.height + _imageView.frame.origin.y + 15 + 0.5*_replaceAvatarButton.frame.size.height);
    
    [_replaceAvatarButton setTitle:@"更换头像" forState:UIControlStateNormal];
    _replaceAvatarButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [_replaceAvatarButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _replaceAvatarButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_replaceAvatarButton addTarget:self action:@selector(changeAvatar:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_replaceAvatarButton];
    
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

#pragma mark - 返回

- (void)back
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 确定按钮

- (void)determineButtonTapped:(UIButton *)sender
{
    NSLog(@"确定");
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
        
        _nicknameField = [[UITextField alloc] initWithFrame:CGRectMake(nicknameLabel.frame.origin.x+nicknameLabel.frame.size.width - 30, 10, screenWidth - (nicknameLabel.frame.origin.x + nicknameLabel.frame.size.width - 30) - 10, 30)];
        _nicknameField.delegate = self;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *name = [defaults objectForKey:@"name"];
        
        if (name != nil) {
            
            _nicknameField.text = name;
            
        } else {
        
            _nicknameField.text = @"";
        }
        
        _nicknameField.textColor = [UIColor lightGrayColor];
        _nicknameField.font = [UIFont systemFontOfSize:18.0f];
        _nicknameField.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview: _nicknameField];

        
    } else if (indexPath.row == 1) {
        
        UILabel *genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 30)];
        genderLabel.text = @"性别";
        genderLabel.font = [UIFont systemFontOfSize:16.0f];
        genderLabel.textColor = [UIColor blackColor];
        genderLabel.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:genderLabel];
        
        _sexField = [[UITextField alloc] initWithFrame:CGRectMake(genderLabel.frame.origin.x+genderLabel.frame.size.width - 30, 10, screenWidth - (genderLabel.frame.origin.x+genderLabel.frame.size.width - 30) - 10, 30)];
        _sexField.delegate = self;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSString *sex = [defaults objectForKey:@"sex"];
        
        if (sex != nil) {
            
            if ([sex isEqualToString:@"male"]) {
                
                _sexField.text = @"男";
                
            } else if ([sex isEqualToString:@"female"]) {
            
                _sexField.text = @"女";
            }
            
        } else {
        
            _sexField.text = @"";
        }
        
        _sexField.textColor = [UIColor lightGrayColor];
        _sexField.font = [UIFont systemFontOfSize:18.0f];
        _sexField.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview: _sexField];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _nicknameField) {
        _edited_name = _nicknameField.text;
    }
    
    if (textField == _sexField) {
        
        _edited_sex = _sexField.text;
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
