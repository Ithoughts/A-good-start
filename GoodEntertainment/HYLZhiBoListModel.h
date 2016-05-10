//
//  HYLZhiBoListModel.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/29/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLJSONModel.h"

@class  VideoInfoModel;

@interface HYLZhiBoListModel : HYLJSONModel

@property (nonatomic, assign) NSInteger videoId;

@property (nonatomic, copy) NSString *video_category_id;

@property (nonatomic, copy) NSString *video_info_id;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *author;

@property (nonatomic, copy) NSString *view_count;

@property (nonatomic, copy) NSString *comment_count;

@property (nonatomic, copy) NSString *like_count;

@property (nonatomic, copy) NSString *summary;

@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, copy) NSString *updated_at;

@property (nonatomic, strong) VideoInfoModel *video_info;


@end


@interface VideoInfoModel : HYLJSONModel



@property (nonatomic, assign) NSInteger videoInfoId;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *cover_url;




@property (nonatomic, copy) NSString *aspect;

@property (nonatomic, copy) NSString *cover_width;

@property (nonatomic, copy) NSString *remote_id;

@property (nonatomic, copy) NSString *cover_height;

@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, copy) NSString *updated_at;

@property (nonatomic, copy) NSString *bitrate;

@property (nonatomic, copy) NSString *is_audio;


@end

