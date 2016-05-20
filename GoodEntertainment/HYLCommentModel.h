//
//  HYLCommentModel.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 5/20/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYLCommentModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *created_at;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *like_count;

@property (nonatomic, copy) NSString *comment_id;

@end
