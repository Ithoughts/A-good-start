//
//  HYLEditProfileViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/10/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLEditProfileViewController.h"


#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <ActionSheetPicker_3_0/ActionSheetStringPicker.h>


#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import "HaoYuLeNetworkInterface.h"

@interface HYLEditProfileViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
{
    UITableView *_tableView;
    
    UIImageView *_imageView;
    UIButton    *_replaceAvatarButton;
    
    UITextField *_nicknameField;
    UILabel *_sexLabel;
    
    NSString    *_edited_name;
    NSString    *_edited_sex;
    
    //
    NSString       *avatar;
    
    //
    UIImage *_photoImage;
    
    //
    NSString *_token;
}

@end

@implementation HYLEditProfileViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _token                   = [defaults objectForKey:@"token"];
}

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
    
    //
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    avatar   = [defaults objectForKey:@"avatar"];
    
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
    _imageView.layer.cornerRadius  = 10.0f;
    _imageView.layer.masksToBounds = YES;
    _imageView.clipsToBounds = YES;
    _imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeAvatar)];
    [_imageView addGestureRecognizer:tap];
   
    if (avatar != nil) {
        
        [_imageView sd_setImageWithURL:[NSURL URLWithString:avatar]];
        [_tableView reloadData];
        
    } else {
         
         _imageView.image = image;
    }

    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [headerView addSubview:_imageView];
    
    _replaceAvatarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _imageView.frame.size.height + _imageView.frame.origin.y + 15, [UIScreen mainScreen].bounds.size.width, 30)];
    _replaceAvatarButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, _imageView.frame.size.height + _imageView.frame.origin.y + 15 + 0.5*_replaceAvatarButton.frame.size.height);
    
    [_replaceAvatarButton setTitle:@"更换头像" forState:UIControlStateNormal];
    _replaceAvatarButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [_replaceAvatarButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _replaceAvatarButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_replaceAvatarButton addTarget:self action:@selector(changeAvatar) forControlEvents:UIControlEventTouchUpInside];
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
    if (_sexLabel.text.length > 0 && _sexLabel.text != nil && _nicknameField.text.length > 0 && _nicknameField.text != nil) {
        
        [self uploadNicknameAndSexToServer]; // 修改信息上传服务器
        
    } else {
    
        [SVProgressHUD showErrorWithStatus:@"昵称和性别不为空"];
    }
}

#pragma mark - 更改昵称、性别上传服务器

- (void)uploadNicknameAndSexToServer
{
    [SVProgressHUD show];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:_edited_sex forKey:@"sex"];
    [dictionary setValue:_edited_name forKey:@"username"];
    
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", _token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    [manager POST:kEditUserInfoURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"更改用户信息返回: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *dataDic = responseDic[@"data"];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            [userDefaults       setObject:dataDic[@"name"]                forKey:@"name"];
            [userDefaults       setObject:dataDic[@"sex"]                 forKey:@"sex"];
            [userDefaults       setObject:dataDic[@"avatar"]              forKey:@"avatar"];
            
            [userDefaults synchronize];
            [_tableView reloadData];
            
            // 通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"logined" object:nil];
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            
        } else {
            
            NSString *message = responseDic[@"message"];
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showErrorWithStatus:message];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
    }];
}

#pragma mark - 更换头像

- (void)changeAvatar
{
    [self chooseImage];
}

- (void)chooseImage {

    UIActionSheet *sheet;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"更换头像"
                                            delegate:self
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:@"取消"
                                   otherButtonTitles:@"拍照", @"从相册选择", nil];
    } else {
    
        sheet = [[UIActionSheet alloc] initWithTitle:@"更换头像"
                                            delegate:self
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:@"取消"
                                   otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                    
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                    
                default:
                    break;
            }
            
        } else {
        
            if (buttonIndex == 0) {
                
                return;
                
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.sourceType = sourceType;
        pickerController.delegate = self;
        
        [self presentViewController:pickerController animated:YES completion:nil];
    }
}

#pragma mark - 上传照片

- (void)UploadAvatar
{
    [SVProgressHUD show];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", _token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    /**
     *  post : 上传的网址
     *
     *  parameters 服务器需要上传的参数
     *
     */
    [manager POST:kUploadAvatarURL parameters:dictionary constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        /*   参数说明：
         1. fileData:   要上传文件的数据
         2. name:       负责上传文件的远程服务中接收文件使用的字段名称
         3. fileName：   要上传文件的文件名
         4. mimeType：   要上传文件的文件类型
      */
        NSData *fileData = UIImageJPEGRepresentation(_photoImage, 0.5);
        
        // 1) 取当前系统时间
        NSDate *date = [NSDate date];
        
        // 2) 使用日期格式化工具
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        // 3) 指定日期格式
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        
        NSString *dateStr = [formatter stringFromDate:date];
        
        // 4) 使用系统时间生成一个文件名
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", dateStr];
        
        [formData appendPartWithFileData:fileData name:@"avatar" fileName:fileName mimeType:@"image/jpg/png/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"response string: %@", response);
        
        NSError *error;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        NSString *message = responseDict[@"message"];
        NSString *resCode = responseDict[@"resCode"];
        
        if ([resCode isEqualToString:@"1"]) {
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showSuccessWithStatus:message];
            
        } else {
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showErrorWithStatus:message];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
    }];
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
        
        _sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(genderLabel.frame.origin.x+genderLabel.frame.size.width - 30, 10, screenWidth - (genderLabel.frame.origin.x+genderLabel.frame.size.width - 30) - 10, 30)];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *sex = [defaults objectForKey:@"sex"];
        
        if (sex != nil) {
            
            if ([sex isEqualToString:@"male"]) {
                
                _sexLabel.text = @"男";
                
            } else if ([sex isEqualToString:@"female"]) {
            
                _sexLabel.text = @"女";
            }
            
        } else {
        
            _sexLabel.text = @"";
        }
        
        _sexLabel.textColor = [UIColor lightGrayColor];
        _sexLabel.font = [UIFont systemFontOfSize:18.0f];
        _sexLabel.textAlignment = NSTextAlignmentRight;
        
        [cell.contentView addSubview: _sexLabel];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sexArray = @[@"男", @"女"];
    
    if (indexPath.row == 1) {
        
        [ActionSheetStringPicker showPickerWithTitle:@"请选择性别" rows:sexArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            _sexLabel.text = selectedValue;
            
            if ([selectedValue isEqualToString:@"男"]) {
                
                _edited_sex = @"male";
                
            } else {
            
                _edited_sex = @"female";
            }
            
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
            
        } origin:self.view];
    }
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
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    _photoImage = info[UIImagePickerControllerOriginalImage];
    _imageView.image = _photoImage;
    _imageView.layer.cornerRadius = 10.0f;
    _imageView.layer.masksToBounds = YES;
    _imageView.clipsToBounds = YES;
    
    // 上传服务器
    [self UploadAvatar];
}

#pragma mark  点击了取消按钮

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // 取消
    [picker dismissViewControllerAnimated:YES completion:nil];
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
