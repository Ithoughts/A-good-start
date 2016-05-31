//
//  HYLJingCaiDetailedInfoViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 4/7/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLJingCaiDetailedInfoViewController.h"

#import "HYLZhiBoListModel.h"
#import "HYLVideoCommentCell.h"

#import "HYLSignInViewController.h"

#import <AFNetworking.h>
#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import "HaoYuLeNetworkInterface.h"

#import <SDWebImage/UIImageView+WebCache.h>

// 视频播放
#import "XLVideoPlayer.h"

#import <UMengSocialCOM/UMSocialSnsService.h>
#import <UMSocialSnsPlatformManager.h>


@interface HYLJingCaiDetailedInfoViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UMSocialUIDelegate>
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;

    UIImageView *_videoImageView;
    UIButton *_playVideoButton;
    NSString *_video_url;
    
    //
    UIButton *_videoDescriptionButton;
    UIButton *_commentButton;
    UIView *_indicatorView;
    
    //
    UIScrollView *_decriptionScrollView;
    NSMutableArray *_dataArray;
    
    //
    UITableView *_commentTableView;
    
    //
    UILabel *_titleLabel;
    UILabel *_playLabel;
    
    //
    UIButton *_shareButton;
    UIButton *_collectButton;
    UIButton *_videoDecripCommentButton;
    UILabel *_decriptionLabel;
    
    //
    UIImageView *_playVideoImage;
    
    NSString *_cover_url;
    
    //
    UIScrollView *_descripScrollView;
    
    //
    UILabel *_commentTipLabel;
    UIImageView *_commentTipImageView;
    
    
    //
    UIView *bottomView;
    
    //
    NSString *_token;
}

@property (nonatomic, strong) XLVideoPlayer *player;

@end

@implementation HYLJingCaiDetailedInfoViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _token = [defaults objectForKey:@"token"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [self HYLJingCaiDetailInfoApiRequest];
    
    [self prepareJingCaiNavigationBar];
}

- (XLVideoPlayer *)player {
    
    if (!_player) {
        _player = [[XLVideoPlayer alloc] init];
        _player.frame = CGRectMake(0, 64, self.view.frame.size.width, 250);
    }
    
    return _player;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player destroyPlayer];
    _player = nil;
}

#pragma mark - 播放视频

- (void)showVideoPlayer:(UITapGestureRecognizer *)tapGesture
{
    [_player destroyPlayer];
    _player = nil;
    
    UIView *view = tapGesture.view;
    
    _player = [[XLVideoPlayer alloc] init];
    _player.videoUrl = _video_url;
    _player.frame = view.bounds;
    
    [view addSubview:_player];
    
    _player.completedPlayingBlock = ^(XLVideoPlayer *player) {
        [player destroyPlayer];
        _player = nil;
    };
}

#pragma mark - 导航栏

- (void)prepareJingCaiNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 30)];
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:18.0f];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = self.jingCaiTitle;
    
    UINavigationItem *navItem = self.navigationItem;
    navItem.titleView = title;
    
    //
    UIImage *image = [UIImage imageNamed:@"backIcon"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [leftButton setImage:image forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    navItem.leftBarButtonItem = left;
}

#pragma mark - 返回

- (void)goBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 视图

- (void)prepareJingCaiView
{
    // 视频截图
    _videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, (self.imageHeight/self.imageWidth)*_screenWidth)];
    _videoImageView.clipsToBounds = YES;
    _videoImageView.userInteractionEnabled = YES;
    _videoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_videoImageView sd_setImageWithURL:[NSURL URLWithString:_cover_url] completed:nil];
    [self.view addSubview:_videoImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showVideoPlayer:)];
    [_videoImageView addGestureRecognizer:tap];
    
    // 视频播放
    UIImage *image = [UIImage imageNamed:@"playBtn"];
    _playVideoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    _playVideoImage.center = CGPointMake(_videoImageView.frame.size.width * 0.5, _videoImageView.frame.size.height * 0.5);
    _playVideoImage.image = image;
    _playVideoImage.userInteractionEnabled = YES;
    
    [_videoImageView addSubview:_playVideoImage];
    
    //
    [self createTwoButtons];
    
    _descripScrollView = [self createVideoDecriptionView];
    
    //
    [self.view addSubview:_decriptionScrollView];
}

