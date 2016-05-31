//
//  HYLRegisterViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/14/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLRegisterViewController.h"

#import "HYLSignInViewController.h"

// 网络请求
#import <AFNetworking.h>

// 时间戳
#import "HYLGetTimestamp.h"

// 签名
#import "HYLGetSignature.h"

// api 接口
#import "HaoYuLeNetworkInterface.h"

#import <SVProgressHUD.h>

#define kLineViewBGColor(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]

@interface HYLRegisterViewController ()<UITextFieldDelegate>
{
    UIImageView *_phoneImageView;
    UITextField *_phoneTextField;
    UIView *_phoneLineView;
    
    UIImageView *_messageImageView;
    UITextField *_messageTextField;
    UIView *_messageLineView;
    
    UIImageView *_settingImageView;
    UITextField *_settingTextField;
    UIView *_settingLineView;
    
    NSString *_phoneNumber;
    NSString *_messageCode;
    NSString *_loginPassword;
    
    NSString *_username;
    NSString *_sex;
}

@end

@implementation HYLRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 硬编码
    _username = @"好娱乐";
    _sex      = @"male";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 30, 30);
    [backButton setImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    titleLabel.text = @"新用户注册";
    titleLabel.font = [UIFont systemFontOfSize:18.0f];
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    [self prepareRegisterView];
    
    UIButton *agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    agreeButton.frame = CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 250, [[UIScreen mainScreen] bounds].size.width - 20, 50);
    [agreeButton setTitle:@"同意并注册" forState:UIControlStateNormal];
    agreeButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    agreeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [agreeButton setBackgroundImage:[UIImage imageNamed:@"determineIcon"] forState:UIControlStateNormal];
    [agreeButton addTarget:self action:@selector(agreeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:agreeButton];
}

- (void)prepareRegisterView
{
    //
    UIImage *phoneImage = [UIImage imageNamed:@"phone"];
    _phoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10 + 5, 100, phoneImage.size.width, phoneImage.size.height)];
    _phoneImageView.image = phoneImage;
    [self.view addSubview:_phoneImageView];
    
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(_phoneImageView.frame.origin.x + _phoneImageView.frame.size.width + 3, _phoneImageView.frame.origin.y - 3, [[UIScreen mainScreen] bounds].size.width - (_phoneImageView.frame.origin.x + _phoneImageView.frame.size.width) - 90, 30)];
    _phoneTextField.delegate = self;
    _phoneTextField.placeholder = @"手机号码";
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.font = [UIFont systemFontOfSize:20.0f];
    _phoneTextField.textAlignment = NSTextAlignmentLeft;
    _phoneTextField.textColor = kLineViewBGColor(255, 199, 3);
    [self.view addSubview:_phoneTextField];
    
    UIButton *sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendMessageButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 110, _phoneTextField.frame.origin.y, 100, 30);
    [sendMessageButton setTitle:@"发送验证码" forState:UIControlStateNormal];
    sendMessageButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [sendMessageButton setTitleColor:[UIColor colorWithRed:255/255.0f green:190/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
    sendMessageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [sendMessageButton addTarget:self action:@selector(sendMessageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendMessageButton];
    
    //
    _phoneLineView = [[UIView alloc] initWithFrame:CGRectMake(10, _phoneTextField.frame.origin.y + _phoneTextField.frame.size.height + 8, [UIScreen mainScreen].bounds.size.width - 20, 1)];
    _phoneLineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_phoneLineView];
    
    //
    UIImage *messageImage = [UIImage imageNamed:@"message"];
    _messageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, _phoneImageView.frame.origin.y + _phoneTextField.frame.size.height + 40, messageImage.size.width, messageImage.size.height)];
    _messageImageView.image = messageImage;
    [self.view addSubview:_messageImageView];
    
    _messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(_messageImageView.frame.origin.x + _messageImageView.frame.size.width + 3, _messageImageView.frame.origin.y - 3, _phoneTextField.frame.size.width, 30)];
    _messageTextField.delegate = self;
    _messageTextField.placeholder = @"短信验证码";
    _messageTextField.keyboardType = UIKeyboardTypeNumberPad;
    _messageTextField.font = [UIFont systemFontOfSize:20.0f];
    _messageTextField.textAlignment = NSTextAlignmentLeft;
    _messageTextField.textColor = kLineViewBGColor(255, 199, 3);
    [self.view addSubview:_messageTextField];
    
    _messageLineView = [[UIView alloc] initWithFrame:CGRectMake(_messageImageView.frame.origin.x, _messageTextField.frame.origin.y + _messageTextField.frame.size.height + 8, [UIScreen mainScreen].bounds.size.width - 20, 1)];
    _messageLineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_messageLineView];
    
    //
    UIImage *setttingImage = [UIImage imageNamed:@"passwordIcon"];
    _settingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10 + 5, _messageImageView.frame.origin.y + _messageTextField.frame.size.height + 40, setttingImage.size.width, setttingImage.size.height)];
    _settingImageView.image = setttingImage;
    [self.view addSubview:_settingImageView];
    
    _settingTextField = [[UITextField alloc] initWithFrame:CGRectMake(_settingImageView.frame.origin.x + _settingImageView.frame.size.width + 3, _settingImageView.frame.origin.y - 3, _phoneTextField.frame.size.width, 30)];
    _settingTextField.delegate = self;
    _settingTextField.placeholder = @"设置登录密码";
    _settingTextField.secureTextEntry = YES;
    _settingTextField.clearsOnBeginEditing = YES;
    _settingTextField.font = [UIFont systemFontOfSize:20.0f];
    _settingTextField.textAlignment = NSTextAlignmentLeft;
    _settingTextField.textColor = kLineViewBGColor(255, 199, 3);
    [self.view addSubview:_settingTextField];
    
    _settingLineView = [[UIView alloc] initWithFrame:CGRectMake(10, _settingTextField.frame.origin.y + _settingTextField.frame.size.height + 8, [UIScreen mainScreen].bounds.size.width - 20, 1)];
    _settingLineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_settingLineView];

    
    UILabel *someLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _settingLineView.frame.origin.y + _settingLineView.frame.size.height + 50, ([UIScreen mainScreen].bounds.size.width - 20)*0.5, 30)];
    someLabel.text = @"我已阅读并同意";
    someLabel.textColor = [UIColor lightGrayColor];
    someLabel.textAlignment = NSTextAlignmentRight;
    someLabel.font = [UIFont systemFontOfSize:18.0f];
    [self.view addSubview:someLabel];
    
    UIButton *provisionButton = [UIButton buttonWithType: UIButtonTypeCustom];
    provisionButton.frame = CGRectMake(someLabel.frame.origin.x + someLabel.frame.size.width - 28, someLabel.frame.origin.y, someLabel.frame.size.width, 30);
    [provisionButton setTitle:@"好娱乐用户条款" forState:UIControlStateNormal];
    [provisionButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
    provisionButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    provisionButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [provisionButton addTarget:self action:@selector(provisionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:provisionButton];
}

#pragma mark - 返回按钮响应

- (void)back:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 发送验证码按钮响应

- (void)sendMessageButtonTapped:(UIButton *)sender
{
    if (_phoneTextField.text != nil) {
        
        [self sendMessageApiRequest];
        
    } else {
    
        [SVProgressHUD showErrorWithStatus:@"请输入手机号"];
    }
}

#pragma mark -  发送验证码

- (void)sendMessageApiRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:_phoneTextField.text forKey:@"mobile"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kSendCaptchaURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSString *reponse = [[NSString alloc] initWithData:responseObject
                                                  encoding:NSUTF8StringEncoding];
        NSLog(@"发送验证码: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showSuccessWithStatus:@"发送验证码成功"];
           
        } else {
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showErrorWithStatus:@"发送验证码失败"];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error:%@", error);
        
    }];
}

