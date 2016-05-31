//
//  HYLCollectionModel.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 5/24/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYLCollectionModel : NSObject

@property (nonatomic, assign) NSInteger videoId;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *video_info_id;

@property (nonatomic, copy) NSString *author;

@property (nonatomic, copy) NSString *view_count;

@property (nonatomic, copy) NSString *comment_count;

@property (nonatomic, copy) NSString *like_count;

@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, assign) NSInteger videoInfoId;

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *cover_url;

@property (nonatomic, copy) NSString *cover_width;

@property (nonatomic, copy) NSString *cover_height;


@end
