//
//  HYLVideoCommentCell.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 4/11/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYLVideoCommentCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UIImageView *honorImageView;
@property (nonatomic, strong) UILabel     *honorCountLabel;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *createdTimeLabel;
@property (nonatomic, strong) UILabel     *commentLabel;

@end
