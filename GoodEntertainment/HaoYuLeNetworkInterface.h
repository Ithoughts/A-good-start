//
//  HaoYuLeNetworkInterface.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/16/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#ifndef HaoYuLeNetworkInterface_h
#define HaoYuLeNetworkInterface_h


#define             kBaseURL              @"http://haoyule.www.fansye.com.cn"


                                    /********** 视频相关： ***********/


// 获取头条数据
#define             kTouTiaoURL           [NSString stringWithFormat:@"%@/api/video/headline", kBaseURL]

// 获取推介列表
#define             kTuiJieURL         [NSString stringWithFormat:@"%@/api/video/interview", kBaseURL]

// 获取原创列表
#define             kYuanChuangURL        [NSString stringWithFormat:@"%@/api/video/original", kBaseURL]

// 获取好精彩列表
#define             kJingCaiURL           [NSString stringWithFormat:@"%@/api/video/new", kBaseURL]

// 获取直播列表
#define             kZhiBoURL             [NSString stringWithFormat:@"%@/api/video/live", kBaseURL]

// 获取重温列表
#define             kChongWenURL          [NSString stringWithFormat:@"%@/api/video/rebroadcast", kBaseURL]

// 获取视频详情
#define             kShiPinDetailURL      [NSString stringWithFormat:@"%@/api/video/detail", kBaseURL]

// 发送验证码
#define             kSendCaptchaURL       [NSString stringWithFormat:@"%@/api/user/send_captcha", kBaseURL]


                                    /********** 音乐相关： ***********/

// 获取MV列表
#define             kMVListURL            [NSString stringWithFormat:@"%@/api/music/mv", kBaseURL]

// 获取show列表
#define             kShowListURL          [NSString stringWithFormat:@"%@/api/music/show", kBaseURL]

// 获取榜单列表
#define             kBangDanListURL       [NSString stringWithFormat:@"%@/api/music/list", kBaseURL]

// 获取音乐详情
#define             kMusicDetailURL       [NSString stringWithFormat:@"%@/api/music/detail", kBaseURL]

// 获取音乐评论
#define             kMusicCommentsURL     [NSString stringWithFormat:@"%@/api/music/comment", kBaseURL]

// 发表音乐评论
#define             kMakeCommentURL       [NSString stringWithFormat:@"%@/api/music/comment/music", kBaseURL]  // 本接口需要用户认证



                                  /********** 用户相关： ***********/

// 用户注册
#define             kUserRegisterURL      [NSString stringWithFormat:@"%@/api/user/register", kBaseURL]

// 用户登录
#define             kUserLoginURL         [NSString stringWithFormat:@"%@/api/user/auth", kBaseURL]

// 找回密码
#define             kGetPasswordURL       [NSString stringWithFormat:@"%@/api/user/find_password", kBaseURL]

// 获取用户信息
#define             kUserInfoURL          [NSString stringWithFormat:@"%@/api/user/info", kBaseURL]          // 本接口需要用户认证

// 修改用户信息
#define             kEditUserInfoURL      [NSString stringWithFormat:@"%@/api/user/info/update", kBaseURL]

// 修改用户密码
#define             kChangePasswordURL    [NSString stringWithFormat:@"%@/api/user/change_password", kBaseURL]

// 获取收藏的音乐
#define             kCollectMusicURL      [NSString stringWithFormat:@"%@/api/user/favorite", kBaseURL]      // 本接口需要用户认证

// 添加收藏
#define             kAddCollectionURL     [NSString stringWithFormat:@"%@/api/user/favorite/add", kBaseURL]  // 本接口需要用户认证



#endif /* HaoYuLeNetworkInterface_h */
