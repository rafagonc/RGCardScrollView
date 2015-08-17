//
//  RGAnimationQueueOperation.m
//  RGCardScrollView
//
//  Created by Rafael Gonzalves on 8/14/15.
//  Copyright (c) 2015 Rafael Gonçalves. All rights reserved.
//

#import "RGAnimationQueueOperation.h"

@interface RGAnimationQueueOperation ()

@property (nonatomic,copy) void(^runOnCompletion)();


@end

@implementation RGAnimationQueueOperation

#pragma mark - constructor
-(instancetype)init {
    NSAssert(0, @"Use the designated constructor -> -(instancetype)initWithAnimation:(CAAnimation *)animation onView:(UIView *)view forKey:(NSString *)key");
    return nil;
}
-(instancetype)initWithAnimation:(CAAnimation *)animation onView:(UIView *)view forKey:(NSString *)key {
    if (self = [super init]) {
        _animation = animation;
        _view = view;
        _key = key;
    } return self;
}

#pragma mark - running
-(void)runWithCompletion:(void (^)())completion {
    self.runOnCompletion = completion;
    self.animation.delegate = self;
    [self.view.layer addAnimation:self.animation forKey:self.key];
    if (self.modalLayerChangingCallback) self.modalLayerChangingCallback();
    self.modalLayerChangingCallback = nil;
}

#pragma mark - delegate
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.runOnCompletion) self.runOnCompletion();
    self.runOnCompletion = nil;
    if (self.animationDidStopCallback) self.animationDidStopCallback();
    self.animationDidStopCallback = nil;
}

#pragma mark - dealloc 
-(void)dealloc {
    NSLog(@"%@ - DEALLOC", NSStringFromClass(self.class));
}

@end
