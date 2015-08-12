//
//  RGCardViewCustomizer.m
//  Components
//
//  Created by Rafael Gonzalves on 8/11/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import "RGCardViewCustomizer.h"

@interface RGCardViewCustomizer ()

@property (nonatomic,strong) UIView *view;

@end

@implementation RGCardViewCustomizer

#pragma mark - constructor
-(instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        self.view = view;
    } return self;
}

#pragma mark - customize
-(void)customize {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, -4, _view.frame.size.width - 1, 30)];
    _view.layer.shadowPath = shadowPath.CGPath;
    _view.layer.masksToBounds = NO;
    _view.layer.shadowColor = [UIColor blackColor].CGColor;
    _view.layer.shadowRadius = 7.0;
    _view.layer.shadowOffset = CGSizeMake(0, -1);
    _view.layer.shadowOpacity = 0.3;
}

#pragma mark - factory method
+(void)customizeView:(UIView *)view {
    RGCardViewCustomizer *custom = [[RGCardViewCustomizer alloc] initWithView:view];
    [custom customize];
}

@end
