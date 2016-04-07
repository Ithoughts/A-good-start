//
//  HYLGetSignature.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/15/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLGetSignature.h"

// md5 加密
#import <CommonCrypto/CommonDigest.h>

@implementation HYLGetSignature

+ (NSString *)getSignature:(NSString *)timestamp
{
    // api_key
    NSString *key = @"6d87a19f011653459575ceb722db3b69";
    // 时间戳、api_key 拼接
    NSString *spliceString = [NSString stringWithFormat:@"time=%@&key=%@", timestamp, key];
    
    // md5 加密
    const char *cStr = [spliceString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02X",digest[i]];
    }

    // 转小写
    NSString *lowerString = output.lowercaseString;
    
    return lowerString;
}

@end
