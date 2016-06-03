//
//  HYLZhiBoInformationViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 4/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLZhiBoInformationViewController.h"

#import "HYLZhiBoListModel.h"
#import "HYLVideoCommentCell.h"
#import "HYLCommentCell.h"

#import "HYLSignInViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import "HaoYuLeNetworkInterface.h"

// 视频播放
#import "XLVideoPlayer.h"

#import <UMengSocialCOM/UMSocialSnsService.h>
#import <UMSocialSnsPlatformManager.h>

#import <SVProgressHUD/SVProgressHUD.h>
#import <MJRefresh/MJRefresh.h>
#import "HYLCommentModel.h"

// 评论视图
#import "HYLSendCommentView.h"

@interface HYLZhiBoInformationViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate, UMSocialUIDelegate>
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    UIImageView *_videoImageView;
    NSString    *_video_url;
    
    //
    UIButton *_videoDescriptionButton;
    UIButton *_commentButton;
    UIView   *_indicatorView;
    
    // 容器 滚动视图
    UIScrollView *_mainScrollView;
    
    //
    UIScrollView *_decriptionScrollView;
    UITableView  *_commentTableView;
    
    // 影片数组
    NSMutableArray *_dataArray;
    
    //
    UILabel *_titleLabel;
    UILabel *_playLabel;
    
    //
    UIButton *_shareButton;
    UIButton *_collectButton;
    UIButton *_videoDecripCommentButton;
    UILabel  *_decriptionLabel;
    
    //
    UIImageView *_playVideoImage;
    NSString    *_cover_url;
    
    //
    UILabel     *_commentTipLabel;
    UIImageView *_commentTipImageView;
    
    //
    NSString *_token;
    NSInteger _page;
    NSMutableArray *_commentDataArray;
    
    // 评论视图
    HYLSendCommentView *_commentSendView;
}

@property (nonatomic, strong) XLVideoPlayer *player;

@end

@implementation HYLZhiBoInformationViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _token = [defaults objectForKey:@"token"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _token = [defaults objectForKey:@"token"];
    
    [self prepareZhiBoNavigationBar];
    
    _page = 1;
    [self HYLZhiBoDetailInfoApiRequest];
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

- (void)prepareZhiBoNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 30)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:18.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = self.zhiBoTitle;
    
    UINavigationItem *navItem = self.navigationItem;
    navItem.titleView = titleLabel;
    
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

- (void)prepareZhiBoView
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
    
    // 创建 (影片描述、评论) 按钮
    [self createTwoButtons];
    
    // 创建 主要 scrollView
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5, _screenWidth, _screenHeight - (_indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5))];
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.delegate = self;
    _mainScrollView.contentSize = CGSizeMake(_screenWidth * 2, _mainScrollView.frame.size.height);
    [self.view addSubview:_mainScrollView];
    
    // 评论视图
    _commentSendView = [[HYLSendCommentView alloc] initWithFrame:CGRectMake(0, _screenHeight - 54 - 64, _screenWidth, 54)];
    _commentSendView.hidden = YES;
    _commentSendView.userInteractionEnabled = YES;
    [_commentSendView.sendBtn addTarget:self action:@selector(sendCommentToServer:) forControlEvents:UIControlEventTouchUpInside];
    _commentSendView.textF.delegate = self;
    [self.view addSubview:_commentSendView];

    //
    [self createVideoDecriptionView];
    [self createCommentTableView];
}

#pragma mark - 发表评论

- (void)sendCommentToServer:(UIButton *)sender
{
    //    NSLog(@"评论完毕");
    if (_commentSendView.textF.text == nil || _commentSendView.textF.text.length == 0) {
        
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD showErrorWithStatus:@"请输入评论内容"];
        
    } else {
        
        [self uploadCommentToServer];
    }
}

#pragma mark - 上传评论到服务器

- (void)uploadCommentToServer
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:self.zhiBoTitle forKey:@"title"];
    [dictionary setValue:_commentSendView.textF.text forKey:@"content"];
    [dictionary setValue:self.videoId forKey:@"commentable_id"];
    
    // HTTP Basic Authorization
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", _token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    [manager POST:kSendVideoCommentURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"评论返回: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        NSString *message = responseDic[@"message"];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            [_commentSendView.textF resignFirstResponder];
            _commentSendView.hidden = YES;
            
            [SVProgressHUD showSuccessWithStatus:message];
            
        } else {
            
            [SVProgressHUD showErrorWithStatus:message];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        
    }];
}


