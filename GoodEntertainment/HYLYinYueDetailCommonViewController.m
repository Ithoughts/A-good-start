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


@interface HYLYinYueDetailCommonViewController ()
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    UIImageView *_musicImageView;
    UIButton *_playMusicButton;
    NSString *_music_url;
}

@property (nonatomic, strong) MPMoviePlayerController *mc;

@end

@implementation HYLYinYueDetailCommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self HYLDetailInfoApiRequest];
    
    float red = arc4random()%255;
    float green = arc4random()%255;
    float blue = arc4random()%255;
    
    UIColor *randomColor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0];
    self.view.backgroundColor = randomColor;
    
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    
    
    [self prepareView];
}

- (void)prepareView
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
}

#pragma mark - 网络请求

- (void)HYLDetailInfoApiRequest
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
        
        NSString *reponse = [[NSString alloc] initWithData:responseObject
                                                  encoding:NSUTF8StringEncoding];
        NSLog(@"详情: %@", reponse);
        
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        
        if ([responseDic[@"status"]  isEqual: @1]) {
            
            NSDictionary *firstDataDic = responseDic[@"music"];
            
            NSDictionary *music_infoDic = firstDataDic[@"video_info"];
            
            // 音乐地址
            _music_url = music_infoDic[@"url"];
            
            // 音乐截图
            [_musicImageView sd_setImageWithURL:[NSURL URLWithString:music_infoDic[@"cover_url"]] completed:nil];

            
        } else {
            
        }

        
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
