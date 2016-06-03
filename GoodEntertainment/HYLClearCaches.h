//
//  HYLClearCaches.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 6/1/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYLClearCaches : NSObject

//获取缓存路径
+ (NSString *)getCachesPath:(NSString *)fileName;

//计算单个文件大小的方法
+ (long long)fileSizeAtPath:(NSString *)path;

//计算一个文件夹大小
+ (float)folderSizeAtPath:(NSString *)path;

//清空缓存方法
+ (void)cleanCaches:(NSString *)path;

@end
