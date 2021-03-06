//
//  HYLCommentCell.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 5/20/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLCommentCell.h"

@implementation HYLCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self configureCell];
    }
    
    return self;
}

- (void)configureCell
{
    CGFloat contentViewWidth = [[UIScreen mainScreen] bounds].size.width;
    
    //
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 60, 60)];
    _avatar.contentMode = UIViewContentModeScaleAspectFit;
    _avatar.layer.cornerRadius = 10.0f;
    _avatar.layer.masksToBounds = YES;
    [self.contentView addSubview:_avatar];

    //
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatar.frame.origin.x + _avatar.frame.size.width + 10, 5, contentViewWidth - (_avatar.frame.origin.x + _avatar.frame.size.width + 10) - 60 - 5, 30)];
    _titleLabel.textColor = [UIColor lightGrayColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = [UIFont systemFontOfSize:16.0f];
    _titleLabel.numberOfLines = 1;
    [self.contentView addSubview:_titleLabel];

    //
    _created_atLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, 27, contentViewWidth - _titleLabel.frame.origin.x, 30)];
    _created_atLabel.textColor = [UIColor lightGrayColor];
    _created_atLabel.textAlignment = NSTextAlignmentLeft;
    _created_atLabel.font = [UIFont systemFontOfSize:16.0f];
    _created_atLabel.numberOfLines = 1;
    [self.contentView addSubview:_created_atLabel];
    
    //
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_created_atLabel.frame.origin.x, 49, contentViewWidth - _created_atLabel.frame.origin.x, 30)];
    _contentLabel.textColor = [UIColor blackColor];
    _contentLabel.textAlignment = NSTextAlignmentLeft;
    _contentLabel.font = [UIFont systemFontOfSize:16.0f];
    _contentLabel.numberOfLines = 1;
    [self.contentView addSubview:_contentLabel];
    
    //
    UIImage  *buttonImage  = [UIImage imageNamed:@"dianzan"];
    
    _like_countButton =  [UIButton buttonWithType:UIButtonTypeCustom];

    [_like_countButton setFrame:CGRectMake(contentViewWidth - 50, 30, 50, 30)];
    
    _like_countLabel = [[UILabel alloc]initWithFrame:CGRectMake(3, 6, buttonImage.size.width - 5, buttonImage.size.height - 5)];
    [_like_countLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [_like_countLabel setText:@"0"];
    _like_countLabel.textAlignment = NSTextAlignmentLeft;
    [_like_countLabel setTextColor:[UIColor blackColor]];
    [_like_countLabel setBackgroundColor:[UIColor clearColor]];
    [_like_countButton addSubview:_like_countLabel];
    
    [self.contentView addSubview:_like_countButton];
}

@end
