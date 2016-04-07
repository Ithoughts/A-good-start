//
//  HYLBangDanModel.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/29/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLBangDanModel.h"


@implementation HYLBangDanModel

- (id)init
{
    self=[super init];
    
    if (self) {
        _data = [[NSMutableArray alloc] init];
    }
    
    return self;
}
- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"data"]) {
        
        for (NSDictionary *dict in value) {
            
            BangDanDetailInfoData *detailInfo = [[BangDanDetailInfoData alloc] initWithDictionary:dict];
            [self.data addObject:detailInfo];
        }
        
    } else {
    
        [super setValue:value forKey:key];
    }
}
@end



//
@implementation BangDanDetailInfoData

- (id)init
{
    self = [super init];
    
    if (self) {
        _artist = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"artist"]) {
        
        for (NSDictionary *dic in value) {
            
            Artist *artist = [[Artist alloc] initWithDictionary:dic];
            
            [_artist addObject:artist];
        }
        
    } else if ([key isEqualToString:@"video_info"]) {
        
        self.video_info = [[VideoInfo alloc] initWithDictionary:value];
        
    } else {
    
        [super setValue:value forKey:key];
    }
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        
        self.musicId = [value integerValue];
        
    } else {
    
        [super setValue:value forUndefinedKey:key];
    }
}
@end



//
@implementation VideoInfo

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.videoId = [value integerValue];
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}
@end



//
@implementation Artist

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.artistId = [value integerValue];
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"pivot"]) {
        self.pivot = [[Pivot alloc] initWithDictionary:value];
    } else {
    
        [super setValue:value forKey:key];
    }
}
@end


//
@implementation Pivot

@end


