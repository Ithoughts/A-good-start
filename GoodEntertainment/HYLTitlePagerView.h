//
//  HYLTitlePagerView.h
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HYLTitlePagerViewDelegate <NSObject>

@optional
- (void)didTouchBWTitle:(NSUInteger)index;

@end


@interface HYLTitlePagerView : UIView

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, weak) id<HYLTitlePagerViewDelegate> delegate;

- (void)addObjects:(NSArray *)images;
- (void)adjustTitleViewByIndex:(CGFloat)index;
+ (CGFloat)calculateTitleWidth:(NSArray *)titleArray withFont:(UIFont *)titleFont;
- (void)updatePageIndicatorPosition:(CGFloat)xPosition;

@end
