//
//  HYLTouTiaoDetailViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/30/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLHaoYuLeCommonDetailViewController.h"

#import "HYLZhiBoListModel.h"

#import <AFNetworking.h>
#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import "HaoYuLeNetworkInterface.h"

#import <SDWebImage/UIImageView+WebCache.h>

// 视频播放
#import <MediaPlayer/MediaPlayer.h>

@interface HYLHaoYuLeCommonDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    UILabel *_videoTitleLabel;
    UILabel *_createTimeLabel;
    UILabel *_editorLabel;
    
    NSString *_videoTitle;
    NSString *_createTime;
    NSString *_editor;
    
    UIImageView *_videoImageView;
    UIButton *_playVideoButton;
    UILabel *_videoIntroductionLabel;
    
    NSString *_html;
    NSString *_video_url;
    
    NSMutableArray *_dataArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) MPMoviePlayerController *mc;

@end

@implementation HYLHaoYuLeCommonDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 隐藏工具栏
//    [self.tabBarController.tabBar setHidden:YES];
    
    _screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    // 网络请求
    [self HYLDetailInfoApiRequest];
    
    // 创建导航栏
    [self prepareNavigationBar];
    
    // 创建表格
    [self prepareCommonTableView];
}

#pragma mark - 创建导航栏

- (void)prepareNavigationBar
{
    // bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    UINavigationItem *navItem = self.navigationItem;
    
    // left bar button item
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 40, 30);
    [leftButton setImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backTo:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    navItem.leftBarButtonItem = left;
    
    
    // right bar button item
    UIBarButtonItem *rightButtonItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comment"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(comment:)];
    
    UIBarButtonItem *rightButtonItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(share:)];
    NSArray *itemArray = @[rightButtonItem2, rightButtonItem1];
    
    navItem.rightBarButtonItems = itemArray;
}

#pragma mark - 返回

- (void)backTo:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 评论

- (void)comment:(UIButton *)sender
{
    NSLog(@"comment");
}

#pragma mark - 分享

- (void)share:(UIButton *)sender
{
    NSLog(@"share");
}

#pragma mark - 创建 界面

- (void)prepareCommonTableView
{
    self.tableView.tableHeaderView = ({
    
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 820.0f)];
        
        // 视频标题
        _videoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_screenWidth * 0.5 - 180 * 0.5, 10, 180, 30)];
        _videoTitleLabel.text = _videoTitle;
        _videoTitleLabel.textColor = [UIColor blackColor];
        _videoTitleLabel.textAlignment = NSTextAlignmentCenter;
        _videoTitleLabel.font = [UIFont systemFontOfSize:16.0f];
        _videoTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//        [_videoTitleLabel sizeToFit];
        [headerView addSubview:_videoTitleLabel];
        
        // 发布时间
        _createTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, _videoTitleLabel.frame.origin.y + _videoTitleLabel.frame.size.height,  _screenWidth * 3 / 4.0, 30)];
        _createTimeLabel.text = [NSString stringWithFormat:@"发布于:%@", _createTime];
        _createTimeLabel.textColor = [UIColor lightGrayColor];
        _createTimeLabel.textAlignment = NSTextAlignmentLeft;
        _createTimeLabel.font = [UIFont systemFontOfSize:13.0f];
        _createTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//        [_createTimeLabel sizeToFit];
        [headerView addSubview:_createTimeLabel];
        
        // 编辑时间
        _editorLabel = [[UILabel alloc] initWithFrame:CGRectMake(_createTimeLabel.frame.origin.x + _createTimeLabel.frame.size.width - 90, _createTimeLabel.frame.origin.y, _screenWidth * 1 / 4.0 - 10, 30)];
        _editorLabel.text = [NSString stringWithFormat:@"编辑:%@", _editor];
        _editorLabel.textColor = [UIColor lightGrayColor];
        _editorLabel.textAlignment = NSTextAlignmentLeft;
        _editorLabel.font = [UIFont systemFontOfSize:13.0f];
        _editorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//        [_editorLabel sizeToFit];
        [headerView addSubview:_editorLabel];
        
        // 分隔线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(5, _editorLabel.frame.origin.y + _editorLabel.frame.size.height + 5, _screenWidth - 10, 1)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [headerView addSubview:lineView];
        
        // 视频截图
        _videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, lineView.frame.origin.y + 1 + 10, _screenWidth - 10, 220)];
        _videoImageView.clipsToBounds = YES;
        _videoImageView.userInteractionEnabled = YES;
        _videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [headerView addSubview:_videoImageView];

        // 视频播放按钮
        UIImage *image = [UIImage imageNamed:@"playBtn"];
        _playVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playVideoButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        _playVideoButton.center = CGPointMake(_videoImageView.frame.size.width * 0.5, _videoImageView.frame.size.height * 0.5);
        [_playVideoButton setImage:image forState:UIControlStateNormal];
        [_playVideoButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [_videoImageView addSubview:_playVideoButton];
        
        // 视频简介
        _videoIntroductionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, _videoImageView.frame.origin.y + _videoImageView.frame.size.height - 50, _screenWidth - 10, 0)];
        _videoIntroductionLabel.numberOfLines = 0;
        
        NSData *data = [_html dataUsingEncoding:NSUnicodeStringEncoding];
        NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
        NSAttributedString *html = [[NSAttributedString alloc] initWithData:data
                                                                    options:options
                                                         documentAttributes:nil
                                                                      error:nil];
        _videoIntroductionLabel.attributedText = html;
        _videoIntroductionLabel.font = [UIFont systemFontOfSize:11.0f];
        _videoIntroductionLabel.textColor = [UIColor lightGrayColor];
        
        CGRect htmlRect = [html boundingRectWithSize:CGSizeMake(_screenWidth - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        _videoIntroductionLabel.frame = CGRectMake(_videoImageView.frame.origin.x, _videoImageView.frame.origin.y + _videoImageView.frame.size.height, htmlRect.size.width, htmlRect.size.height);
        
        [headerView addSubview:_videoIntroductionLabel];
        
        // 分隔线
//        UIView *line1View = [[UIView alloc] initWithFrame:CGRectMake(5, _videoIntroductionLabel.frame.origin.y + _videoIntroductionLabel.frame.size.height + 5, _screenWidth - 10, 1)];
//        line1View.backgroundColor = [UIColor lightGrayColor];
//        [headerView addSubview:line1View];
        
        headerView;
    });