#pragma mark - 按钮

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
            [self changeDecriptionButtonState];
            [_mainScrollView scrollRectToVisible:CGRectMake(0, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height) animated:YES];
        }
            break;
            
            
        case 1001:
        {
            [self changeCommentButtonState];
            [_mainScrollView scrollRectToVisible:CGRectMake(_mainScrollView.frame.size.width*1, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height) animated:YES];
        }
            break;
            
            
        default:
            break;
    }
}


#pragma mark - 影片描述视图

- (void)createVideoDecriptionView
{
     HYLZhiBoListModel *model = _dataArray[0];
    
    _decriptionScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height)];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _decriptionScrollView.frame.size.width, _decriptionScrollView.frame.size.height)];
    headerView.userInteractionEnabled = YES;
    headerView.backgroundColor = [UIColor clearColor];
    
    //
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, _screenWidth, 30)];
    _titleLabel.text = self.zhiBoTitle;
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [headerView addSubview:_titleLabel];
    
    //
    _playLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, 150, 30)];
    _playLabel.text = [NSString stringWithFormat:@"播放: %@",model.view_count];
    _playLabel.textColor = [UIColor lightGrayColor];
    _playLabel.textAlignment = NSTextAlignmentLeft;
    _playLabel.font = [UIFont systemFontOfSize:16.0f];
    [headerView addSubview:_playLabel];
    
    // 分享
    _shareButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"jingcaishare"] title:@"分享" x:5 tag:100];
    [headerView addSubview:_shareButton];
    
    // 收藏
    _collectButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"myCollectionIcon"] title:@"收藏" x:_screenWidth * 1 / 3.0 tag:101];
    [headerView addSubview:_collectButton];
    
    // 评论
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
    
    _decriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, line.frame.origin.y + line.frame.size.height + 15, _screenWidth - 20, htmlRect.size.height)];
    _decriptionLabel.attributedText = attributeHtml;
    _decriptionLabel.font = [UIFont systemFontOfSize:16.0f];
    _decriptionLabel.numberOfLines = 0;
    _decriptionLabel.textColor = [UIColor lightGrayColor];
    [_decriptionLabel sizeThatFits:htmlRect.size];
    
    [headerView addSubview:_decriptionLabel];
    
    headerView.frame = CGRectMake(0, 0, _decriptionScrollView.frame.size.width, _decriptionLabel.frame.origin.y +_decriptionLabel.frame.size.height);
    
    [_decriptionScrollView addSubview:headerView];
    
    _decriptionScrollView.contentSize = CGSizeMake(_screenWidth, _decriptionLabel.frame.origin.y +_decriptionLabel.frame.size.height);
    [_mainScrollView addSubview:_decriptionScrollView];
}

#pragma mark - 评论列表

- (void)createCommentTableView
{
    _commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(_mainScrollView.frame.size.width, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height) style:UITableViewStylePlain];
    
    _commentTableView.backgroundColor = [UIColor clearColor];
    _commentTableView.separatorColor = [UIColor clearColor];
    _commentTableView.dataSource = self;
    _commentTableView.delegate = self;
    _commentTableView.showsVerticalScrollIndicator = NO;
    _commentTableView.showsHorizontalScrollIndicator = NO;
    _commentTableView.tableFooterView = [[UIView alloc] init];
    
    [_mainScrollView addSubview:_commentTableView];
    
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    _commentTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
}

#pragma mark - 下拉刷新

- (void)loadNewData
{
    _page = 1;
    [_commentDataArray removeAllObjects];
    [self getZhiBoVideoCommentsRequest];
}

#pragma mark - 创建 分享、收藏、评论 button

- (UIButton *)createCommonButtonWithImage:(UIImage *)image title:(NSString *)title x:(CGFloat)x tag:(NSUInteger)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (tag == 100) {
        
        button.frame = CGRectMake(_playLabel.frame.origin.x - 5, _playLabel.frame.origin.y + _playLabel.frame.size.height, 60, 30);
    }
    
    if (tag == 101) {
        
        button.frame = CGRectMake(_screenWidth*0.5 - 30, _playLabel.frame.origin.y + _playLabel.frame.size.height, 60, 30);
    }
    
    if (tag == 102) {
        
        button.frame = CGRectMake(_screenWidth - 65, _playLabel.frame.origin.y + _playLabel.frame.size.height, 60, 30);
    }
    
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

