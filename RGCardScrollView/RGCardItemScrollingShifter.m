//
//  RGCardItemShifter.m
//  Components
//
//  Created by Rafael Gonzalves on 8/7/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import "RGCardItemScrollingShifter.h"
#import "RGCardItem.h"
#import "RGCardItemSorter.h"

@interface RGCardItemScrollingShifter ()

@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,assign) NSInteger possibleNewOrder;
@property (nonatomic,strong) RGCardItemSorter *sorter;

@end

@implementation RGCardItemScrollingShifter

#pragma mark - constructor
-(instancetype)initWithItems:(NSMutableArray *)items andSorter:(RGCardItemSorter *)sorter {
    if (self = [super init]) {
        self.items = items;
        self.sorter = sorter;
    } return self;
}

#pragma mark - shift
-(void)trackDraggingWithLocation:(CGPoint)centerOfDraggingView {
    CGRect initialFrame = [self.sorter rectForCardItem:self.item];
    NSInteger shift = (initialFrame.origin.y - centerOfDraggingView.y) / self.sorter.closedPadding;
    self.possibleNewOrder = [self.items indexOfObject:self.item] - shift;
}

#pragma mark - getters and setters
-(void)setPossibleNewOrder:(NSInteger)possibleNewOrder {
    if (_possibleNewOrder == possibleNewOrder || possibleNewOrder > self.items.count - 1) return;
    _possibleNewOrder = possibleNewOrder;
    RGCardItem *itemToChange = self.items[_possibleNewOrder];
    [self.items exchangeObjectAtIndex:[self.items indexOfObject:self.item] withObjectAtIndex:[self.items indexOfObject:itemToChange]];
    if (self.shifted) self.shifted();
    
}


@end
