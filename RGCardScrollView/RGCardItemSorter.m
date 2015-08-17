//
//  RGCardItemSorter.m
//  Components
//
//  Created by Rafael Gonzalves on 8/7/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import "RGCardItemSorter.h"
#import "RGCardItem.h"
#import "RGDraggrableView.h"
#import "RGAnimationQueueOperationComposite.h"

@interface RGCardItemSorter ()

@property (nonatomic,strong) NSMutableArray * cards;;

@end

@implementation RGCardItemSorter

#pragma mark - constructor
-(instancetype)initWithCardsArray:(NSMutableArray *)cardsArray {
    if (self = [super init]) {
        self.cards = cardsArray;
        self.closedPadding = 60;
    } return self;
}

#pragma mark - sort
-(void)sortViewsAndSendThemToTheRightPlaces {
    [self.cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RGCardItem *item = (RGCardItem *)obj;
        RGDraggrableView *draggable = (RGDraggrableView *)item.view;
        [item.view.superview bringSubviewToFront:draggable];
        if (draggable.dragging == NO) {
            item.view.frame = [self rectForCardItem:item];
        }
    }];
}
-(RGAnimationQueueOperationComposite *)compositeSortingAnimation {
    RGAnimationQueueOperationComposite *animationItem = [[RGAnimationQueueOperationComposite alloc] initWithKey:@"comeBackToPlace"];
    for (int i = 0; i < self.cards.count; i++) {
        RGCardItem *item = (RGCardItem *)self.cards[i];
        RGDraggrableView *draggable = (RGDraggrableView *)item.view;
        [item.view.superview bringSubviewToFront:draggable];
        if (draggable.dragging == NO) [animationItem addAnimation:[self animationForItem:item] onView:item.view andModalLayerChanges:^{
            item.view.frame = [self rectForCardItem:item];
            item.view.layer.opacity = 1.0f;
        }];
    }
    return animationItem;
}

#pragma mark - helper methods
-(CGRect)rectForCardItem:(RGCardItem *)item {
    return CGRectMake(item.view.superview.frame.size.width/2 - item.view.frame.size.width/2, [self yForItem:item] , item.view.frame.size.width, item.view.frame.size.height);
}
-(CGFloat)yForItem:(RGCardItem *)item {
    __block CGFloat yAmount = 0;
    for (NSUInteger i = 0; i < self.cards.count; i++) {
        RGCardItem *itemToCompare = self.cards[i];
        
        //check if opened
        BOOL previewIsOpened = NO;
        if (i > 0) previewIsOpened = [(RGCardItem *)self.cards[i - 1] opened];
        yAmount += (previewIsOpened ? item.view.frame.size.height : 0);
        
        //break if reaches item
        if ([itemToCompare isEqual:item]) break;
        yAmount = yAmount + self.closedPadding;
    }
    return yAmount;
}
-(RGCardItem *)openedItem {
    for (RGCardItem *item in self.cards) {
        if (item.opened) return item;
    }
    return nil;
}

#pragma mark - animation
-(CAAnimation *)animationForItem:(RGCardItem *)item {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position";
    animation.duration = 0.2;
    animation.fromValue = [NSValue valueWithCGPoint:item.view.frame.origin];
    animation.toValue = [NSValue valueWithCGPoint:[self rectForCardItem:item].origin];
    
    if (item.view.layer.opacity < 0.1f) {
        CABasicAnimation *animation2 = [CABasicAnimation animation];
        animation.keyPath = @"opacity";
        animation.fromValue = @(item.view.layer.opacity);
        animation.toValue = @1;
        animation.duration = 0.2;
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        [group setAnimations:@[animation, animation2]];
        return group;
    }
    
    return animation;
}

#pragma mark - dealloc
-(void)dealloc {
    
}

@end