#pragma mark - 分享、收藏、评论 响应

- (void)threeButtonsAction:(UIButton *)sender
{
    switch (sender.tag) {
            
        case 100:
        {
            [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://baidu.com";
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://baidu.com";
            [UMSocialData defaultData].extConfig.wechatSessionData.title = self.zhiBoTitle;
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = self.zhiBoTitle;
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeText;
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
            
            //如果需要分享回调，请将delegate对象设置self，并实现下面的回调方法
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:@"57396808e0f55a0902001ba4"
                                              shareText:self.zhiBoTitle
                                             shareImage:[UIImage imageNamed:@"icon"]
                                        shareToSnsNames:@[UMShareToWechatSession, UMShareToWechatTimeline]
                                               delegate:self];
        }
            break;
            
        case 101:
        {
            if (_token != nil && _token.length > 0) {
                
                [self collectVideo];
                
            } else {
                
                HYLSignInViewController *loginVC = [[HYLSignInViewController alloc] init];
                [self.navigationController pushViewController:loginVC animated:YES];
            }
        }
            break;
            
            
        case 102:
        {
            if (_token != nil && _token.length > 0) {
                
                [_commentSendView.textF becomeFirstResponder];
                _commentSendView.hidden = !_commentSendView.hidden;
                
            } else {
                
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
    
    // HTTP Basic Authorization
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
        NSString *message = responseDic[@"message"];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            if ([responseDic[@"message"] isEqualToString:@"目标已被收藏"]) {
                
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD showErrorWithStatus:@"已经收藏过"];
                
            } else {
                
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD showSuccessWithStatus:message];
            }
            
        } else {
            
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showErrorWithStatus:message];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - 改变指示器的位置

- (void)changeIndicatorViewOriginX:(CGFloat)x
{
    _indicatorView.frame = CGRectMake(x, _videoDescriptionButton.frame.origin.y + _videoDescriptionButton.frame.size.height + 0.5, _screenWidth * 0.5, 1);
}

#pragma mark - 网络请求

- (void)HYLZhiBoDetailInfoApiRequest
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
//        NSLog(@"直播详情: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        
        _dataArray = [[NSMutableArray alloc] init];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *dataDic = responseDic[@"data"];
            
            HYLZhiBoListModel *model = [[HYLZhiBoListModel alloc] initWithDictionary:dataDic];
            [_dataArray addObject:model];
            
            // 视频地址
            _video_url = model.video_info.url;
            _cover_url = model.video_info.cover_url;
            
            [self prepareZhiBoView];
            
        } else {
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - 获取视频评论

- (void)getZhiBoVideoCommentsRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:self.videoId forKey:@"video_id"];
    [dictionary setValue:[NSString stringWithFormat:@"%ld", _page] forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kGetVideoCommentURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"重温评论列表: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
        
        _commentDataArray = [[NSMutableArray alloc] init];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSArray *dataArray = responseDic[@"data"];
            
            if (dataArray.count > 0) {
                
                for (NSDictionary *dic in dataArray) {
                    
                    HYLCommentModel *model = [[HYLCommentModel alloc] init];
                
                    model.content    = dic[@"content"];
                    model.like_count = dic[@"like_count"];
                    model.created_at = dic[@"created_at"];
                    model.comment_id = [NSString stringWithFormat:@"%@", dic[@"id"]];
                    
                    NSDictionary *user = dic[@"user"];
                    
                    model.name         = user[@"name"];
                    model.avatar       = user[@"avatar"];
                    
                    [_commentDataArray addObject:model];
                }
                
                [self createCommentTableView];
                [_commentTableView reloadData];
                
                // 拿到当前的下拉刷新控件，结束刷新状态
                [_commentTableView.mj_header endRefreshing];
                
                // 拿到当前的上拉刷新控件，结束刷新状态
                [_commentTableView.mj_footer endRefreshing];

                
            } else {
                
                if (_commentTipImageView != nil) {
                    
                    [_commentTipImageView removeFromSuperview];
                }
                
                if (_commentTipLabel != nil) {
                    
                    [_commentTipLabel removeFromSuperview];
                }
                
                UIImage *backgroundImage = [UIImage imageNamed:@"tip"];
                
                // 背景
                _commentTipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_mainScrollView.frame.size.width, 0, backgroundImage.size.width, backgroundImage.size.height)];
                _commentTipImageView.image = backgroundImage;
                _commentTipImageView.center = CGPointMake(_mainScrollView.frame.size.width * 1.5, _mainScrollView.frame.size.height *0.5 - 64);
                [_mainScrollView addSubview:_commentTipImageView];
                
                // 标签
                _commentTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_mainScrollView.frame.size.width * 1.5 - 60, _commentTipImageView.frame.origin.y + _commentTipImageView.frame.size.height + 5, 120, 30)];
                _commentTipLabel.text = @"暂无评论";
                _commentTipLabel.font = [UIFont systemFontOfSize:16.0f];
                _commentTipLabel.textColor = [UIColor blackColor];
                _commentTipLabel.textAlignment = NSTextAlignmentCenter;
                
                [_mainScrollView addSubview:_commentTipLabel];
            }
            
        } else {
            
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark -  UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count;
    
    if (tableView == _commentTableView) {
        
        count =  _commentDataArray.count;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id commonCell = nil;
    
    if (tableView == _commentTableView) {
        
        static NSString *CellIdentifier = @"commentCell";
        
        HYLCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            
            cell = [[HYLCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        HYLCommentModel *model    = _commentDataArray[indexPath.row];
        
        cell.titleLabel.text      = model.name;
        cell.created_atLabel.text = model.created_at;
        cell.contentLabel.text    = model.content;
        
        [cell.avatar sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"defaultImage"]];
        
        if (model.like_count.integerValue > 0) {
            
            [cell.like_countButton setImage:[UIImage imageNamed:@"dianzanle"] forState:UIControlStateNormal];
            
        } else {
            
            [cell.like_countButton setImage:[UIImage imageNamed:@"dianzan"] forState:UIControlStateNormal];
        }
        
        cell.like_countButton.tag = indexPath.row + 1000;
        cell.like_countButton.userInteractionEnabled = YES;
        cell.like_countLabel.text = model.like_count;
        
        [cell.like_countButton addTarget:self action:@selector(dianzanAction:) forControlEvents:UIControlEventTouchUpInside];
        
        commonCell = cell;
    }
    
    return commonCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (tableView == _commentTableView) {
        
        height = 90;
    }
    
    return height;
}

#pragma mark - 点赞请求

- (void)dianzanAction:(UIButton *)sender
{
    if (_token != nil && _token.length > 0) {
        
        NSInteger buttonTag = sender.tag - 1000;
        HYLCommentModel *model = _commentDataArray[buttonTag];
        
        NSString *comment_id = model.comment_id;
        
        //
        NSString *timestamp = [HYLGetTimestamp getTimestampString];
        NSString *signature = [HYLGetSignature getSignature:timestamp];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        
        [dictionary setValue:timestamp          forKey:@"time"];
        [dictionary setValue:signature          forKey:@"sign"];
        [dictionary setValue:comment_id         forKey:@"comment_id"];
        
        // HTTP Basic Authorization
        NSString *authorization = [NSString stringWithFormat:@"Basic %@", _token];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
        
        [manager POST:kLikeCommentURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"点赞返回: %@", reponse);
            
            NSError *error = nil;
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:&error];
            
            NSString *message = responseDic[@"message"];
            
            if ([responseDic[@"status"]  isEqual: @1]) {
                
                [self loadNewData];
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD showSuccessWithStatus:message];
                
            } else {
                
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD showErrorWithStatus:message];
            }
            
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            
            NSLog(@"error: %@", error);
            
        }];
        
        
    } else {
        
        HYLSignInViewController *loginVC = [[HYLSignInViewController alloc] init];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

#pragma mark --- UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    
    int numOfPage = offset.x / _screenWidth;
    
    if (numOfPage == 0) {
        
        [self changeDecriptionButtonState];
        
    } else if (numOfPage == 1) {
        
        [self changeCommentButtonState];
    }
}

#pragma mark --- 改变影片描述按钮的状态

- (void)changeDecriptionButtonState
{
    [self changeIndicatorViewOriginX:0];
    [_videoDescriptionButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

#pragma mark --- 改变评论按钮的状态

- (void)changeCommentButtonState
{
    [self getZhiBoVideoCommentsRequest];
    
    [self changeIndicatorViewOriginX:_screenWidth * 0.5];
    [_videoDescriptionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_commentSendView.hidden == NO) {
        
        _commentSendView.hidden = YES;
        [_commentSendView.textF resignFirstResponder];
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
