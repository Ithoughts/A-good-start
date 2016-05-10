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
//#import <MediaPlayer/MediaPlayer.h>
#import "XLVideoPlayer.h"

#import "HYLSendCommentView.h"

@interface HYLHaoYuLeCommonDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextViewDelegate>
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
    UIImageView *_playVideoImage;
    UILabel *_videoIntroductionLabel;
    
    NSString *_html;
    NSString *_video_url;
    
    NSMutableArray *_dataArray;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@property (nonatomic, strong) MPMoviePlayerController *mc;

@property (nonatomic, strong) XLVideoPlayer *player;

@property (weak, nonatomic) IBOutlet HYLSendCommentView *commentView;

@end

@implementation HYLHaoYuLeCommonDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    // 网络请求
    [self HYLDetailInfoApiRequest];
    
    // 创建导航栏
    [self prepareNavigationBar];
    
    // 创建表格
    [self prepareCommonTableView];
    
    
//    _commentView = [[HYLSendCommentView alloc] initWithFrame:CGRectMake(0, _screenHeight - 54, _screenWidth, 54)];
//    _commentView.sendButton addTarget:self action:@selector(<#selector#>) forControlEvents:<#(UIControlEvents)#>
//    
//    
//    if (self.commentView.hidden == NO) {
//        
//        [self.commentView.textField becomeFirstResponder];
//    }
    
    self.commentView.textField.delegate = self;
    
//    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
//    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
//    [self.textField addTarget:self action:@selector(endInput:) forControlEvents:UIControlEventEditingDidEndOnExit];
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

//- (void)keyboardWillShow:(id)sender
//{
//    self.textField.transform = CGAffineTransformMakeTranslation(0, -[[[sender userInfo] objectForKey: @"UIKeyboardFrameEndUserInfoKey"] CGRectValue].size.height);
//    if ([[[sender userInfo] objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue] > 0)
//    {
//        [UIView animateWithDuration:[[[sender userInfo] objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue] delay:0 options:[[[sender userInfo] objectForKey:@"UIKeyboardAnimationCurveUserInfoKey"] integerValue] << 16 animations:^{
//            
//        } completion:nil];
//    }
//    
//}
//
//- (void)keyboardWillHide:(id)sender
//{
//    self.textField.transform = CGAffineTransformIdentity;
//    
//    if ([[[sender userInfo] objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue] > 0)
//    {
//        [UIView animateWithDuration:[[[sender userInfo] objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue] delay:0 options:[[[sender userInfo] objectForKey:@"UIKeyboardAnimationCurveUserInfoKey"] integerValue] << 16 animations:^{
//            
//        } completion:nil];
//    }
//}
//
//- (IBAction)endInput:(UITextField *)sender {
//    
//    NSLog(@"FFF");
//    [sender resignFirstResponder];
//}

#pragma mark - 发表评论

- (void)sendComment:(UIButton *)sender
{
    NSLog(@"sender 评论");
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
        _videoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, _screenWidth - 10, 30)];
        _videoTitleLabel.text = _videoTitle;
        _videoTitleLabel.textColor = [UIColor blackColor];
        _videoTitleLabel.textAlignment = NSTextAlignmentLeft;
        _videoTitleLabel.font = [UIFont systemFontOfSize:20.0f];
        _videoTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

        [headerView addSubview:_videoTitleLabel];
        
        // 发布时间
        _createTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, _videoTitleLabel.frame.origin.y + _videoTitleLabel.frame.size.height,  _screenWidth*3/4.0 - 10, 30)];
        _createTimeLabel.text = [NSString stringWithFormat:@"发布于: %@", _createTime];
        _createTimeLabel.textColor = [UIColor lightGrayColor];
        _createTimeLabel.textAlignment = NSTextAlignmentLeft;
        _createTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        _createTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

        [headerView addSubview:_createTimeLabel];
        
        // 编辑时间
        _editorLabel = [[UILabel alloc] initWithFrame:CGRectMake(_screenWidth*0.5 + 10, _createTimeLabel.frame.origin.y, _screenWidth*0.5 - 20, 30)];
        _editorLabel.text = [NSString stringWithFormat:@"编辑: %@", _editor];
        _editorLabel.textColor = [UIColor lightGrayColor];
        _editorLabel.textAlignment = NSTextAlignmentLeft;
        _editorLabel.font = [UIFont systemFontOfSize:14.0f];
        _editorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showVideoPlayer:)];
        [_videoImageView addGestureRecognizer:tap];

        // 视频播放按钮
        UIImage *image = [UIImage imageNamed:@"playBtn"];
        _playVideoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _playVideoImage.center = CGPointMake(_videoImageView.frame.size.width * 0.5, _videoImageView.frame.size.height * 0.5);
        _playVideoImage.image = image;
        _playVideoImage.userInteractionEnabled = YES;

        [_videoImageView addSubview:_playVideoImage];
        
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
//        _videoIntroductionLabel.font = [UIFont systemFontOfSize:11.0f];
//        _videoIntroductionLabel.textColor = [UIColor lightGrayColor];
        
        CGRect htmlRect = [html boundingRectWithSize:CGSizeMake(_screenWidth - 10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        _videoIntroductionLabel.frame = CGRectMake(_videoImageView.frame.origin.x, _videoImageView.frame.origin.y + _videoImageView.frame.size.height, htmlRect.size.width, htmlRect.size.height);
        
        [headerView addSubview:_videoIntroductionLabel];

        
        headerView;
    });
    
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
        NSLog(@"详情: %@", reponse);
        
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
//            _videoIntroductionLabel.textColor = [UIColor blackColor];
            
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tableView]) {
        
        [_player playerScrollIsSupportSmallWindowPlay:YES];
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
