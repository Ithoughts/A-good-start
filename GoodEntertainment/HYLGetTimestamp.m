//
//  HYLGetTimestamp.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/15/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLGetTimestamp.h"

@implementation HYLGetTimestamp

+ (NSString *)getTimestampString
{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval interval = [now timeIntervalSince1970];
    NSString *timestamp = [NSString stringWithFormat:@"%.0f", interval];
    
    return timestamp;
}

@end
