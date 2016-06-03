//
//  HYLSendCommentView.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 6/4/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLSendCommentView.h"
#import "UIViewExt.h"

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
    
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.94 alpha:1];
        
        _conView = [[UIView alloc] init];
        _conView.width = self.width - 16;
        _conView.height = 36;
        _conView.top = (self.height-36)/2;
        _conView.left = 8;
        _conView.backgroundColor = [UIColor whiteColor];
        _conView.layer.cornerRadius = _conView.height/2.0;
        _conView.layer.masksToBounds = true;
        _conView.userInteractionEnabled = YES;
        [self addSubview:_conView];
        
        _editIV = [[UIImageView alloc] init];
        _editIV.frame = CGRectMake(6, 9, 17, 14);
        _editIV.image = [UIImage imageNamed:@"textfieldbackground"];
        [_conView addSubview:_editIV];
        
        
        _sendBtn = [[UIButton alloc] init];
        _sendBtn.frame = CGRectMake(_conView.width - 46, 0, 40, _conView.height);
        [_sendBtn setTitle:@"发表" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [_sendBtn setTitleColor:[UIColor colorWithRed:255/255.0f green:199/255.0 blue:3/255.0 alpha:1.0] forState:UIControlStateNormal];
        _sendBtn.tag = 10088;
        [_conView addSubview:_sendBtn];
        
        _textF = [[UITextField alloc] init];
        _textF.frame = CGRectMake(_editIV.right + 3, 0, _conView.width - _editIV.right - 3 - 46, 35);
        _textF.font = [UIFont systemFontOfSize:16.0f];
        _textF.placeholder = @"点击评论...";

        [_conView addSubview:_textF];
    }
    
    return self;
}

@end
