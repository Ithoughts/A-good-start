//
//  HYLYinYueDetailCommonViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 4/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLYinYueDetailCommonViewController.h"

#import "HYLBangDanModel.h"
#import "HYLSignInViewController.h"

#import <AFNetworking/AFNetworking.h>
#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import "HaoYuLeNetworkInterface.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "HYLArtistMusicListModel.h"
#import "HYLSingerMVCell.h"

// 视频播放
#import "XLVideoPlayer.h"

#import <UMengSocialCOM/UMSocialSnsService.h>
#import <UMSocialSnsPlatformManager.h>

#import "HYLPlayMVListMusicViewController.h"

// 刷新
#import <MJRefresh/MJRefresh.h>
#import <SVProgressHUD/SVProgressHUD.h>


#import "HYLCommentCell.h"
#import "HYLCommentModel.h"

// 评论视图
#import "HYLSendCommentView.h"

@interface HYLYinYueDetailCommonViewController ()<UITableViewDelegate, UITableViewDataSource, UMSocialUIDelegate, UIScrollViewDelegate, UITextFieldDelegate>
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    UIImageView *_musicImageView;
    UIImageView *_playVideoImage;
    NSString *_music_url;
    NSString *_cover_url;
    
    // MV 描述
    UIButton *_MVDescriptionButton;
    // 评论按钮
    UIButton *_commentButton;
    // 艺人 MV
    UIButton *_singerButton;
    // 指示条
    UIView   *_indicatorView;
    
    // 容器
    UIScrollView *_mainScrollView;
    
    //
    UIScrollView *_MVDecriptionScrollView;
    // 评论 table
    UITableView *_commentTable;
    // 艺人 MV table
    UITableView *_singerTable;
    
    //
    UILabel *_titleLabel;
    UILabel *_editorLabel;
    UILabel *_playLabel;
    
    //
    UIButton *_shareButton;
    UIButton *_collectButton;
    UIButton *_musicCommentButton;
    UILabel  *_decriptionLabel;
    
    // 音乐人 id
    NSString *_artist_id;
    
    //
    UILabel     *_commentTipLabel;
    UIImageView *_commentTipImageView;
    
    //
    NSIndexPath *_indexPath;
    CGRect _currentPlayCellRect;
    
    //
    NSInteger _commentPage;
    NSInteger _singerPage;
    NSString *_token;
    
    // 数组
    NSMutableArray *_dataArray;
    NSMutableArray *_artistListArray;
    NSMutableArray *_commentDataArray;
    
    // 评论视图
    HYLSendCommentView *_commentSendView;
}

@property (nonatomic, strong) XLVideoPlayer *player;

@end

@implementation HYLYinYueDetailCommonViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _token = [defaults objectForKey:@"token"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    _screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _token = [defaults objectForKey:@"token"];
    
    _commentPage = 1;
    _singerPage = 1;
    
    [self prepareYinYueNavigationBar];
    
    _artistListArray = [[NSMutableArray alloc] init];
    
    [self HYLMusicInfoApiRequest];
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
    _player.videoUrl = _music_url;
    _player.frame = view.bounds;
    
    [view addSubview:_player];
    
    _player.completedPlayingBlock = ^(XLVideoPlayer *player) {
        [player destroyPlayer];
        _player = nil;
    };
}

#pragma mark - 导航栏

- (void)prepareYinYueNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 30)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:18.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = self.musicTitle;
    
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

