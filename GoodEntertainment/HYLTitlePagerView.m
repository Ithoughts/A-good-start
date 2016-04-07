//
//  HYLTitlePagerView.m
//  GoodEntertainment
//
//  Created by Xiaowu Yin on 3/8/16.
//  Copyright © 2016 Xiaowu Yin. All rights reserved.
//

#import "HYLTitlePagerView.h"
#import "UIView+Additions.h"

// Main Screen
#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define SCREEN_WIDTH  [[UIScreen mainScreen]bounds].size.width
#define ORIGINAL_MAX_WIDTH 640.0f

// RGB
#define   RGB(r, g, b)   [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]

static CGFloat TitlePagerViewTitleSpace = 50;

@interface HYLTitlePagerView ()

@property (nonatomic, strong) NSMutableArray *views;
@property (nonatomic, strong) UIImageView *pageIndicator;
@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation HYLTitlePagerView

- (id)init {
    self = [super init];
    if (self) {
        self.views = [NSMutableArray array];
        [self addSubview:self.pageIndicator];
    }
    return self;
}

- (void)addObjects:(NSArray *)objects {
    self.titleArray = objects;
    
    [self.views makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.views removeAllObjects];
    
    __weak typeof(self) weakself = self;
    
    [objects enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if ([object isKindOfClass:[NSString class]]) {
            UILabel *textLabel = [[UILabel alloc] init];
            textLabel.text = object;
            textLabel.tag = idx;
            textLabel.textAlignment = NSTextAlignmentCenter;
            textLabel.font = self.font;
            textLabel.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tapTextLabel = [[UITapGestureRecognizer alloc] initWithTarget:weakself action:@selector(didTapTextLabel:)];
            [textLabel addGestureRecognizer:tapTextLabel];
            
            [weakself addSubview:textLabel];
            [weakself.views addObject:textLabel];
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.pageIndicator.y = self.height - 5;
    self.pageIndicator.width = (self.width - TitlePagerViewTitleSpace * (self.titleArray.count - 1))/self.titleArray.count;
    
    [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view sizeToFit];
        CGSize size = view.frame.size;
        size.width = self.width;
        CGFloat viewWidth = (size.width - TitlePagerViewTitleSpace * (self.titleArray.count - 1))/self.titleArray.count;
        view.frame = CGRectMake((viewWidth + TitlePagerViewTitleSpace) * idx, 0, viewWidth, size.height * 2);
    }];
}

- (void)didTapTextLabel:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTouchBWTitle:)]) {
        [self.delegate didTouchBWTitle:gestureRecognizer.view.tag];
    }
}

+ (CGFloat)calculateTitleWidth:(NSArray *)titleArray withFont:(UIFont *)titleFont {
    return [self getMaxTitleWidthFromArray:titleArray withFont:titleFont] * 3 + TitlePagerViewTitleSpace * 2;
}

+ (CGFloat)getMaxTitleWidthFromArray:(NSArray *)titleArray withFont:(UIFont *)titleFont {
    
    CGFloat maxWidth = 0;
    for (int i = 0; i < titleArray.count; i++) {
        NSString *titleString = [titleArray objectAtIndex:i];
        CGFloat titleWidth = [titleString sizeWithAttributes:@{NSFontAttributeName:titleFont}].width;
        if (titleWidth > maxWidth) {
            maxWidth = titleWidth;
        }
    }
    
    return maxWidth;
}

- (UIImageView *)pageIndicator {
    if (!_pageIndicator) {
        _pageIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
        _pageIndicator.image = [UIImage imageNamed:@"pager_indicator"];
        _pageIndicator.contentMode = UIViewContentModeScaleAspectFill;
        _pageIndicator.clipsToBounds = YES;
    }
    return _pageIndicator;
}

- (void)updatePageIndicatorPosition:(CGFloat)xPosition {
    CGFloat pageIndicatorXPosition = (((xPosition - SCREEN_WIDTH)/SCREEN_WIDTH) * (self.width - self.pageIndicator.width))/(self.titleArray.count - 1);
    self.pageIndicator.x = pageIndicatorXPosition;
}

- (void)adjustTitleViewByIndex:(CGFloat)index {
    for (UILabel *textLabel in self.subviews) {
        if ([textLabel isKindOfClass:[UILabel class]]) {
            textLabel.textColor = [UIColor whiteColor];
            if (textLabel.tag == index) {
//                textLabel.textColor = [UIColor colorWithRed:255/255.0f green:199/255.0f blue:3/255.0f alpha:1.0];
                textLabel.textColor = RGB(255, 199, 3);
            }
        }
    }
    
    if (index == 0) {
        self.pageIndicator.x = 0;
    } else if (index == self.titleArray.count - 1) {
        self.pageIndicator.x = self.width - self.pageIndicator.width;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