#pragma mark - 条款 按钮响应

- (void)provisionButtonTapped:(UIButton *)sender
{
    NSLog(@"条款按钮被按!");
}

#pragma mark - 同意并注册 按钮响应

- (void)agreeButtonTapped:(UIButton *)sender
{
    if (_phoneTextField.text == nil || _phoneTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号码"];
    }
    
    if (_messageTextField.text == nil || _messageTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
    }
    
    if (_settingTextField.text == nil || _settingTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
    }
    
//    NSLog(@"同意并注册");
    if (_phoneTextField.text.length > 0 && _messageTextField.text.length > 0 && _settingTextField.text.length > 0) {
        
        [self registerApiSend];
    }
}

#pragma mark - 注册请求

- (void)registerApiSend
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    
    [dictionary setValue:_phoneTextField.text forKey:@"mobile"];
    [dictionary setValue:_messageCode forKey:@"captcha"];
    [dictionary setValue:_loginPassword forKey:@"password"];
    
    [dictionary setValue:_username forKey:@"username"];
    [dictionary setValue:_sex forKey:@"sex"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kUserRegisterURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSString *reponse = [[NSString alloc] initWithData:responseObject
                                                  encoding:NSUTF8StringEncoding];
        NSLog(@"注册返回: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showSuccessWithStatus:@"注册成功"];
            
            HYLSignInViewController *signInVC = [[HYLSignInViewController alloc] init];
            [self.navigationController pushViewController:signInVC animated:YES];
            
        } else {
            
            NSString *message = responseDic[@"message"];
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showErrorWithStatus:message];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error:%@", error);
        
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _phoneTextField) {
        _phoneImageView.image = [UIImage imageNamed:@"phoneselected"];
        _phoneLineView.backgroundColor = kLineViewBGColor(255, 199, 3);
    } else  {
        _phoneImageView.image = [UIImage imageNamed:@"phone"];
        _phoneLineView.backgroundColor = [UIColor lightGrayColor];
    }
    
    if (textField == _messageTextField) {
        _messageImageView.image = [UIImage imageNamed:@"messageselected"];
        _messageLineView.backgroundColor = kLineViewBGColor(255, 199, 3);
    } else  {
        _messageImageView.image = [UIImage imageNamed:@"message"];
        _messageLineView.backgroundColor = [UIColor lightGrayColor];
    }
    
    if (textField == _settingTextField) {
        _settingImageView.image = [UIImage imageNamed:@"passwordfieldselected"];
        _settingLineView.backgroundColor = kLineViewBGColor(255, 199, 3);
    } else  {
        _settingImageView.image = [UIImage imageNamed:@"passwordIcon"];
        _settingLineView.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _phoneImageView.image = [UIImage imageNamed:@"phone"];
    _phoneLineView.backgroundColor = [UIColor lightGrayColor];
    
    _messageImageView.image = [UIImage imageNamed:@"message"];
    _messageLineView.backgroundColor = [UIColor lightGrayColor];
    
    _settingImageView.image = [UIImage imageNamed:@"passwordIcon"];
    _settingLineView.backgroundColor = [UIColor lightGrayColor];
    
    
    if (textField == _phoneTextField) {
        
        _phoneNumber = _phoneTextField.text;
        
    } else if (textField == _settingTextField) {
    
        _loginPassword = _settingTextField.text;
        
    } else if (textField == _messageTextField) {
    
        _messageCode = _messageTextField.text;
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