- (void)prepareMVView
{
    // 音乐截图
    _musicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, (self.imageHeight/self.imageWidth)*_screenWidth)];
    _musicImageView.clipsToBounds = YES;
    _musicImageView.userInteractionEnabled = YES;
    _musicImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_musicImageView sd_setImageWithURL:[NSURL URLWithString:_cover_url] completed:nil];
    [self.view addSubview:_musicImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showVideoPlayer:)];
    [_musicImageView addGestureRecognizer:tap];
    
    // 音乐播放
    UIImage *image = [UIImage imageNamed:@"playBtn"];
    _playVideoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    _playVideoImage.center = CGPointMake(_musicImageView.frame.size.width * 0.5, _musicImageView.frame.size.height * 0.5);
    _playVideoImage.image = image;
    _playVideoImage.userInteractionEnabled = YES;
    [_musicImageView addSubview:_playVideoImage];
    
    // 创建 (MV描述、评论、 艺人MV) 按钮
    [self createThreeButtons];
    
    // 创建 主要 scrollView
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5, _screenWidth, _screenHeight - (_indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5))];
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.delegate = self;
    _mainScrollView.contentSize = CGSizeMake(_screenWidth * 3, _mainScrollView.frame.size.height);
    [self.view addSubview:_mainScrollView];
    
    // 评论视图
    _commentSendView = [[HYLSendCommentView alloc] initWithFrame:CGRectMake(0, _screenHeight - 54 - 64, _screenWidth, 54)];
    _commentSendView.hidden = YES;
    _commentSendView.userInteractionEnabled = YES;
    [_commentSendView.sendBtn addTarget:self action:@selector(sendCommentToServer:) forControlEvents:UIControlEventTouchUpInside];
    _commentSendView.textF.delegate = self;
    [self.view addSubview:_commentSendView];
    

    [self createMVDecriptionView];
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
    [dictionary setValue:self.musicTitle forKey:@"title"];
    [dictionary setValue:_commentSendView.textF.text forKey:@"content"];
    [dictionary setValue:self.musicID forKey:@"commentable_id"];
    
    // HTTP Basic Authorization
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", _token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    [manager POST:kMakeCommentURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
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



#pragma mark - 创建按钮

- (void)createThreeButtons
{
    //
    _MVDescriptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _MVDescriptionButton.frame = CGRectMake(0, _musicImageView.frame.origin.y + _musicImageView.frame.size.height, _screenWidth * 1/3.0, 30);
    [_MVDescriptionButton setTitle:@"MV描述" forState:UIControlStateNormal];
    [_MVDescriptionButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
    _MVDescriptionButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    _MVDescriptionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _MVDescriptionButton.tag = 1000;
    [_MVDescriptionButton addTarget:self action:@selector(threeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_MVDescriptionButton];
    
    //
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentButton.frame = CGRectMake(_screenWidth * 1/3.0, _musicImageView.frame.origin.y + _musicImageView.frame.size.height, _screenWidth * 1/3.0, 30);
    [_commentButton setTitle:@"评论" forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _commentButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    _commentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _commentButton.tag = 1001;
    [_commentButton addTarget:self action:@selector(threeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_commentButton];
    
    //
    _singerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _singerButton.frame = CGRectMake(_screenWidth * 2/3.0, _musicImageView.frame.origin.y + _musicImageView.frame.size.height, _screenWidth * 1/3.0, 30);
    [_singerButton setTitle:@"艺人MV" forState:UIControlStateNormal];
    [_singerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _singerButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    _singerButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    _singerButton.tag = 1002;
    [_singerButton addTarget:self action:@selector(threeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_singerButton];
    
    //
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, _MVDescriptionButton.frame.origin.y + _MVDescriptionButton.frame.size.height + 0.5, _screenWidth, 0.5)];
    backgroundView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:backgroundView];
    
    //
    _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, _MVDescriptionButton.frame.origin.y + _MVDescriptionButton.frame.size.height + 0.5, _screenWidth * 1/3.0, 1)];
    _indicatorView.backgroundColor = [UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f];
    [self.view addSubview:_indicatorView];
}

#pragma mark - MV描述、评论、艺人MV 按钮响应

- (void)threeButtonAction:(UIButton *)sender
{
    switch (sender.tag) {
            
        case 1000:
        {
            [self changeMVButtonState];
            
            [_mainScrollView scrollRectToVisible:CGRectMake(0, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height) animated:YES];
        }
            break;
            
        case 1001:
        {
            [self changeCommentButtonState];
            
            [self HYLMusicCommentListRequest];
            
            [_mainScrollView scrollRectToVisible:CGRectMake(_mainScrollView.frame.size.width*1, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height) animated:YES];
        }
            break;
            
        case 1002:
        {
            [self changeSingerMVButtonState];
            
             [_mainScrollView scrollRectToVisible:CGRectMake(_mainScrollView.frame.size.width*2, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height) animated:YES];
        }
            break;

        default:
            break;
    }
}

#pragma mark - 获取音乐评论列表

- (void)HYLMusicCommentListRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp      forKey:@"time"];
    [dictionary setValue:signature      forKey:@"sign"];
    [dictionary setValue:self.musicID   forKey:@"music_id"];
    [dictionary setValue:[NSString stringWithFormat:@"%ld", _commentPage] forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kMusicCommentsURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"音乐评论列表: %@", reponse);
        
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

                // 添加到当前视图
                [self createCommentTableView];
                [_commentTable reloadData];
                
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
                _commentTipImageView.center = CGPointMake(_mainScrollView.frame.size.width * 0.5 + _mainScrollView.frame.size.width, _mainScrollView.frame.size.height * 0.5 - 64);
                [_mainScrollView addSubview:_commentTipImageView];
                
                // 标签
                _commentTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(_mainScrollView.frame.size.width * 0.5 + _mainScrollView.frame.size.width - 60, _commentTipImageView.frame.origin.y + _commentTipImageView.frame.size.height + 5, 120, 30)];
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

