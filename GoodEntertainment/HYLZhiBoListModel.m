//
//  HYLZhiBoListModel.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/29/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLZhiBoListModel.h"

@implementation HYLZhiBoListModel

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"video_info"]) {
        self.video_info = [[VideoInfoModel alloc] initWithDictionary:value];
    } else {
    
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.videoId = [value integerValue];
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end


@implementation VideoInfoModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.videoInfoId = [value integerValue];
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end