//    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.tableView.tableFooterView = ({
    
        UIButton *footer = [UIButton buttonWithType:UIButtonTypeCustom];
        footer.frame = CGRectMake(0, 0, _screenWidth, 30);
        footer.center = CGPointMake(_screenWidth*0.5, 0);
        [footer setTitle:@"查看更多评论" forState:UIControlStateNormal];
        [footer setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        footer.titleLabel.font = [UIFont systemFontOfSize: 15.0f];
        footer.titleLabel.textAlignment = NSTextAlignmentCenter;
        footer.enabled = NO;
    
        footer;
    });
    
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
        
//        NSString *reponse = [[NSString alloc] initWithData:responseObject
//                                                  encoding:NSUTF8StringEncoding];
//        NSLog(@"详情: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *dataDic = responseDic[@"data"];
            
            //
            _videoTitle = dataDic[@"title"];
            _videoTitleLabel.text = _videoTitle;
            
            //
            _createTime = dataDic[@"updated_at"];
            _createTimeLabel.text = [NSString stringWithFormat:@"发布于:%@", _createTime];
            
            //
            _editor = dataDic[@"author"];
            _editorLabel.text = [NSString stringWithFormat:@"编辑:%@", _editor];
            
            //
            _html = dataDic[@"summary"];
            NSData *data = [_html dataUsingEncoding:NSUnicodeStringEncoding];
            NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
            NSAttributedString *html = [[NSAttributedString alloc] initWithData:data
                                                                        options:options
                                                             documentAttributes:nil
                                                                          error:nil];
            _videoIntroductionLabel.attributedText = html;
            _videoIntroductionLabel.font = [UIFont systemFontOfSize:11.0f];
            _videoIntroductionLabel.textColor = [UIColor blackColor];
            
            CGRect htmlRect = [html boundingRectWithSize:CGSizeMake(_screenWidth - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            
            _videoIntroductionLabel.frame = CGRectMake(_videoImageView.frame.origin.x, _videoImageView.frame.origin.y + _videoImageView.frame.size.height, htmlRect.size.width, htmlRect.size.height);
            
            [_videoIntroductionLabel sizeThatFits:htmlRect.size];

            
            // 视频数据
            NSDictionary *videoInfoDic = dataDic[@"video_info"];
            
            // 视频地址
            _video_url = videoInfoDic[@"url"];
            
            // 视频截图
            [_videoImageView sd_setImageWithURL:[NSURL URLWithString:videoInfoDic[@"cover_url"]] completed:nil];
            
        } else {
            
        }
        
        // 刷新表格
        [self.tableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
//        NSLog(@"error: %@", error);
        
    }];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"haoYuLeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"test:%ld", indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
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