#pragma mark - 创建按钮

- (void)createTwoButtons
{
    //
    _videoDescriptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _videoDescriptionButton.frame = CGRectMake(0, _videoImageView.frame.origin.y + _videoImageView.frame.size.height, _screenWidth * 0.5, 30);
    [_videoDescriptionButton setTitle:@"影片描述" forState:UIControlStateNormal];
    [_videoDescriptionButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
    _videoDescriptionButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    _videoDescriptionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _videoDescriptionButton.tag = 1000;
    [_videoDescriptionButton addTarget:self action:@selector(twoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_videoDescriptionButton];
    
    //
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentButton.frame = CGRectMake(_screenWidth * 0.5, _videoImageView.frame.origin.y + _videoImageView.frame.size.height, _screenWidth * 0.5, 30);
    [_commentButton setTitle:@"评论" forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _commentButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    _commentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _commentButton.tag = 1001;
    [_commentButton addTarget:self action:@selector(twoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_commentButton];
    
    //
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, _videoDescriptionButton.frame.origin.y + _videoDescriptionButton.frame.size.height + 0.5, _screenWidth, 0.5)];
    backgroundView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:backgroundView];
    
    //
    _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, _videoDescriptionButton.frame.origin.y + _videoDescriptionButton.frame.size.height + 0.5, _screenWidth * 0.5, 1)];
    _indicatorView.backgroundColor = [UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f];
    [self.view addSubview:_indicatorView];
}

#pragma mark - 分段

- (void)twoButtonAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 1000:
        {
            if (_commentTableView != nil) {
                
                [_commentTableView removeFromSuperview];
            }
            
            if (_commentTipImageView != nil && _commentTipLabel != nil) {
                [_commentTipImageView removeFromSuperview];
                [_commentTipLabel     removeFromSuperview];
            }
            
            [self changeIndicatorViewOriginX:0];
            [_videoDescriptionButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [_commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            
            // 添加到当前视图
            _descripScrollView = [self createVideoDecriptionView];
            
            [self.view addSubview:_decriptionScrollView];
        }
            break;
            
        case 1001:
        {
            if (_descripScrollView != nil) {
                
                [_descripScrollView removeFromSuperview];
            }
            
            [self changeIndicatorViewOriginX:_screenWidth * 0.5];
            [_videoDescriptionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [_commentButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
            
            [self getJingCaiVideoCommentsRequest];
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 影片描述视图

- (UIScrollView *)createVideoDecriptionView
{
    HYLZhiBoListModel *model = _dataArray[0];
    
    _decriptionScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5, _screenWidth, _screenHeight - (_indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5))];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _decriptionScrollView.frame.size.width, _decriptionScrollView.frame.size.height)];
    headerView.userInteractionEnabled = YES;
    headerView.backgroundColor = [UIColor clearColor];
        
    //
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, _screenWidth, 30)];
    _titleLabel.text = self.jingCaiTitle;
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [headerView addSubview:_titleLabel];
        
    //
    _playLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, _screenWidth, 30)];
    _playLabel.text = [NSString stringWithFormat:@"播放: %@", model.view_count];
    _playLabel.textColor = [UIColor lightGrayColor];
    _playLabel.textAlignment = NSTextAlignmentLeft;
    _playLabel.font = [UIFont systemFontOfSize:16.0f];
    [headerView addSubview:_playLabel];
        
    //
    _shareButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"jingcaishare"] title:@"分享" x:5 tag:100];
    [headerView addSubview:_shareButton];
        
    _collectButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"myCollectionIcon"] title:@"收藏" x:_screenWidth * 1 / 3.0 tag:101];
    [headerView addSubview:_collectButton];
        
    _videoDecripCommentButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"jingcaicomment"] title:@"评论" x:_screenWidth * 2 / 3.0 tag:102];
    [headerView addSubview:_videoDecripCommentButton];
    
    //
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _shareButton.frame.origin.y + _shareButton.frame.size.height, _screenWidth, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:line];
        
    //
    NSString *html = model.summary;
    
    NSData *data = [html dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSAttributedString *attributeHtml = [[NSAttributedString alloc] initWithData:data
                                                                         options:options
                                                              documentAttributes:nil
                                                                           error:nil];
    
    CGRect htmlRect = [attributeHtml boundingRectWithSize:CGSizeMake(_screenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    _decriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, line.frame.origin.y + 15, _screenWidth - 20, htmlRect.size.height)];
    _decriptionLabel.attributedText = attributeHtml;
    _decriptionLabel.font = [UIFont systemFontOfSize:16.0f];
    _decriptionLabel.textColor = [UIColor lightGrayColor];
    
    [_decriptionLabel sizeThatFits:htmlRect.size];
    
    [headerView addSubview:_decriptionLabel];
    
    headerView.frame = CGRectMake(0, 0, _decriptionScrollView.frame.size.width, _decriptionLabel.frame.origin.y +_decriptionLabel.frame.size.height);
    
    [_decriptionScrollView addSubview:headerView];
    
    _decriptionScrollView.contentSize = CGSizeMake(_screenWidth, _decriptionLabel.frame.origin.y +_decriptionLabel.frame.size.height);
    
    
    return _decriptionScrollView;
}

