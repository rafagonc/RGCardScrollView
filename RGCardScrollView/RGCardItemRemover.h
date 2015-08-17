//
//  RGCardItemRemover.h
//  Components
//
//  Created by Rafael Gonzalves on 8/10/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

@import UIKit;

@class RGDraggrableView;
@class RGCardItem;
@class RGAnimationQueueOperation;

@interface RGCardItemRemover : NSObject

#pragma mark - constructor
-(instancetype)initWithItem:(RGCardItem *)item;

#pragma mark - tracking
-(void)trackingHorizontalCardScrolling:(CGFloat)velocity andDeletionCallback:(void(^)())deletionCallback ;

#pragma mark - remove
-(RGAnimationQueueOperation *)removeAnimationItem;

#pragma mark - factory method


@end
