//
//  HYLTouTiaoDetailViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/30/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLTouTiaoDetailViewController.h"

#import <AFNetworking.h>
#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import "HaoYuLeNetworkInterface.h"

#import <SDWebImage/UIImageView+WebCache.h>

// 视频播放
#import <MediaPlayer/MediaPlayer.h>


#define     kWidthHeightRatio   533/300.0f

@interface HYLTouTiaoDetailViewController ()
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
    
    NSMutableArray *_dataArray;
}

@property (nonatomic, strong) MPMoviePlayerController *mc;

@end

@implementation HYLTouTiaoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];

    _videoTitle = @"到";
    _createTime = @"2016-03-30 13:46:47";
    _editor = @"admin";
    _html = @"<p style=\"font-size:14px;color:#333333;font-family:Arial, 宋体, sans-serif;background-color:#FFFFFF;\">\r\n\t黄玉是和田玉中珍贵的品种之一，近些年来在玉器收藏市场上也是特别的火爆。随着和田玉越来越受人们的关注，品质优异的黄玉并不多，并且黄玉也是最近几年才开始被人们熟知的。很多人对黄玉的了解度并不高，那么，和田玉黄玉有没有收藏价值呢？小编给大家整理了一下资料供参考。\r\n</p>\r\n<p style=\"font-size:14px;color:#333333;font-family:Arial, 宋体, sans-serif;background-color:#FFFFFF;\">\r\n\t大部分人所熟知的都是和田白玉，也就是最为珍贵的羊脂玉，好的羊脂白玉是可遇不可求的，并且市场价格非常之昂贵。而和田黄玉的正规度并不压于羊脂白玉， 并且黄色越浓的就越是珍贵，颜色纯正的黄玉其珍贵性不比羊脂白玉低。而最重要的原因是因为和田黄玉的产量本身就特别低，所以很多的人在收藏了之后就很少会 拿出交易。品质优异的和田黄玉价格丝毫不比羊脂白玉的差。\r\n</p>\r\n<p style=\"font-size:14px;color:#333333;font-family:Arial, 宋体, sans-serif;background-color:#FFFFFF;\">\r\n\t近些年，黄玉作为珍贵的软玉品种已经在市面上开始展露些头角了，据业内人士表 示，从2009年开始，和田黄玉的价格已经涨至三到六成，由此可见黄玉的收藏潜力是不容小视的。当然，要想收藏的有潜力的黄玉，还要看黄玉的颜色是否纯 正，有没有掺有杂色等，这些都会令黄玉的价值受到影响。\r\n</p>\r\n<p style=\"font-size:14px;color:#333333;font-family:Arial, 宋体, sans-serif;background-color:#FFFFFF;\">\r\n\t来源： 金投珠宝\r\n</p>";
    
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    // 网络请求
    [self hylTouTiaoDetailInfoApiRequest];
    
    // 创建导航栏
    [self prepareNavigationBar];
    
    // 创建界面
    [self createViewHeader];
}

#pragma mark - 创建导航栏

- (void)prepareNavigationBar
{
    // bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    // left bar button item
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 40, 30);
    [leftButton setImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backTo) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationController.navigationItem.leftBarButtonItem = left;
    
    
    // right bar button item
    UIBarButtonItem *rightButtonItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comment"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(comment:)];
    
    UIBarButtonItem *rightButtonItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(share:)];
    NSArray *itemArray = @[rightButtonItem1, rightButtonItem2];
    
    self.navigationController.navigationItem.rightBarButtonItems = itemArray;
}

#pragma mark - 返回

- (void)backTo
{
    NSLog(@"返回");
}

#pragma mark - 评论

- (void)comment:(id)sender
{
    NSLog(@"comment");
}

#pragma mark - 分享

- (void)share:(id)sender
{
    NSLog(@"share");
}

#pragma mark - 创建 界面

- (void)prepareView
{
    NSLog(@"prepare view");
}

#pragma mark - 视图头

