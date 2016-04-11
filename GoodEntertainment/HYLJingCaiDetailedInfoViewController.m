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

#import <AFNetworking.h>
#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import "HaoYuLeNetworkInterface.h"

#import <SDWebImage/UIImageView+WebCache.h>

// 视频播放
#import <MediaPlayer/MediaPlayer.h>

@interface HYLJingCaiDetailedInfoViewController ()<UITableViewDelegate, UITableViewDataSource>
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
    UITableView *_decriptionTableView;
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
}

@property (nonatomic, strong) MPMoviePlayerController *mc;

@end

@implementation HYLJingCaiDetailedInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [self HYLDetailInfoApiRequest];
    [self getVideoCommentsRequest];
    
    [self prepareView];
}

- (void)prepareView
{
    // 视频截图
    _videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 220)];
    _videoImageView.clipsToBounds = YES;
    _videoImageView.userInteractionEnabled = YES;
    _videoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_videoImageView];
    
    // 视频播放按钮
    UIImage *image = [UIImage imageNamed:@"playBtn"];
    _playVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playVideoButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    _playVideoButton.center = CGPointMake(_videoImageView.frame.size.width * 0.5, _videoImageView.frame.size.height * 0.5);
    [_playVideoButton setImage:image forState:UIControlStateNormal];
    [_playVideoButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    [_videoImageView addSubview:_playVideoButton];
    
    [self createButtons];
    
    //
    [self.view addSubview:[self createVideoDecriptionView]];
}

#pragma mark - 创建按钮

- (void)createButtons
{
    //
    _videoDescriptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _videoDescriptionButton.frame = CGRectMake(0, _videoImageView.frame.origin.y + _videoImageView.frame.size.height, _screenWidth * 0.5, 30);
    [_videoDescriptionButton setTitle:@"影片描述" forState:UIControlStateNormal];
    [_videoDescriptionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_videoDescriptionButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _videoDescriptionButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    _videoDescriptionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    _videoDescriptionButton.tag = 1000;
    
    [_videoDescriptionButton addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_videoDescriptionButton];
    
    
    //
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentButton.frame = CGRectMake(_screenWidth * 0.5, _videoImageView.frame.origin.y + _videoImageView.frame.size.height, _screenWidth * 0.5, 30);
    [_commentButton setTitle:@"评论" forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _commentButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    _commentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    _commentButton.tag = 1001;
    
    [_commentButton addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_commentButton];
    
    //
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, _videoDescriptionButton.frame.origin.y + _videoDescriptionButton.frame.size.height + 0.5, _screenWidth, 0.5)];
    backgroundView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:backgroundView];
    
    //
    _indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, _videoDescriptionButton.frame.origin.y + _videoDescriptionButton.frame.size.height + 0.5, _screenWidth * 0.5, 1)];
    _indicatorView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_indicatorView];
}

#pragma mark - 分段响应

