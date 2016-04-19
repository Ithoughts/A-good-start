//
//  HYLVideoCommentCell.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 4/11/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLVideoCommentCell.h"

@implementation HYLVideoCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self configureCell];
    }
    
    return self;
}

- (void)configureCell
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    //
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 90, 90)];
    _avatar.clipsToBounds = YES;
    _avatar.contentMode = UIViewContentModeScaleAspectFit;
    _avatar.image = [UIImage imageNamed:@"defaultImage"];
    [self.contentView addSubview:_avatar];
    
    
    //
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatar.frame.origin.x + _avatar.frame.size.width + 5, _avatar.frame.origin.y, 100, 30)];
    _nameLabel.text = @"武艺凡";
    _nameLabel.font = [UIFont systemFontOfSize:12.0f];
    _nameLabel.textColor = [UIColor lightGrayColor];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_nameLabel];
    
    //
    _createdTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatar.frame.origin.x + _avatar.frame.size.width + 5, _nameLabel.frame.origin.y + 25, 180, 30)];
    _createdTimeLabel.text = @"2016-03-30 14:41:34";
    _createdTimeLabel.font = [UIFont systemFontOfSize:12.0f];
    _createdTimeLabel.textColor = [UIColor lightGrayColor];
    _createdTimeLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_createdTimeLabel];
    
    //
    _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatar.frame.origin.x + _avatar.frame.size.width + 5, _createdTimeLabel.frame.origin.y + 25, 180, 30)];
    _commentLabel.text = @"好，好，好";
    _commentLabel.font = [UIFont systemFontOfSize:12.0f];
    _commentLabel.textColor = [UIColor lightGrayColor];
    _commentLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_commentLabel];
    
    //
    _honorCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 45, _avatar.frame.origin.y - 2, 30, 30)];
    _honorCountLabel.text = @"20";
    _honorCountLabel.font = [UIFont systemFontOfSize:12.0f];
    _honorCountLabel.textColor = [UIColor lightGrayColor];
    _honorCountLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_honorCountLabel];
    
    //
    _honorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_honorCountLabel.frame.origin.x + _honorCountLabel.frame.size.width - 10, _avatar.frame.origin.y, 23, 23)];
    _honorImageView.clipsToBounds = YES;
    _honorImageView.contentMode = UIViewContentModeScaleAspectFit;
    _honorImageView.image = [UIImage imageNamed:@"dianzan"];
    [self.contentView addSubview:_honorImageView];
    
}

@end
