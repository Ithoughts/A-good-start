//
//  HYLZhiBoCell.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/29/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYLZhiBoCell : UITableViewCell

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *updated_at;
@property (nonatomic, strong) UIImageView *videoImage;
@property (nonatomic, strong) UIImageView *orderImage;

 //获取图片高度
+ (CGFloat)getImageViewWidth:(float)width height:(float)height;

@end
