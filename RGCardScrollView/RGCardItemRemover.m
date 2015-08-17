//
//  RGCardItemRemover.m
//  Components
//
//  Created by Rafael Gonzalves on 8/10/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import "RGCardItemRemover.h"
#import "RGDraggrableView.h"
#import "RGCardItem.h"
#import "RGAnimationQueueOperation.h"

@interface RGCardItemRemover ()

@property (nonatomic,weak) RGCardItem *item;
@property (nonatomic,assign) BOOL animated;

@end

@implementation RGCardItemRemover

#pragma mark - constructor
-(instancetype)initWithItem:(RGCardItem *)item {
    if (self = [super init]) {
        self.item = item;
        self.animated = YES;
    } return self;
}

#pragma mark - tracking
-(void)trackingHorizontalCardScrolling:(CGFloat)velocity andDeletionCallback:(void(^)())deletionCallback {
    if ((velocity) > 1000) {
        RGDraggrableView *draggableView = (RGDraggrableView *)self.item.view;
        draggableView.draggable = NO;
        draggableView.userInteractionEnabled = NO;
        if (deletionCallback) deletionCallback();
        deletionCallback = nil;
    }
}

#pragma mark - remove
-(RGAnimationQueueOperation *)removeAnimationItem {
    if (self.animated) {
        CGFloat xDestination = [UIScreen mainScreen].bounds.size.width + self.item.view.frame.size.width + 30;
        
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.keyPath = @"position.x";
        animation.duration = 0.4;
        animation.delegate = self;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.fromValue = @(self.item.view.frame.origin.x);
        animation.toValue = @(xDestination);
        
        RGAnimationQueueOperation *op = [[RGAnimationQueueOperation alloc] initWithAnimation:animation onView:self.item.view forKey:@"slipOut"];
        op.modalLayerChangingCallback = ^{[self.item.view setFrame:CGRectMake(xDestination, self.item.view.frame.origin.y, self.item.view.frame.size.width, self.item.view.frame.size.height)];};
        op.animationDidStopCallback = ^{[self.item.view removeFromSuperview];};
        
        return op;
    } else {
        [self.item.view removeFromSuperview];
        return nil;
    }
    
}


//#pragma mark - factory method
//+(void)removeItem:(RGCardItem *)item animated:(BOOL)animated andCompletion:(void(^)())completion {
//    RGCardItemRemover *remover = [[RGCardItemRemover alloc] initWithItem:item];
//    remover.animated = animated;
//    [remover removeWithCompletion:completion];
//}

@end