#pragma mark - MV 列表播放

- (void)showPlayer:(UITapGestureRecognizer *)tapGesture
{
    [_player destroyPlayer];
    _player = nil;
    
    UIView *view = tapGesture.view;
    HYLArtistMusicListModel *item = _artistListArray[view.tag - 100];
    
    _indexPath = [NSIndexPath indexPathForRow:view.tag - 100 inSection:0];
    HYLSingerMVCell *cell = [_singerTable cellForRowAtIndexPath:_indexPath];
    
    _player = [[XLVideoPlayer alloc] init];
    _player.videoUrl = item.url;
    [_player playerBindTableView:_singerTable currentIndexPath:_indexPath];
    _player.frame = view.bounds;
    
    [cell.contentView addSubview:_player];
    
    _player.completedPlayingBlock = ^(XLVideoPlayer *player) {
        [player destroyPlayer];
        _player = nil;
    };
}

#pragma mark - 影片简介表

- (void)createMVDecriptionView
{
    BangDanDetailInfoData *model = _dataArray[0];
    
    _MVDecriptionScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height)];
        
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _MVDecriptionScrollView.frame.size.width, _MVDecriptionScrollView.frame.size.height)];
    headerView.userInteractionEnabled = YES;
    headerView.backgroundColor = [UIColor clearColor];

    //
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, _screenWidth, 30)];
    _titleLabel.text = self.musicTitle;
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [headerView addSubview:_titleLabel];
    
    //
    _editorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, _screenWidth*0.5, 30)];
    _editorLabel.text = model.author;
    _editorLabel.textColor = [UIColor lightGrayColor];
    _editorLabel.textAlignment = NSTextAlignmentLeft;
    _editorLabel.font = [UIFont systemFontOfSize:15.0f];
    [headerView addSubview:_editorLabel];
    
    //
    _playLabel = [[UILabel alloc] initWithFrame:CGRectMake(_screenWidth - 160, 35, 150, 30)];
    _playLabel.text = [NSString stringWithFormat:@"播放: %@",model.view_count];;
    _playLabel.textColor = [UIColor lightGrayColor];
    _playLabel.textAlignment = NSTextAlignmentRight;
    _playLabel.font = [UIFont systemFontOfSize:15.0f];
    [headerView addSubview:_playLabel];
    
    //
    _shareButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"jingcaishare"]          title:@"分享" x:5 tag:100];
    [headerView addSubview:_shareButton];
    
    _collectButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"myCollectionIcon"]    title:@"收藏" x:_screenWidth * 1 / 3.0 tag:101];
    [headerView addSubview:_collectButton];
    
    _musicCommentButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"jingcaicomment"] title:@"评论" x:_screenWidth * 2 / 3.0 tag:102];
    [headerView addSubview:_musicCommentButton];
    
    //
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _shareButton.frame.origin.y + _shareButton.frame.size.height, _screenWidth, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:line];
    
    //
    if (_dataArray.count > 0) {
        
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
        _decriptionLabel.numberOfLines = 0;
        _decriptionLabel.textColor = [UIColor blackColor];
        _decriptionLabel.font = [UIFont systemFontOfSize:15.0f];
        
        [headerView addSubview:_decriptionLabel];
        
        headerView.frame = CGRectMake(0, 0, _MVDecriptionScrollView.frame.size.width, _decriptionLabel.frame.origin.y +_decriptionLabel.frame.size.height);
        
        _MVDecriptionScrollView.contentSize = CGSizeMake(_screenWidth, _decriptionLabel.frame.origin.y +_decriptionLabel.frame.size.height);
        
        [_MVDecriptionScrollView addSubview:headerView];
        
        [_mainScrollView addSubview:_MVDecriptionScrollView];
    }
}

#pragma mark - 评论 table

