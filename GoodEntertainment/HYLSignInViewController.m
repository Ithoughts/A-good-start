//
//  HYLSignOutViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/10/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLSignInViewController.h"
#import "HYLForgetPasswordViewController.h"
#import "HYLRegisterViewController.h"

#import <UIViewController+MMDrawerController.h>

#import "HaoYuLeNetworkInterface.h"
#import <AFNetworking.h>
#import "HYLGetSignature.h"
#import "HYLGetTimestamp.h"

#define kLineViewBGColor(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]

@interface HYLSignInViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UIImageView *passwordImageView;
@property (nonatomic, strong) UITextField *userTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIView *userlineView;
@property (nonatomic, strong) UIView *passwordlineView;

@property (nonatomic, strong) UIImageView *loginBgView;

@end

@implementation HYLSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.loginBgView = [[UIImageView alloc]  initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.loginBgView.image = [UIImage imageNamed:@"loginBG"];
    
    self.loginBgView.userInteractionEnabled = YES;
    
    [self.view addSubview:self.loginBgView];
    
    // navigation bar
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    
    // left bar button Item
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 40, 30);
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;

    // title view
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    titleLabel.text = @"登录";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:18.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    // right bar button Item
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shutdownIcon"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(shutdown:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self prepareSignInView];
}

- (void)prepareSignInView
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = rect.size.width;
    CGFloat screenHeight = rect.size.height;
    
    //
    UIImage *userImage = [UIImage imageNamed:@"userIcon"];
    self.userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 153, userImage.size.width, userImage.size.height)];
    self.userImageView.image = userImage;
    [self.loginBgView addSubview:self.userImageView];
    
    // 用户文本框
    self.userTextField = [[UITextField alloc] initWithFrame:CGRectMake(43, 150, screenWidth - 63 , 30)];
    self.userTextField.delegate = self;
    
    // 修改 placeholder 的字体颜色大小
    NSString *userholderText = @"手机号码";
    NSMutableAttributedString *userplaceholder = [[NSMutableAttributedString alloc] initWithString:userholderText];
    [userplaceholder addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, userholderText.length)];
    [userplaceholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0f] range:NSMakeRange(0, userholderText.length)];
    
    self.userTextField.attributedPlaceholder = userplaceholder;
    self.userTextField.font = [UIFont systemFontOfSize:15.0f];
    self.userTextField.textColor = [UIColor whiteColor];
    self.userTextField.textAlignment = NSTextAlignmentLeft;
    self.userTextField.autocorrectionType = NO;
    self.userTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.loginBgView addSubview:self.userTextField];
    
    // 线条
    self.userlineView = [[UIView alloc] initWithFrame:CGRectMake(self.userImageView.frame.origin.x, self.userTextField.frame.origin.y + self.userTextField.frame.size.height + 5, self.userImageView.frame.size.width + self.userTextField.frame.size.width, 1)];
    self.userlineView.backgroundColor = [UIColor lightGrayColor];
    [self.loginBgView addSubview:self.userlineView];
    
    //
    UIImage *passwordImage = [UIImage imageNamed:@"passwordIcon"];
    self.passwordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, self.userTextField.frame.origin.y + self.userTextField.frame.size.height + 10 + 3, passwordImage.size.width, passwordImage.size.height)];
    self.passwordImageView.image = passwordImage;
    [self.loginBgView addSubview:self.passwordImageView];
    
    // 密码文本框
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(43, self.userTextField.frame.origin.y + self.userTextField.frame.size.height + 10, screenWidth - 63 , 30)];
    self.passwordTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    
    // 修改 placeholder 的字体颜色大小
    NSString *passwordholderText = @"登录密码";
    NSMutableAttributedString *passwordplaceholder = [[NSMutableAttributedString alloc] initWithString:passwordholderText];
    [passwordplaceholder addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, passwordholderText.length)];
    [passwordplaceholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0f] range:NSMakeRange(0, passwordholderText.length)];

    self.passwordTextField.attributedPlaceholder = passwordplaceholder;
    self.passwordTextField.font = [UIFont systemFontOfSize:15.0f];
    self.passwordTextField.textColor = [UIColor whiteColor];
    self.passwordTextField.textAlignment = NSTextAlignmentLeft;
    [self.loginBgView addSubview:self.passwordTextField];
    
    // 线条
    self.passwordlineView = [[UIView alloc] initWithFrame:CGRectMake(self.passwordImageView.frame.origin.x, self.passwordTextField.frame.origin.y + self.passwordTextField.frame.size.height + 5, self.passwordImageView.frame.size.width + self.passwordTextField.frame.size.width, 1)];
    self.passwordlineView.backgroundColor = [UIColor lightGrayColor];
    [self.loginBgView addSubview:self.passwordlineView];

    // 登录按钮
    [self prepareLoginButton:screenWidth origin:self.passwordTextField.frame.origin];
    
    // 忘记密码按钮
    [self prepareForgetPasswordButton:screenWidth screenHeight:screenHeight];
    
    // 创建 分隔线
    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth * 0.5 + 10, screenHeight - 95, 1, 20)];
    dividerView.backgroundColor = [UIColor whiteColor];
    [self.loginBgView addSubview:dividerView];
    
    // 注册账号按钮
    [self prepareRegisterButton:screenWidth screenHeight:screenHeight];
}

