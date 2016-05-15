//
//  HYLYinYueDetailCommonViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 4/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLYinYueDetailCommonViewController.h"

#import "HYLBangDanModel.h"

#import <AFNetworking.h>
#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import "HaoYuLeNetworkInterface.h"

#import <SDWebImage/UIImageView+WebCache.h>

// 视频播放
#import <MediaPlayer/MediaPlayer.h>


@interface HYLYinYueDetailCommonViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    UIImageView *_musicImageView;
    UIButton *_playMusicButton;
    NSString *_music_url;
    
    //
    UIButton *_MVDescriptionButton;
    UIButton *_commentButton;
    UIButton *_singerButton;
    UIView *_indicatorView;
    
    //
    UITableView *_MVDecriptionTable;
    NSMutableArray *_dataArray;
    
    //
    UITableView *_commentTable;
    
    //
    UITableView *_singerTable;
    
    //
    UILabel *_titleLabel;
    UILabel *_editorLabel;
    UILabel *_playLabel;
    
    //
    UIButton *_shareButton;
    UIButton *_collectButton;
    UIButton *_musicCommentButton;
    UILabel *_decriptionLabel;
    
    // 音乐人 id
    NSString *_artist_id;
}

@property (nonatomic, strong) MPMoviePlayerController *mc;

@end

@implementation HYLYinYueDetailCommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [self HYLMusicInfoApiRequest];
    
    [self prepareYinYueNavigationBar];
    [self prepareMVView];
}

#pragma mark - 导航栏

- (void)prepareYinYueNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
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
    _musicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 220)];
    _musicImageView.clipsToBounds = YES;
    _musicImageView.userInteractionEnabled = YES;
    _musicImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_musicImageView];
    
    // 音乐播放
    UIImage *image = [UIImage imageNamed:@"playBtn"];
    _playMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playMusicButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    _playMusicButton.center = CGPointMake(_musicImageView.frame.size.width * 0.5, _musicImageView.frame.size.height * 0.5);
    [_playMusicButton setImage:image forState:UIControlStateNormal];
    [_playMusicButton addTarget:self action:@selector(playMusic:) forControlEvents:UIControlEventTouchUpInside];
    [_musicImageView addSubview:_playMusicButton];
    
    //
    [self createThreeButtons];
    
    // 描述表
    [self.view addSubview:[self createMVDecriptionView]];
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


#pragma mark - 分段

- (void)threeButtonAction:(UIButton *)sender
{
    switch (sender.tag) {
        case 1000:
        {
//            NSLog(@"MV描述");
            
            [self changeIndicatorViewOriginX:0];
            [_MVDescriptionButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [_commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [_singerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            
            // 添加到当前视图
            [self.view addSubview:[self createMVDecriptionView]];
        }
            break;
        case 1001:
        {
//            NSLog(@"评论");
            [self changeIndicatorViewOriginX:_screenWidth * 1/3.0];
            [_MVDescriptionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [_commentButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [_singerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            // 添加到当前视图
            [self.view addSubview:[self createCommentTableView]];
        }
            break;
            
        case 1002:
        {
//            NSLog(@"艺人MV");
            [self changeIndicatorViewOriginX:_screenWidth * 2/3.0];
            [_MVDescriptionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [_commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [_singerButton setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0f] forState:UIControlStateNormal];
            // 添加到当前视图
            [self.view addSubview:[self createSingerTableView]];
        }
            break;

            
        default:
            break;
    }
}
#pragma mark - 影片简介 表

- (UITableView *)createMVDecriptionView
{
    _MVDecriptionTable = [[UITableView alloc] initWithFrame:CGRectMake(0, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5, _screenWidth, 360)];
    _MVDecriptionTable.dataSource = self;
    _MVDecriptionTable.delegate = self;
    _MVDecriptionTable.tableHeaderView = ({
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5, _screenWidth, 360)];
        headerView.userInteractionEnabled = YES;
    
        //
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 30)];
        _titleLabel.text = @"发达";
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [headerView addSubview:_titleLabel];
        
        //
        _editorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 150, 30)];
        _editorLabel.text = @"admin";
        _editorLabel.textColor = [UIColor lightGrayColor];
        _editorLabel.textAlignment = NSTextAlignmentLeft;
        _editorLabel.font = [UIFont systemFontOfSize:15.0f];
        [headerView addSubview:_editorLabel];
        
        //
        _playLabel = [[UILabel alloc] initWithFrame:CGRectMake(_screenWidth - 160, 35, 150, 30)];
        _playLabel.text = @"播放: 53";
        _playLabel.textColor = [UIColor lightGrayColor];
        _playLabel.textAlignment = NSTextAlignmentRight;
        _playLabel.font = [UIFont systemFontOfSize:15.0f];
        [headerView addSubview:_playLabel];
        
        //
        _shareButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"jingcaishare"] title:@"分享" x:5 tag:100];
        [headerView addSubview:_shareButton];
        
        _collectButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"myCollectionIcon"] title:@"收藏" x:_screenWidth * 1 / 3.0 tag:101];
        [headerView addSubview:_collectButton];
        
        _musicCommentButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"jingcaicomment"] title:@"评论" x:_screenWidth * 2 / 3.0 tag:102];
        [headerView addSubview:_musicCommentButton];
        
        //
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _shareButton.frame.origin.y + _shareButton.frame.size.height, _screenWidth, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        [headerView addSubview:line];
        
        //
        _decriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, line.frame.origin.y + line.frame.size.height+5, _screenWidth - 10, 0)];
        
        //
        BangDanDetailInfoData *model = _dataArray[0];
        
        if (_dataArray.count > 0) {
            
            NSString *html = model.summary;
            NSData *data = [html dataUsingEncoding:NSUnicodeStringEncoding];
            NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
            NSAttributedString *attributeHtml = [[NSAttributedString alloc] initWithData:data
                                                                                 options:options
                                                                      documentAttributes:nil
                                                                                   error:nil];
            _decriptionLabel.attributedText = attributeHtml;
            _decriptionLabel.font = [UIFont systemFontOfSize:15.0f];
            _decriptionLabel.numberOfLines = 0;
            _decriptionLabel.textColor = [UIColor lightGrayColor];
            
            CGRect htmlRect = [attributeHtml boundingRectWithSize:CGSizeMake(_screenWidth - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            
            _decriptionLabel.frame = CGRectMake(5, line.frame.origin.y + line.frame.size.height, _screenWidth - 10, htmlRect.size.height);
            
            [_decriptionLabel sizeThatFits:htmlRect.size];
            
            [headerView addSubview:_decriptionLabel];
        }
        
        headerView;
    });
    
    _MVDecriptionTable.tableFooterView = [[UIView alloc] init];
    
    return _MVDecriptionTable;
}