#pragma mark - 创建评论列表

- (UITableView *)createCommentTableView
{
    _commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5, _screenWidth, _screenHeight -(_indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5)) style:UITableViewStylePlain];
    _commentTableView.dataSource = self;
    _commentTableView.delegate = self;
    _commentTableView.showsVerticalScrollIndicator = NO;
    _commentTableView.showsHorizontalScrollIndicator = NO;
    _commentTableView.tableFooterView = [[UIView alloc] init];
    
    return _commentTableView;
}

#pragma mark - 创建 buttons 

- (UIButton *)createCommonButtonWithImage:(UIImage *)image title:(NSString *)title x:(CGFloat)x tag:(NSUInteger)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(x, _playLabel.frame.origin.y + _playLabel.frame.size.height, _screenWidth * 1/3.0, 30);
    button.tag = tag;
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f );
    [button addTarget:self action:@selector(threeButtonsAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - 分享、收藏、评论

- (void)threeButtonsAction:(UIButton *)sender
{
    switch (sender.tag) {
            
        case 100:
        {
            [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://baidu.com";
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://baidu.com";
            [UMSocialData defaultData].extConfig.wechatSessionData.title = @"微信好友title";
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"微信朋友圈title";
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeText;
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
            
            //如果需要分享回调，请将delegate对象设置self，并实现下面的回调方法
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:@"57396808e0f55a0902001ba4"
                                              shareText:@"分享到微信"
                                             shareImage:[UIImage imageNamed:@"icon"]
                                        shareToSnsNames:@[UMShareToWechatSession, UMShareToWechatTimeline]
                                               delegate:self];

        }
            break;
            
        case 101:
        {
//            NSLog(@"收藏");
            
            if (_token != nil && _token.length > 0) {
                
                [self collectVideo];
                
            } else {
            
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请先登录" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];
                
                HYLSignInViewController *loginVC = [[HYLSignInViewController alloc] init];
                [self.navigationController pushViewController:loginVC animated:YES];
            }
            
        }
            break;
            
        case 102:
        {
            NSLog(@"评论");
            
            if (_token != nil && _token.length > 0) {
                
                
            } else {
                
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请先登录" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];
                
                HYLSignInViewController *loginVC = [[HYLSignInViewController alloc] init];
                [self.navigationController pushViewController:loginVC animated:YES];
            }

        }
            break;
            
        default:
            break;
    }
}


#pragma mark - 实现回调方法：

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
//        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}


#pragma mark - 收藏视频

- (void)collectVideo
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:self.videoId         forKey:@"video_id"];
    [dictionary setValue:timestamp            forKey:@"time"];
    [dictionary setValue:signature            forKey:@"sign"];
    
    // HTTP Basic Authorization 认证机制
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", _token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    [manager POST:kAddFavoriteVideoURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"收藏视频返回:%@", string);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            
            if ([responseDic[@"message"] isEqualToString:@"目标已被收藏"]) {
                
                UIAlertView *tip = [[UIAlertView alloc] initWithTitle:@"已收藏" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [tip show];
                
            } else {
                
                UIAlertView *tip = [[UIAlertView alloc] initWithTitle:@"收藏成功" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [tip show];
            }
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - 获取 token

//- (NSString *)getToken
//{
//    __block NSString *token = nil;
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    [manager POST:kGetUserTokenURL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//        
//        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"获取用户 token 返回:%@", string);
//        
//        token = string;
//        
//    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//        
//        NSLog(@"error: %@", error);
//    }];
//    
//    return token;
//}

- (UIView *)createCommentView
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, _screenHeight - 50, _screenWidth, 50)];
    commentView.backgroundColor = [UIColor lightGrayColor];
    
    UITextField *commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, commentView.frame.size.width - 10, 40)];
    commentTextField.delegate = self;
    commentTextField.placeholder = @"点击评论...";
    commentTextField.clearsOnBeginEditing = YES;
    commentTextField.background = [UIImage imageNamed:@"textfieldbackground"];
    [commentView addSubview:commentTextField];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(commentTextField.frame.size.width - 55, 10, 50, 30);
    [sendButton setTitle:@"发表" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:199.0/255.0 blue:3/255.0 alpha:1.0] forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [sendButton addTarget:self action:@selector(sendCommentToServer:) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:sendButton];
    
    return commentView;
}