#pragma mark - 创建 登录按钮
- (void)prepareLoginButton:(CGFloat)screenWidth  origin:(CGPoint)origin
{
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(20, origin.y + 30 + 50, screenWidth - 40, 40);
    [loginButton setBackgroundImage:[UIImage imageNamed:@"determineIcon"] forState:UIControlStateNormal];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    loginButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.loginBgView addSubview:loginButton];
}

#pragma mark - 创建 忘记密码 按钮
- (void)prepareForgetPasswordButton:(CGFloat)screenWidth screenHeight:(CGFloat)screenHeight
{
    UIButton *forgetPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetPasswordButton.frame = CGRectMake(screenWidth*0.5 - 120, screenHeight - 100, 120, 30);
    [forgetPasswordButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    forgetPasswordButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    forgetPasswordButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [forgetPasswordButton addTarget:self action:@selector(forgetPasswordButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.loginBgView addSubview:forgetPasswordButton];
}

#pragma mark - 创建 注册账号 按钮
- (void)prepareRegisterButton:(CGFloat)screenWidth screenHeight:(CGFloat)screenHeight
{
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registerButton.frame = CGRectMake(screenWidth*0.5 + 20, screenHeight - 100, 120, 30);
    [registerButton setTitle:@"注册账号" forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor colorWithRed:255.0/255.0f green:199.0/255.0f blue:3.0/255.0f alpha:1.0] forState:UIControlStateNormal];
    registerButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    registerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [registerButton addTarget:self action:@selector(registerButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.loginBgView addSubview:registerButton];
}

#pragma mark - 登录按钮 响应
- (void)loginButtonAction:(UIButton *)sender
{
//    NSLog(@"login button tapped!");
    [self login];
}

#pragma - 用户登录 响应

- (void)login
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:_userTextField.text forKey:@"mobile"];
    [dictionary setValue:_passwordTextField.text forKey:@"password"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kUserLoginURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"登录返回: \n%@", reponse);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error:   \n%@", error);
        
    }];
}

#pragma mark - 忘记密码 响应
- (void)forgetPasswordButtonTapped:(UIButton *)sender
{
    NSLog(@"忘记密码");
    
    
    HYLForgetPasswordViewController *forgetPasswordViewController = [[HYLForgetPasswordViewController alloc] init];
    [self.navigationController pushViewController:forgetPasswordViewController animated:NO];
}
#pragma mark - 注册账号 响应
- (void)registerButtonTapped:(UIButton *)sender
{
    NSLog(@"注册账号");
    
    HYLRegisterViewController *registerViewController = [[HYLRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerViewController animated:NO];
}

#pragma mark - 关闭登录界面
- (void)shutdown:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.userTextField) {
        self.userImageView.image = [UIImage imageNamed:@"userIconselected"];
        self.userlineView.backgroundColor = kLineViewBGColor(255, 199, 3);
    } else {
    
        self.userImageView.image = [UIImage imageNamed:@"userIcon"];
        self.userlineView.backgroundColor = [UIColor lightGrayColor];
    }
    
    if (textField == self.passwordTextField) {
        self.passwordImageView.image = [UIImage imageNamed:@"passwordfieldselected"];
        self.passwordlineView.backgroundColor = kLineViewBGColor(255, 199, 3);
    } else {
        self.passwordImageView.image = [UIImage imageNamed:@"passwordIcon"];
        self.passwordlineView.backgroundColor = [UIColor lightGrayColor];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.userImageView.image = [UIImage imageNamed:@"userIcon"];
    self.userlineView.backgroundColor = [UIColor lightGrayColor];
    
    self.passwordImageView.image = [UIImage imageNamed:@"passwordIcon"];
    self.passwordlineView.backgroundColor = [UIColor lightGrayColor];
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
