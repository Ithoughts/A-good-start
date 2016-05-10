//
//  HYLSendCommentView.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 5/10/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLSendCommentView.h"

@implementation HYLSendCommentView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.94 alpha:1.0];
    
    self.conView.backgroundColor = [UIColor whiteColor];
    self.conView = [[UIView alloc] init];
    [self addSubview:self.conView];
    
    self.editIV = [[UIImageView alloc] init];
    self.editIV.image = [UIImage imageNamed:@"determineIcon"];
    [self.conView addSubview:self.editIV];
    
    [self.sendButton setTitle:@"发表" forState:UIControlStateNormal];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.sendButton setTitleColor:[UIColor colorWithRed:0.99 green:0.49 blue:0.17 alpha:1.0f] forState:UIControlStateNormal];
    self.sendButton.tag = 10099;
    [self.conView addSubview:self.sendButton];
    self.conView.userInteractionEnabled = YES;
    
    
    self.textField = [[UITextField alloc] init];
    [self.conView addSubview:self.textField];
    
    return self;

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.conView.width = self.width - 16;
    self.conView.height = 36;
    self.conView.top = (self.height - 36)/2;
    self.conView.left = 8;
    self.conView.backgroundColor = [UIColor whiteColor];
    self.conView.layer.cornerRadius = self.conView.height/2.0;
    self.conView.layer.masksToBounds = YES;
    self.editIV.frame = CGRectMake(6, 9, 17, 14);
    self.sendButton.frame = CGRectMake(self.conView.width - 46, 0, 40, self.conView.height);
    self.textField.frame = CGRectMake(self.editIV.right + 3, 0, self.conView.width - self.editIV.right - 3 - 46, 35);
    self.textField.font = [UIFont systemFontOfSize:14.0f];
    self.textField.placeholder = @"点击评论...";
}

@end