- (void)createCommentTableView
{
    _commentTable = [[UITableView alloc] initWithFrame:CGRectMake(_mainScrollView.frame.size.width, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height) style:UITableViewStylePlain];
    _commentTable.backgroundColor = [UIColor clearColor];
    _commentTable.separatorColor = [UIColor clearColor];
    _commentTable.dataSource = self;
    _commentTable.delegate = self;
    _commentTable.showsHorizontalScrollIndicator = NO;
    _commentTable.showsVerticalScrollIndicator = NO;
    _commentTable.tableFooterView = [[UIView alloc] init];
    
    [_mainScrollView addSubview:_commentTable];
    
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    _commentTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewCommentListData];
    }];
}

#pragma mark - 评论列表，下拉刷新

- (void)loadNewCommentListData
{
    _commentPage = 1;
    
    [_commentDataArray removeAllObjects];
    
    [self HYLMusicCommentListRequest];
}

#pragma mark -  艺人MV table

- (void)createSingerTableView
{
    _singerTable = [[UITableView alloc] initWithFrame:CGRectMake(_mainScrollView.frame.size.width * 2, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height) style:UITableViewStylePlain];
    _singerTable.backgroundColor = [UIColor clearColor];
    _singerTable.separatorColor = [UIColor clearColor];
    _singerTable.dataSource = self;
    _singerTable.delegate = self;
    _singerTable.showsHorizontalScrollIndicator = NO;
    _singerTable.showsVerticalScrollIndicator = NO;
    _singerTable.tableFooterView = [[UIView alloc] init];
    
    [_mainScrollView addSubview:_singerTable];
    
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    _singerTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewSingerListData];
    }];
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    _singerTable.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreSingerListData];
    }];
}

#pragma mark - 艺人MV，下拉刷新

- (void)loadNewSingerListData
{
    _singerPage = 1;
    
    [_artistListArray removeAllObjects];
    
    [self HYLMusicListApiRequest:_artist_id];
}

#pragma mark - 艺人MV，上拉加载更多

- (void)loadMoreSingerListData
{
    _singerPage ++;
    
    [self HYLMusicListApiRequest:_artist_id];
}

#pragma mark - 改变指示器的位置

- (void)changeIndicatorViewOriginX:(CGFloat)x
{
    _indicatorView.frame = CGRectMake(x, _MVDescriptionButton.frame.origin.y + _MVDescriptionButton.frame.size.height + 0.5, _screenWidth * 1/3.0, 1);
}
#pragma mark - 创建 buttons

