//
//  HYLPlayMVListMusicViewController.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 5/17/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLPlayMVListMusicViewController.h"
#import "XLVideoPlayer.h"

@interface HYLPlayMVListMusicViewController ()

@property (nonatomic, strong) XLVideoPlayer *player;

@end

@implementation HYLPlayMVListMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.videoTitle;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self preparePlayVideoNavigationBar];
}

#pragma mark - 导航栏

- (void)preparePlayVideoNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"naviBar_background"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:18.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = self.videoTitle;
    
    UINavigationItem *navItem = self.navigationItem;
    navItem.titleView = titleLabel;
    
    //
    UIImage *image = [UIImage imageNamed:@"backIcon"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [leftButton setImage:image forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(comeBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    navItem.leftBarButtonItem = left;
}

#pragma mark - 返回

- (void)comeBack:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (XLVideoPlayer *)player {
    if (!_player) {
        _player = [[XLVideoPlayer alloc] init];
        _player.frame = CGRectMake(0, 0, self.view.frame.size.width, 250);
    }
    return _player;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.player.videoUrl = self.mp4_url;
    [self.view addSubview:self.player];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.player destroyPlayer];
    self.player = nil;
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
