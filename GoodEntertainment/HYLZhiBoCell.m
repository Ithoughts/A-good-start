//
//  HYLZhiBoCell.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/29/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLZhiBoCell.h"

@implementation HYLZhiBoCell

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
    
    _videoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, contentViewWidth, 220)];
    _videoImage.contentMode = UIViewContentModeScaleToFill;
    [self.contentView addSubview:_videoImage];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, _videoImage.frame.size.height*0.5 - 20, contentViewWidth, 30)];
    _title.textColor = [UIColor whiteColor];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.font = [UIFont systemFontOfSize:18.0f];
    _title.numberOfLines = 1;
    [_videoImage addSubview:_title];
    
    _updated_at = [[UILabel alloc] initWithFrame:CGRectMake(0, _videoImage.frame.size.height*0.5, contentViewWidth, 30)];
    _updated_at.textColor = [UIColor whiteColor];
    _updated_at.textAlignment = NSTextAlignmentCenter;
    _updated_at.font = [UIFont systemFontOfSize:15.0f];
    _updated_at.numberOfLines = 1;
    [_videoImage addSubview:_updated_at];
}

@end
