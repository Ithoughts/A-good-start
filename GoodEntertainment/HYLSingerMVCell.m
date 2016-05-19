//
//  HYLSingerMVCell.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 4/15/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLSingerMVCell.h"
//#import "HYLArtistMusicListModel.h"

//#import <UIImageView+WebCache.h>

@interface HYLSingerMVCell ()

@end

@implementation HYLSingerMVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)setModel:(HYLArtistMusicListModel *)model {
//    
//    _model = model;
//    
//    self.titleLabel.text = model.title;
//    self.authorLabel.text = model.author;
//    
//    [self.avatar sd_setImageWithURL:[NSURL URLWithString:model.cover_url]];
//}


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
    
    _avatar = [[UIImageView alloc] init];
    _avatar.frame = CGRectMake(5, 0, 100, 100);
    _avatar.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_avatar];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 23, screenWidth - 75, 30)];
    _titleLabel.font = [UIFont systemFontOfSize:16.0f];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLabel];
    
    _authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 48, screenWidth - 75, 30)];
    _authorLabel.font = [UIFont systemFontOfSize:16.0f];
    _authorLabel.textColor = [UIColor lightGrayColor];
    _authorLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_authorLabel];
}

@end