#pragma mark - 评论 列表

- (UITableView *)createCommentTableView
{
    _commentTable = [[UITableView alloc] initWithFrame:CGRectMake(0, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5+5, _screenWidth, _screenHeight - (_indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5+5)) style:UITableViewStylePlain];
    _commentTable.dataSource = self;
    _commentTable.delegate = self;
    _commentTable.showsHorizontalScrollIndicator = NO;
    _commentTable.showsVerticalScrollIndicator = NO;
    _commentTable.tableFooterView = [[UIView alloc] init];
    
    return _commentTable;
}

#pragma mark -  MV艺人 列表

- (UITableView *)createSingerTableView
{
    _singerTable = [[UITableView alloc] initWithFrame:CGRectMake(0, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5, _screenWidth, _screenHeight - (_indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5+5)) style:UITableViewStylePlain];
    _singerTable.dataSource = self;
    _singerTable.delegate = self;
    _singerTable.showsHorizontalScrollIndicator = NO;
    _singerTable.showsVerticalScrollIndicator = NO;
    _singerTable.tableFooterView = [[UIView alloc] init];
    
    return _singerTable;
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
    button.frame = CGRectMake(x, _playLabel.frame.origin.y + _playLabel.frame.size.height, _screenWidth * 1/3.0, 30);
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
            NSLog(@"分享");
        }
            break;
            
        case 101:
        {
            NSLog(@"收藏");
        }
            break;
            
            
        case 102:
        {
            NSLog(@"评论");
        }
            break;
            
        default:
            break;
    }
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
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject
//                                                  encoding:NSUTF8StringEncoding];
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
            
            // 获取歌曲列表
            [self HYLMusicListApiRequest:_artist_id];
            
            // 音乐地址
            _music_url = music_info[@"url"];
            
            // 音乐截图
            [_musicImageView sd_setImageWithURL:[NSURL URLWithString:music_info[@"cover_url"]] completed:nil];

        } else {
            
        }
        
        [_MVDecriptionTable reloadData];
        

    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
//        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - 获取某人的音乐列表

- (void)HYLMusicListApiRequest:(NSString *)artist_id
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:artist_id forKey:@"artist_id"];
    [dictionary setValue:@"1" forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kSingerMVURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject
//                                                  encoding:NSUTF8StringEncoding];
//        NSLog(@"音乐人的音乐列表: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            } else {
            
        }
        
        [_MVDecriptionTable reloadData];
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
//        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - 播放音乐

- (void)playMusic:(UIButton *)sender
{
    NSURL *url = [NSURL URLWithString:_music_url];
    MPMoviePlayerController *controller = [[MPMoviePlayerController alloc] initWithContentURL:url];
    controller.movieSourceType = MPMovieSourceTypeStreaming;
    self.mc = controller;
    
    controller.view.frame = self.view.bounds;
    [self.view addSubview:controller.view];
    [controller play];
}

#pragma mark -  UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _MVDecriptionTable) {
        
        return 0;
        
    } else {
        
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (tableView != _MVDecriptionTable) {
        
        static NSString *CellIdentifier = @"CellIdentifier";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (tableView != _MVDecriptionTable) {
        height = 100;
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
