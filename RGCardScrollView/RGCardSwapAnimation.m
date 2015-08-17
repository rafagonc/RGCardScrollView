//
//  RGCardAnimation.m
//  Components
//
//  Created by Rafael Gonzalves on 8/7/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import "RGCardSwapAnimation.h"
#import "RGCardItem.h"
#import "RGCardItemSorter.h"

@interface RGCardSwapAnimation ()

@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) RGCardItemSorter *sorter;
@property (nonatomic,copy) void(^completion)();

@end

@implementation RGCardSwapAnimation

#pragma mark - constructor
-(instancetype)initFromItem:(RGCardItem *)fromItem toItem:(RGCardItem *)toItem andSorter:(RGCardItemSorter *)sorter andAnimationType:(RGCardAnimationType)type andItems:(NSMutableArray *)items {
    if (self = [super init]) {
        self.fromItem = fromItem;
        self.toItem = toItem;
        self.sorter = sorter;
        self.items = items;
        self.type = type;
    } return self;
}

#pragma mark - run
-(void)runWithCompletion:(void(^)(void))completion {
    self.completion = completion;
    if (self.type == RGCardAnimationTypeShift) {
        [self shiftAnimation];
    } else {
        [self swapAnimation];
    }
    [self.sorter sortViewsAndSendThemToTheRightPlaces];
}

#pragma mark - animation types
-(void)shiftAnimation {
    NSUInteger destinationIndex = [self.items indexOfObject:self.toItem];
    for (NSInteger i = [self.items indexOfObject:self.fromItem] + 1; i <= destinationIndex; i++) {
        self.items[i - 1] = self.items[i];
        RGCardItem *item = self.items[i];
        
        CABasicAnimation *fromItemAnimation = [CABasicAnimation animation];
        fromItemAnimation.delegate = self;
        fromItemAnimation.keyPath = @"position.y";
        fromItemAnimation.fromValue = @(item.view.frame.origin.y);
        fromItemAnimation.toValue = @([self.sorter rectForCardItem:item].origin.y);
        fromItemAnimation.duration = [self durationFrom:item.view.frame.origin.y to:[self.sorter rectForCardItem:item].origin.y];
        fromItemAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [item.view.layer addAnimation:fromItemAnimation forKey:@"cardSortingAnimation"];
        
    }
    
    [self.items removeObjectAtIndex:destinationIndex];
    [self.items insertObject:self.fromItem atIndex:destinationIndex];
    
    CABasicAnimation *toItem = [CABasicAnimation animation];
    toItem.delegate = self;
    toItem.keyPath = @"position.y";
    toItem.fromValue = @(self.fromItem.view.frame.origin.y);
    toItem.toValue = @([self.sorter rectForCardItem:self.fromItem].origin.y);
    toItem.duration = [self durationFrom:self.fromItem.view.frame.origin.y to:[self.sorter rectForCardItem:self.fromItem].origin.y];
    toItem.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.fromItem.view.layer addAnimation:toItem forKey:@"cardSortingAnimation"];
    
}
-(void)swapAnimation {
    [self.items exchangeObjectAtIndex:[self.items indexOfObject:self.fromItem] withObjectAtIndex:[self.items indexOfObject:self.toItem]];
    
    CABasicAnimation *fromItemAnimation = [CABasicAnimation animation];
    fromItemAnimation.delegate = self;
    fromItemAnimation.keyPath = @"position.y";
    fromItemAnimation.fromValue = @(self.fromItem.view.frame.origin.y);
    fromItemAnimation.toValue = @([self.sorter rectForCardItem:self.fromItem].origin.y);
    fromItemAnimation.duration = [self durationFrom:self.fromItem.view.frame.origin.y to:[self.sorter rectForCardItem:self.fromItem].origin.y];
    fromItemAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.fromItem.view.layer addAnimation:fromItemAnimation forKey:@"cardSortingAnimation"];
    
    CABasicAnimation *toItemAnimation = [CABasicAnimation animation];
    toItemAnimation.keyPath = @"position.y";
    toItemAnimation.fromValue = @(self.toItem.view.frame.origin.y);
    toItemAnimation.toValue = @([self.sorter rectForCardItem:self.toItem].origin.y);
    toItemAnimation.duration = [self durationFrom:self.toItem.view.frame.origin.y to:[self.sorter rectForCardItem:self.toItem].origin.y];
    toItemAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.toItem.view.layer addAnimation:toItemAnimation forKey:@"cardSortingAnimation"];
}

#pragma mark - helpers
-(NSTimeInterval)durationFrom:(CGFloat)y to:(CGFloat)y2 {
    CGFloat vel = 600/1.0; //320 px per second
    CGFloat deltaY = y2 - y;
    CGFloat duration = fabs(deltaY/vel);
    return (duration);
}

#pragma mark - delegate
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.completion) self.completion();
    self.completion = nil;
}

#pragma mark - dealloc
-(void)dealloc {
}


@end