- (UIButton *)createCommonButtonWithImage:(UIImage *)image title:(NSString *)title x:(CGFloat)x tag:(NSUInteger)tag
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (tag == 100) {
        
        button.frame = CGRectMake(_titleLabel.frame.origin.x - 5, _playLabel.frame.origin.y + _playLabel.frame.size.height, 60, 30);
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
    [button addTarget:self action:@selector(socialButtonsAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - 分享、收藏、评论

- (void)socialButtonsAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
        {
            [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://baidu.com";
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://baidu.com";
            [UMSocialData defaultData].extConfig.wechatSessionData.title = self.musicTitle;
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = self.musicTitle;
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeText;
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeApp;
            
            //如果需要分享回调，请将delegate对象设置self，并实现下面的回调方法
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:@"57396808e0f55a0902001ba4"
                                              shareText:self.musicTitle
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
    
    [dictionary setValue:self.musicID         forKey:@"music_id"];
    [dictionary setValue:timestamp            forKey:@"time"];
    [dictionary setValue:signature            forKey:@"sign"];
    
    // HTTP Basic Authorization
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", _token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    [manager POST:kAddFavoriteMusicURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"收藏音乐返回:%@", string);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        NSString *message = responseDic[@"message"];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            if ([responseDic[@"message"] isEqualToString:@"目标已被收藏"]) {
                
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD showErrorWithStatus:message];
                
            } else {
        
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD showSuccessWithStatus:message];
            }
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - 网络请求

- (void)HYLMusicInfoApiRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:self.musicID forKey:@"id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kMusicDetailURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"音乐详情: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        _dataArray = [[NSMutableArray alloc] init];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *musicDic = responseDic[@"music"];
            NSDictionary *music_info = musicDic[@"video_info"] ;
            
            BangDanDetailInfoData *model = [[BangDanDetailInfoData alloc] initWithDictionary:musicDic];
            [_dataArray addObject:model];
            
            NSArray *artistArray = musicDic[@"artist"];
            
            for (NSDictionary *dic in artistArray) {
                
                _artist_id = dic[@"id"];
            }
            
            // 获取 艺人MV 列表，数据
            [self HYLMusicListApiRequest:_artist_id];
            
            // 音乐地址
            _music_url = music_info[@"url"];
            
            // 音乐截图
            _cover_url = music_info[@"cover_url"];
            
            [self prepareMVView];
            
        } else {
            
        }

    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - 获取 艺人MV

- (void)HYLMusicListApiRequest:(NSString *)artist_id
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:artist_id forKey:@"artist_id"];
    [dictionary setValue:[NSString stringWithFormat:@"%ld", (long)_singerPage] forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kSingerMVURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"音乐人的音乐列表: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *firstData = responseDic[@"data"];
            NSArray *musicArray = firstData[@"music"];
            
            if (musicArray.count > 0) {
                
                for (NSDictionary *dic in musicArray) {
                    
                    HYLArtistMusicListModel *model = [[HYLArtistMusicListModel alloc] init];
                    
                    model.title = dic[@"title"];
                    model.author = dic[@"author"];
                    
                    NSDictionary *video_info = dic[@"video_info"];
                    model.url = video_info[@"url"];
                    model.cover_url = video_info[@"cover_url"];
                    
                    [_artistListArray addObject:model];
                }
                
                [self createSingerTableView];
                [_singerTable reloadData];
                
                // 拿到当前的下拉刷新控件，结束刷新状态
                [_singerTable.mj_header endRefreshing];
                // 拿到当前的上拉刷新控件，结束刷新状态
                [_singerTable.mj_footer endRefreshing];
                
            } else {
                
                // 刷新表格
                [_singerTable reloadData];
                // 拿到当前的上拉刷新控件，变为没有更多数据的状态
                [_singerTable.mj_footer endRefreshingWithNoMoreData];
                // 隐藏当前的上拉刷新控件
                _singerTable.mj_footer.hidden = YES;
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
    NSInteger count;
    
    if (tableView == _singerTable) {
        
        count = _artistListArray.count;
        
    } else if (tableView == _commentTable) {
        
        count = _commentDataArray.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id commonCell = nil;
    
    if (tableView == _singerTable) {
        
        static NSString *CellIdentifier = @"MVlist";
        
        HYLSingerMVCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[HYLSingerMVCell alloc] init];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        HYLArtistMusicListModel *model = _artistListArray[indexPath.row];
        
        [cell.avatar sd_setImageWithURL:[NSURL URLWithString:model.cover_url]];
        cell.titleLabel.text = model.title;
        cell.authorLabel.text = model.author;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPlayer:)];
        
        [cell.avatar addGestureRecognizer:tap];
        
        cell.avatar.tag = indexPath.row + 100;
        
        commonCell = cell;
        
    } else if (tableView == _commentTable) {
    
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
    
    if (tableView == _commentTable) {
        
        height = 90.0f;
        
    } else if (tableView == _singerTable) {
    
        height = 100.0f;
    }
    
    return height;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _singerTable) {
        
        HYLArtistMusicListModel *item = _artistListArray[indexPath.row];
        
        HYLPlayMVListMusicViewController *videoDetailViewController = [[HYLPlayMVListMusicViewController alloc] init];
        videoDetailViewController.videoTitle = item.title;
        videoDetailViewController.mp4_url = item.url;
        
        [self.navigationController pushViewController:videoDetailViewController animated:YES];
    }
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
                
                [self loadNewCommentListData];
                
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    
    int numOfPage = offset.x / _screenWidth;
    
    if (numOfPage == 0) {
        
        [self changeMVButtonState];
        
    } else if (numOfPage == 1) {
        
        [self changeCommentButtonState];
        
    } else if (numOfPage == 2) {
    
        [self changeSingerMVButtonState];
    }
}

#pragma mark - 改变MV描述按钮状态

- (void)changeMVButtonState
{
    [self changeIndicatorViewOriginX:0];
    [_MVDescriptionButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_singerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (void)changeCommentButtonState
{
    [self changeIndicatorViewOriginX:_screenWidth * 1/3.0];
    [_MVDescriptionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [_singerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (void)changeSingerMVButtonState
{
    [self changeIndicatorViewOriginX:_screenWidth * 2/3.0];
    [_MVDescriptionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_singerButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
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