- (void)createViewHeader
{
    _videoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_screenWidth*0.5 - 180 * 0.5, 10, 180, 30)];
    _videoTitleLabel.text = _videoTitle;
    _videoTitleLabel.textColor = [UIColor blackColor];
    _videoTitleLabel.textAlignment = NSTextAlignmentCenter;
    _videoTitleLabel.font = [UIFont systemFontOfSize:16.0f];
    [self.view addSubview:_videoTitleLabel];
    
    _createTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, _videoTitleLabel.frame.origin.y + _videoTitleLabel.frame.size.height, _screenWidth * 3 / 4.0, 30)];
    _createTimeLabel.text = [NSString stringWithFormat:@"发布于:%@", _createTime];
    _createTimeLabel.textColor = [UIColor lightGrayColor];
    _createTimeLabel.textAlignment = NSTextAlignmentLeft;
    _createTimeLabel.font = [UIFont systemFontOfSize:13.0f];
    [_createTimeLabel sizeToFit];
    [self.view addSubview:_createTimeLabel];
    
    _editorLabel = [[UILabel alloc] initWithFrame:CGRectMake(_createTimeLabel.frame.origin.x + _createTimeLabel.frame.size.width + 10, _createTimeLabel.frame.origin.y , _screenWidth * 1 / 4.0 - 10, 30)];
    _editorLabel.text = [NSString stringWithFormat:@"编辑:%@", _editor];
    _editorLabel.textColor = [UIColor lightGrayColor];
    _editorLabel.textAlignment = NSTextAlignmentLeft;
    _editorLabel.font = [UIFont systemFontOfSize:13.0f];
    [_editorLabel sizeToFit];
    [self.view addSubview:_editorLabel];
    
    // 分隔线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(5, _editorLabel.frame.origin.y + _editorLabel.frame.size.height + 10, _screenWidth - 10, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView];
    
    // 创建视频
    _videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, lineView.frame.origin.y + 1 + 10, _screenWidth - 20, 220)];
    _videoImageView.userInteractionEnabled = YES;
    _videoImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_videoImageView];
    
    // 播放视频按钮
    UIImage *image = [UIImage imageNamed:@"playBtn"];
    _playVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playVideoButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    _playVideoButton.center = CGPointMake(_videoImageView.frame.size.width*0.5, _videoImageView.frame.size.height * 0.5);
    [_playVideoButton setImage:image forState:UIControlStateNormal];
    [_playVideoButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    [_videoImageView addSubview:_playVideoButton];
   
    // 视频简介
    _videoIntroductionLabel = [[UILabel alloc] init];
    _videoIntroductionLabel.numberOfLines = 0;
    
    NSData *data = [_html dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSAttributedString *html = [[NSAttributedString alloc] initWithData:data
                                                                options:options
                                                     documentAttributes:nil
                                                                  error:nil];
    _videoIntroductionLabel.attributedText = html;
    _videoIntroductionLabel.font = [UIFont systemFontOfSize:12.0f];
    _videoIntroductionLabel.textColor = [UIColor lightGrayColor];
    
    CGRect htmlRect = [html boundingRectWithSize:CGSizeMake(_screenWidth - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    _videoIntroductionLabel.frame = CGRectMake(_videoImageView.frame.origin.x, _videoImageView.frame.origin.y + _videoImageView.frame.size.height + 5, htmlRect.size.width, htmlRect.size.height);
    
    [self.view addSubview:_videoIntroductionLabel];
}

#pragma mark - 播放视频按钮 响应

- (void)playVideo:(UIButton *)sender
{
    NSLog(@"play video");
    
    NSURL *url = [NSURL URLWithString:@"http://vfile.grtn.cn/2016/1458/7374/4515/145873744515.ssm/145873744515.m3u8"];
    MPMoviePlayerController *controller = [[MPMoviePlayerController alloc] initWithContentURL:url];
    controller.movieSourceType = MPMovieSourceTypeStreaming;
    self.mc = controller;
    
    controller.view.frame = self.view.bounds;
    [self.view addSubview:controller.view];
    [controller play];
}

#pragma mark - 网络请求

- (void)hylTouTiaoDetailInfoApiRequest
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    NSString *timestamp = [HYLGetTimestamp getTimestampString];
    NSString *signature = [HYLGetSignature getSignature:timestamp];
    
    [dictionary setValue:timestamp forKey:@"time"];
    [dictionary setValue:signature forKey:@"sign"];
    [dictionary setValue:@"5" forKey:@"id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:kShiPinDetailURL parameters:dictionary success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSString *reponse = [[NSString alloc] initWithData:responseObject
                                                  encoding:NSUTF8StringEncoding];
        NSLog(@"头条详情: \n%@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *firstDataDic = responseDic[@"data"];
            
            _videoTitle = firstDataDic[@"title"];
            _createTime = firstDataDic[@"updated_at"];
            _editor = firstDataDic[@"author"];
            _html = firstDataDic[@"summary"];
            
            NSDictionary *videoInfoDic = firstDataDic[@"video_info"];
            
            [_videoImageView sd_setImageWithURL:[NSURL URLWithString:videoInfoDic[@"cover_url"]] completed:nil];
            
        } else {
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
//        NSLog(@"error:\n%@", error);
        
    }];
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