#pragma mark - 发表评论

- (void)sendCommentToServer:(UIButton *)sender
{
//    NSLog(@"评论完毕");
}

#pragma mark - 改变指示器的位置

- (void)changeIndicatorViewOriginX:(CGFloat)x
{
    _indicatorView.frame = CGRectMake(x, _videoDescriptionButton.frame.origin.y + _videoDescriptionButton.frame.size.height + 0.5, _screenWidth * 0.5, 1);
}

#pragma mark - 网络请求

- (void)HYLJingCaiDetailInfoApiRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:self.videoId forKey:@"id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kShiPinDetailURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"好精彩详情: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        
        _dataArray = [[NSMutableArray alloc] init];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *dataDic = responseDic[@"data"];
            
            HYLZhiBoListModel *model = [[HYLZhiBoListModel alloc] initWithDictionary:dataDic];
            [_dataArray addObject:model];
            
            // 视频地址
            _video_url = model.video_info.url;
            
            _cover_url = model.video_info.cover_url;
            
            [self prepareJingCaiView];
            
        } else {
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
//        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - 获取视频评论

- (void)getJingCaiVideoCommentsRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:self.videoId forKey:@"id"];
//    [dictionary setValue:@"1" forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kGetVideoCommentURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject
//                                                  encoding:NSUTF8StringEncoding];
//        NSLog(@"好精彩评论列表: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            // 添加到当前视图
            [self.view addSubview:[self createCommentTableView]];
            
        } else {
            
            UIImage *backgroundImage = [UIImage imageNamed:@"tip"];
            
            // 背景
            _commentTipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
            _commentTipImageView.image = backgroundImage;
            _commentTipImageView.center = CGPointMake(self.view.frame.size.width * 0.5, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5+ (_screenHeight - (_indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5))*0.5 - 0.5 * backgroundImage.size.height);
            [self.view addSubview:_commentTipImageView];
            
            // 标签
            _commentTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 - 60, _commentTipImageView.frame.origin.y + _commentTipImageView.frame.size.height + 5, 120, 30)];
            _commentTipLabel.text = @"暂无评论";
            _commentTipLabel.font = [UIFont systemFontOfSize:16.0f];
            _commentTipLabel.textColor = [UIColor blackColor];
            _commentTipLabel.textAlignment = NSTextAlignmentCenter;
            
            [self.view addSubview:_commentTipLabel];
        }

    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
//        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark -  UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _commentTableView) {
        
        return 0;
        
    } else {
    
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HYLVideoCommentCell *cell = nil;
    
    if (tableView == _commentTableView) {
        
        static NSString *CellIdentifier = @"CellIdentifier";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            
            cell = [[HYLVideoCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
     return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (tableView == _commentTableView) {
        height = 105;
    }
    
    return height;
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
