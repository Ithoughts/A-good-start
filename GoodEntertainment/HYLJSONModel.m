//
//  HYLJSONModel.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/28/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLJSONModel.h"

@implementation HYLJSONModel

- (id)initWithDictionary:(NSMutableDictionary *)jsonObject
{
    self = [super init];
    
    if (self) {
        [self setValuesForKeysWithDictionary:jsonObject];
    }
    
    return self;
}


- (id)valueForUndefinedKey:(NSString *)key
{
    NSLog(@"Undefined Key: %@", key);
    
    return nil;
}
- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key
{
     NSLog(@"Undefined Key: %@", key);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

@end
