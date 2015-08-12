//
//  RGCardItemShifter.h
//  Components
//
//  Created by Rafael Gonzalves on 8/7/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

@import UIKit;
@class RGCardItem;
@class RGCardItemSorter;

@interface RGCardItemScrollingShifter : NSObject

#pragma mark - constructor
-(instancetype)initWithItems:(NSMutableArray *)items andSorter:(RGCardItemSorter *)sorter;

#pragma mark - methods
-(void)trackDraggingWithLocation:(CGPoint)centerOfDraggingView ;

#pragma mark - callback
@property (nonatomic,copy) void(^shifted)();

#pragma mark - properties
@property (nonatomic,weak) RGCardItem *item;


@end
