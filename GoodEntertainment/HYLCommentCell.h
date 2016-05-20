//
//  HYLCommentCell.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 5/20/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYLCommentCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *created_atLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *like_countButton;
@property (nonatomic, strong) UILabel *like_countLabel;

//- (void)comment:(UIButton *)sender;

@end
