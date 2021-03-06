//
//  HYLForgetPasswordViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/14/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLForgetPasswordViewController.h"
//#import <AFNetworking.h>
#import <AFNetworking/AFNetworking.h>
#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"

#import "HaoYuLeNetworkInterface.h"

#import "HYLSignInViewController.h"

//#import <SVProgressHUD.h>
#import <SVProgressHUD/SVProgressHUD.h>

#define kLineViewBGColor(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]

@interface HYLForgetPasswordViewController ()<UITextFieldDelegate>
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
    
    UIButton *sendMessageButton;
}

@end

@implementation HYLForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // back
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 30, 30);
    [backButton setImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    // title view
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    titleLabel.text = @"忘记密码";
    titleLabel.font = [UIFont systemFontOfSize:18.0f];
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    // view
    [self prepareForgetPasswordView];
    
    // 确定按钮
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.frame = CGRectMake(10, [[UIScreen mainScreen] bounds].size.height - 260 - 64 , [[UIScreen mainScreen] bounds].size.width - 20, 50);
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    sureButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [sureButton setBackgroundImage:[UIImage imageNamed:@"determineIcon"] forState:UIControlStateNormal];
    [sureButton setBackgroundImage:[UIImage imageNamed:@"determineselected"] forState:UIControlStateHighlighted];
    [sureButton addTarget:self action:@selector(sureButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureButton];
}

- (void)prepareForgetPasswordView
{
    //
    UIImage *phoneImage = [UIImage imageNamed:@"phone"];
    _phoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10 + 5, 100, phoneImage.size.width, phoneImage.size.height)];
    _phoneImageView.image = phoneImage;
    [self.view addSubview:_phoneImageView];
    
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(_phoneImageView.frame.origin.x + _phoneImageView.frame.size.width + 3, _phoneImageView.frame.origin.y - 3, [[UIScreen mainScreen] bounds].size.width - (_phoneImageView.frame.size.width + _phoneImageView.frame.origin.x) - 90, 30)];
    _phoneTextField.delegate = self;
    _phoneTextField.placeholder = @"手机号码";
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneTextField.font = [UIFont systemFontOfSize:20.0f];
    _phoneTextField.textAlignment = NSTextAlignmentLeft;
    _phoneTextField.textColor = [UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0];
    [self.view addSubview:_phoneTextField];
    
    sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendMessageButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 110, _phoneTextField.frame.origin.y, 100, 30);
    [sendMessageButton setTitle:@"发送验证码" forState:UIControlStateNormal];
    sendMessageButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [sendMessageButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
    sendMessageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [sendMessageButton addTarget:self action:@selector(sendMessageButtonTap:) forControlEvents:UIControlEventTouchUpInside];
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
    _messageTextField.textColor = [UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0];
    [self.view addSubview:_messageTextField];
    
    _messageLineView = [[UIView alloc] initWithFrame:CGRectMake(_messageImageView.frame.origin.x, _messageTextField.frame.origin.y + _messageTextField.frame.size.height + 8, [UIScreen mainScreen].bounds.size.width - 20, 1)];
    _messageLineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_messageLineView];
    
    //
    UIImage *settingImage = [UIImage imageNamed:@"passwordIcon"];
    _settingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10 + 5, _messageImageView.frame.origin.y + _messageTextField.frame.size.height + 40, settingImage.size.width, settingImage.size.height)];
    _settingImageView.image = settingImage;
    [self.view addSubview:_settingImageView];
    
    _settingTextField = [[UITextField alloc] initWithFrame:CGRectMake(_settingImageView.frame.origin.x + _settingImageView.frame.size.width + 3, _settingImageView.frame.origin.y - 3, _phoneTextField.frame.size.width, 30)];
    _settingTextField.delegate = self;
    _settingTextField.placeholder = @"设置登录密码";
    _settingTextField.secureTextEntry = YES;
    _settingTextField.clearsOnBeginEditing = YES;
    _settingTextField.font = [UIFont systemFontOfSize:20.0f];
    _settingTextField.textAlignment = NSTextAlignmentLeft;
    _settingTextField.textColor = [UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0];
    [self.view addSubview:_settingTextField];
    
    _settingLineView = [[UIView alloc] initWithFrame:CGRectMake(10, _settingTextField.frame.origin.y + _settingTextField.frame.size.height + 8, [UIScreen mainScreen].bounds.size.width - 20, 1)];
    _settingLineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_settingLineView];
}

#pragma mark - 返回

- (void)backAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 发送信息

- (void)sendMessageButtonTap:(UIButton *)sender
{
    if (_phoneTextField.text.length > 0) {
        
        [self sendMessageApi];
        
    } else {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入手机号" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)sendMessageApi
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
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
//        NSLog(@"发送验证码返回: %@", reponse);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - 确定按钮响应

- (void)sureButtonTapped:(UIButton *)sender
{
    if (_phoneTextField.text.length == 0) {
        
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD showErrorWithStatus:@"请输入手机号"];
    }
    
    if (_messageTextField.text.length == 0) {
 
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
    }
    
    if (_settingTextField.text.length == 0) {

        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
    }
    
    if (_phoneTextField.text.length > 0 && _messageTextField.text.length > 0 && _settingTextField.text.length > 0) {
        
        [self findMyPasswordToServer]; // 请求到服务器
    }
}

- (void)findMyPasswordToServer
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:_phoneTextField.text forKey:@"mobile"];
    [dictionary setValue:_messageTextField.text forKey:@"captcha"];
    [dictionary setValue:_settingTextField.text forKey:@"newPassword"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kGetPasswordURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"找密码返回: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showSuccessWithStatus:@"找回密码成功"];
            
            HYLSignInViewController *signInVC = [[HYLSignInViewController alloc] init];
            [self.navigationController pushViewController:signInVC animated:YES];
            
        } else {
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showErrorWithStatus:@"找回密码失败"];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        
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
