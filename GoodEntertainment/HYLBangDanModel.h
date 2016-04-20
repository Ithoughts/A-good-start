//
//  HYLBangDanModel.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/29/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLJSONModel.h"

@class  BangDanDetailInfoData, VideoInfo, Artist, Pivot;

//
@interface HYLBangDanModel : HYLJSONModel

@property (nonatomic, assign) NSInteger status;

@property (nonatomic, assign) NSInteger per_page;

@property (nonatomic, assign) NSInteger from;

@property (nonatomic, assign) NSInteger to;

@property (nonatomic, strong) NSMutableArray<BangDanDetailInfoData *> *data;

@property (nonatomic, copy) NSString *next_page_url;

@property (nonatomic, assign) NSInteger total;

@property (nonatomic, assign) NSInteger current_page;

@property (nonatomic, assign) NSInteger last_page;

@property (nonatomic, copy) NSString *prev_page_url;

@end

//
@interface BangDanDetailInfoData : HYLJSONModel

@property (nonatomic, assign) NSInteger musicId;

@property (nonatomic, copy) NSString *music_category_id;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *video_info_id;

@property (nonatomic, copy) NSString *author;

@property (nonatomic, copy) NSString *summary;

@property (nonatomic, copy) NSString *view_count;

@property (nonatomic, copy) NSString *comment_count;

@property (nonatomic, copy) NSString *like_count;

@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, copy) NSString *updated_at;

@property (nonatomic, strong) VideoInfo *video_info;

@property (nonatomic, strong) NSMutableArray<Artist *> *artist;

@end


//
@interface VideoInfo : HYLJSONModel

@property (nonatomic, copy) NSString *aspect;

@property (nonatomic, copy) NSString *cover_url;

@property (nonatomic, copy) NSString *cover_width;

@property (nonatomic, assign) NSInteger videoId;

@property (nonatomic, copy) NSString *remote_id;

@property (nonatomic, copy) NSString *cover_height;

@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, copy) NSString *updated_at;

@property (nonatomic, copy) NSString *bitrate;

@property (nonatomic, copy) NSString *is_audio;

@property (nonatomic, copy) NSString *url;

@end


//
@interface Artist : HYLJSONModel

@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, copy) NSString *summary;

@property (nonatomic, assign) NSInteger artistId;

@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, copy) NSString *updated_at;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) Pivot *pivot;

@end


//
@interface Pivot : HYLJSONModel

@property (nonatomic, copy) NSString *music_artist_id;

@property (nonatomic, copy) NSString *music_id;

@end