- (void)buttonTap:(UIButton *)sender
{
    switch (sender.tag) {
        case 1000:
        {
            NSLog(@"影视描述");

            [self changeIndicatorViewOriginX:0];
            
            // 添加到当前视图
            [self.view addSubview:[self createVideoDecriptionView]];
            
        }
            break;
        case 1001:
        {
            NSLog(@"评论");
            
            [self changeIndicatorViewOriginX:_screenWidth * 0.5];
            
            // 添加到当前视图
            [self.view addSubview:[self createCommentTableView]];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 影片描述视图

- (UITableView *)createVideoDecriptionView
{
    _decriptionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5, _screenWidth, 300)];
    _decriptionTableView.dataSource = self;
    _decriptionTableView.delegate = self;
    
    _decriptionTableView.tableHeaderView = ({
    
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5, _screenWidth, 360)];
        headerView.userInteractionEnabled = YES;
        
        //
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 150, 30)];
        _titleLabel.text = @"大师傅";
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [headerView addSubview:_titleLabel];
        
        //
        _playLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, 150, 30)];
        _playLabel.text = @"播放: 0";
        _playLabel.textColor = [UIColor lightGrayColor];
        _playLabel.textAlignment = NSTextAlignmentLeft;
        _playLabel.font = [UIFont systemFontOfSize:16.0f];
        [headerView addSubview:_playLabel];
        
        //
        _shareButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"share"] title:@"分享" x:5 tag:100];
        [headerView addSubview:_shareButton];
        
        _collectButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"myCollectionIcon"] title:@"收藏" x:_screenWidth * 1 / 3.0 tag:101];
        [headerView addSubview:_collectButton];
        
        _commentButton = [self createCommonButtonWithImage:[UIImage imageNamed:@"comment"] title:@"评论" x:_screenWidth * 2 / 3.0 tag:102];
        [headerView addSubview:_commentButton];
    
        
        //
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _shareButton.frame.origin.y + _shareButton.frame.size.height, _screenWidth, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        [headerView addSubview:line];
        
        //
        _decriptionLabel = [[UILabel alloc] init];
        
        //
        HYLZhiBoListModel *model = _dataArray[0];
        
        NSString *html = model.summary;
        NSData *data = [html dataUsingEncoding:NSUnicodeStringEncoding];
        NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
        NSAttributedString *attributeHtml = [[NSAttributedString alloc] initWithData:data
                                                                    options:options
                                                         documentAttributes:nil
                                                                      error:nil];
        _decriptionLabel.attributedText = attributeHtml;
        _decriptionLabel.font = [UIFont systemFontOfSize:11.0f];
        _decriptionLabel.numberOfLines = 0;
        _decriptionLabel.textColor = [UIColor blackColor];
        
        CGRect htmlRect = [attributeHtml boundingRectWithSize:CGSizeMake(_screenWidth - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        _decriptionLabel.frame = CGRectMake(5, line.frame.origin.y + line.frame.size.height, htmlRect.size.width - 10, htmlRect.size.height);
        
        [_decriptionLabel sizeThatFits:htmlRect.size];
        
        [headerView addSubview:_decriptionLabel];

        headerView;
    
    });
    
    
    _decriptionTableView.tableFooterView = [[UIView alloc] init];
    
    
    return _decriptionTableView;
}

#pragma mark - 创建评论视图

- (UITableView *)createCommentTableView
{
    _commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _indicatorView.frame.origin.y + _indicatorView.frame.size.height + 0.5, _screenWidth, 300) style:UITableViewStylePlain];
    _commentTableView.dataSource = self;
    _commentTableView.delegate = self;
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
    [button addTarget:self action:@selector(buttonsTap:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - buttonsTap:

- (void)buttonsTap:(UIButton *)sender
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

#pragma mark - 改变指示器的位置

- (void)changeIndicatorViewOriginX:(CGFloat)x
{
    _indicatorView.frame = CGRectMake(x, _videoDescriptionButton.frame.origin.y + _videoDescriptionButton.frame.size.height + 0.5, _screenWidth * 0.5, 1);
}

#pragma mark - 网络请求

- (void)HYLDetailInfoApiRequest
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
        
        NSString *reponse = [[NSString alloc] initWithData:responseObject
                                                  encoding:NSUTF8StringEncoding];
        NSLog(@"好精彩详情: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        _dataArray = [[NSMutableArray alloc] init];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *dataDic = responseDic[@"data"];
            
            HYLZhiBoListModel *model = [[HYLZhiBoListModel alloc] initWithDictionary:dataDic];
            [_dataArray addObject:model];
            
//            // 视频数据
//            NSDictionary *videoInfoDic = dataDic[@"video_info"];
            
            // 视频地址
            _video_url = model.video_info.url;
            
            // 视频截图
            [_videoImageView sd_setImageWithURL:[NSURL URLWithString:model.video_info.cover_url] completed:nil];
            
            
        } else {
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        //        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - 获取评论

- (void)getVideoCommentsRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:self.videoId forKey:@"id"];
    [dictionary setValue:@"1" forKey:@"page"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kGetVideoCommentURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSString *reponse = [[NSString alloc] initWithData:responseObject
                                                  encoding:NSUTF8StringEncoding];
        NSLog(@"好精彩评论: %@", reponse);
        
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
//        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - 播放视频

- (void)playVideo:(UIButton *)sender
{
    NSURL *url = [NSURL URLWithString:_video_url];
    MPMoviePlayerController *controller = [[MPMoviePlayerController alloc] initWithContentURL:url];
    controller.movieSourceType = MPMovieSourceTypeStreaming;
    self.mc = controller;
    
    controller.view.frame = self.view.bounds;
    [self.view addSubview:controller.view];
    [controller play];
}

#pragma mark - 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _decriptionTableView) {
        
        return 0;
        
    } else {
    
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HYLVideoCommentCell *cell = nil;
    
    if (tableView != _decriptionTableView) {
        
        static NSString *CellIdentifier = @"CellIdentifier";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[HYLVideoCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    
     return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    
    if (tableView != _decriptionTableView) {
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