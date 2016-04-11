//
//  HYLZhiBoInformationViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 4/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLZhiBoInformationViewController.h"

#import "HYLZhiBoListModel.h"

#import <AFNetworking.h>
#import "HYLGetTimestamp.h"
#import "HYLGetSignature.h"
#import "HaoYuLeNetworkInterface.h"

#import <SDWebImage/UIImageView+WebCache.h>

// 视频播放
#import <MediaPlayer/MediaPlayer.h>

@interface HYLZhiBoInformationViewController ()
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    UIImageView *_videoImageView;
    UIButton *_playVideoButton;
    NSString *_video_url;
}

@property (nonatomic, strong) MPMoviePlayerController *mc;

@end

@implementation HYLZhiBoInformationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    [self HYLDetailInfoApiRequest];
    
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
            
            // 视频数据
            NSDictionary *videoInfoDic = dataDic[@"video_info"];
            
            // 视频地址
            _video_url = videoInfoDic[@"url"];
            
            // 视频截图
            [_videoImageView sd_setImageWithURL:[NSURL URLWithString:videoInfoDic[@"cover_url"]] completed:nil];
            
        } else {
            
        }
        
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
