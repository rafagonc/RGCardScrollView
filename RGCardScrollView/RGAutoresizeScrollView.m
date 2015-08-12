//
//  RGAutoresizeScrollView.m
//  Components
//
//  Created by Rafael Gonzalves on 8/5/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import "RGAutoresizeScrollView.h"

@interface RGAutoresizeScrollView ()

@property (nonatomic,assign) CGFloat keyboardHeight;

@end

@implementation RGAutoresizeScrollView

#pragma mark - constructor
-(instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    } return self;
}
-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    } return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    } return self;
}
-(void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}
-(void)commonInit {
    self.lock = RGAutoresizeScrollViewDirectionLockNone;
    self.addedSubviews = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

}

#pragma mark - overrides
-(void)addSubview:(UIView *)view {
    [super addSubview:view];
    if (![self isProbablyAScrollBar:view]) [self.addedSubviews addObject:view];
    self.contentSize = [self calculateContentSize];
}
-(bool)isProbablyAScrollBar:(UIView*)view {
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    return (([view isKindOfClass:[UIImageView class]]) && (view.frame.size.width <= (screenScale*3.5f) || view.frame.size.height <= (screenScale*3.5f)));
}

#pragma mark - calculation
-(CGSize)calculateContentSize {
    CGSize contentSize;
    for (UIView *view in self.addedSubviews) {
        contentSize.height = MAX(contentSize.height, view.frame.origin.y + view.frame.size.height);
        contentSize.width  = MAX(contentSize.width, view.frame.origin.x + view.frame.size.width);
    }
    contentSize.height += self.keyboardHeight;
    
    if (self.lock == RGAutoresizeScrollViewDirectionLockHorizontal) contentSize = CGSizeMake(0, contentSize.height);
    else if (self.lock == RGAutoresizeScrollViewDirectionLockVertical) contentSize = CGSizeMake(contentSize.width, 0);
    
    return contentSize;
}

#pragma mark - notification
-(void)keyboardDidShow:(NSNotification *)notification {
    self.keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
}
-(void)keyboardDidHide:(NSNotification *)notification {
    self.keyboardHeight = 0;
}
-(void)keyboardFrameChanged:(NSNotification *)notification {
    self.keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
}

#pragma mark - getters and setters
-(void)setKeyboardHeight:(CGFloat)keyboardHeight {
    _keyboardHeight = keyboardHeight;
    self.contentSize = [self calculateContentSize];
}

#pragma mark - dealloc
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

@end
