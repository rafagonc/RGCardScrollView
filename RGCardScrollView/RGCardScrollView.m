
//
//  RGCardScrollView.m
//  Components
//
//  Created by Rafael Gonzalves on 8/6/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import "RGCardScrollView.h"
#import "RGCardItemSorter.h"
#import "RGCardItem.h"
#import "RGCardSwapAnimation.h"
#import "RGDraggrableView.h"
#import "RGCardItemScrollingShifter.h"
#import "RGCardItemRemover.h"
#import "RGCardViewCustomizer.h"
#import "RGAnimationQueue.h"

@interface RGCardScrollView () <UIScrollViewDelegate>

@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) RGCardItemSorter *sorter;
@property (nonatomic,strong) RGAnimationQueue *animationQueue;
@property (nonatomic,assign) BOOL shouldCalculateContentSize;
@property (nonatomic,assign) BOOL shouldSortOnLayoutSubviews;
@property (nonatomic,assign) BOOL shoudLayoutOnDraggableEndDragging;


@end

@implementation RGCardScrollView

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
    [super commonInit];
    
    self.shoudLayoutOnDraggableEndDragging = YES;
    self.shouldSortOnLayoutSubviews=  YES;
    self.shouldCalculateContentSize = YES;
    self.animationQueue = [[RGAnimationQueue alloc] init];
    self.editing = YES;
    self.lock = RGAutoresizeScrollViewDirectionLockHorizontal;
    
    self.delegate = self;
    self.closedPadding = 60;
    self.items = [[NSMutableArray alloc] init];
    self.animationType = RGCardAnimationTypeShift;
    
    self.sorter = [[RGCardItemSorter alloc] initWithCardsArray:self.items];
    self.sorter.closedPadding = self.closedPadding;
}

#pragma mark - layout
-(void)layoutSubviews {
    [super layoutSubviews];
    if (self.shouldSortOnLayoutSubviews) {
        [self.sorter sortViewsAndSendThemToTheRightPlaces];
    }
    if (self.shouldCalculateContentSize) self.contentSize = [self calculateContentSize];

}

#pragma mark - overrides
-(RGCardItem *)addSubview:(UIView *)view withOrder:(NSUInteger)order {
    if ([self isProbablyAScrollBar:view] == NO) {
        //Add to the draggable view
        RGDraggrableView *draggableView = [[RGDraggrableView alloc] initWithFrame:view.frame];
        draggableView.draggable = self.editing;
        [draggableView addSubview:view];
        
        //Add to card item
        RGCardItem *cardItem = [[RGCardItem alloc] initWithView:draggableView andOrder:order];
        draggableView.layer.anchorPoint = CGPointMake(0, 0);
        
        //Customize
        [RGCardViewCustomizer customizeView:draggableView];
        
        //Add as scroll view subview
        [super addSubview:draggableView];
        
        __weak typeof(self) welf = self;
        __weak typeof(cardItem) wCardItem = cardItem;
        
        [self setupStartDraggingForDraggableView:draggableView];
        [self setupDraggingCallbackForDraggableView:draggableView andCardItem:wCardItem];
        [self setupEndDraggingForDraggableView:draggableView];
        
        cardItem.tapped = ^(UIView *view) {[welf openItem:wCardItem];};
        cardItem.longPressed = ^(UIView *view) {[welf longPressedItem:wCardItem];};
        
        [self.items insertObject:cardItem atIndex:order];
        
        return cardItem;
    }
    
    return nil;
}
-(void)willRemoveSubview:(UIView *)subview {
    RGCardItem *item = [self itemForSubview:subview];
    if (item)[self.items removeObject:item];

}
-(void)didMoveToSuperview {
    [self reloadData];
}

#pragma mark - draggable setups
-(void)setupStartDraggingForDraggableView:(RGDraggrableView *)draggableView {
    __weak typeof(self) welf = self;
    draggableView.startDraggingCallback = ^(RGDraggrableViewCallbackStructure structure) {
        [welf setScrollEnabled:NO];
    };
}
-(void)setupDraggingCallbackForDraggableView:(RGDraggrableView *)draggableView andCardItem:(RGCardItem *)item {
    __weak typeof(self) welf = self;
    __block RGCardItemScrollingShifter *shifter = [[RGCardItemScrollingShifter alloc] initWithItems:welf.items andSorter:welf.sorter];
    draggableView.draggingCallback = ^(RGDraggrableViewCallbackStructure structure){
        if (welf.editing == NO) return;
        if (structure.direction == RGDraggrableViewDirectionVertical) {
            shifter.item = item;
            [shifter trackDraggingWithLocation:structure.viewPosition];
            shifter.shifted = ^{
                [(id<RGAnimationQueueOperationProtocol>)[welf.sorter compositeSortingAnimation] runWithCompletion:nil];
            };
        } else {
            RGCardItemRemover *remover = [[RGCardItemRemover alloc] initWithItem:item];
            if (welf.cardDelegate && [welf.cardDelegate respondsToSelector:@selector(cardScrollView:canDeleteViewAtIndex:)]) {
                if ([welf.cardDelegate cardScrollView:welf canDeleteViewAtIndex:[welf.items indexOfObject:item]]) {
                    [remover trackingHorizontalCardScrolling:structure.speed andDeletionCallback:^{
                        
                    }];
                }
            }
        }
    };
}
-(void)setupEndDraggingForDraggableView:(RGDraggrableView *)draggableView {
    __weak typeof(self) welf = self;
    draggableView.endDraggingCallback = ^(RGDraggrableViewCallbackStructure structure) {
        if (welf.shoudLayoutOnDraggableEndDragging) {
            [welf animatedSortIntoPlaces];
        }
        [welf setScrollEnabled:YES];
        
    };
}

#pragma mark - runtime insertion, deletion and swapping
-(void)insertSubview:(UIView *)view atOrder:(NSUInteger)order animated:(BOOL)animated {
    if (self.editing == NO) return;
    RGCardItem *item = [self addSubview:view withOrder:order];
    item.view.layer.opacity = animated ? 0.0f : 1.0f; //fade out animation
    [self animatedSortIntoPlaces];
}
-(void)deleteSubviewAtOrder:(NSUInteger)order animated:(BOOL)animated {
    if (self.editing == NO || order >= self.items.count) return;
    
    RGCardItem *item = self.items[order];
    self.shoudLayoutOnDraggableEndDragging = NO;
    self.shouldSortOnLayoutSubviews = NO;
    
    [self.animationQueue addOperation:(id<RGAnimationQueueOperationProtocol>)[[[RGCardItemRemover alloc] initWithItem:item] removeAnimationItem]];
    [self.items removeObjectAtIndex:order];
    [self.animationQueue addOperation:(id<RGAnimationQueueOperationProtocol>)[self.sorter compositeSortingAnimation]];
    [self.animationQueue run:^{
        self.shoudLayoutOnDraggableEndDragging = YES;
        self.shouldSortOnLayoutSubviews = YES;
    }];
}
-(void)swapViewAtIndex:(NSUInteger)index withViewAtIndex:(NSUInteger)index2 andAnimationType:(RGCardAnimationType)animationType {
    RGCardSwapAnimation *swap = [[RGCardSwapAnimation alloc] initFromItem:self.items[index] toItem:self.items[index2] andSorter:self.sorter andAnimationType:animationType andItems:self.items];
    [swap runWithCompletion:nil];
}

#pragma mark - data
-(void)reloadData {
    [self clean];
    for (NSInteger i = 0; i < [self.cardDatasource numberOfCardsOnCardScrollView:self]; i++) {
        UIView *view = [self.cardDatasource cardScrollView:self viewForIndex:i];
        if ([view isEqual:[NSNull null]] || view == nil) {
            NSAssert(0, @"A view nao pode ser nula ou [NSNull null]");
        }
        [self addSubview:view withOrder:i];
    }
}
-(void)clean {
    [self.items removeAllObjects];
    for (RGCardItem *item in self.items) {
        [item.view removeFromSuperview];
    }
}

#pragma mark - delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.shouldCalculateContentSize = NO;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        CGFloat r = sqrtf(fabs(scrollView.contentOffset.y));
        self.sorter.closedPadding =  (self.closedPadding + r);
    } else if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height) {
        CGFloat factor = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height);
        CGFloat r = sqrtf(factor);
        self.sorter.closedPadding = (self.closedPadding - r);
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.shouldCalculateContentSize = YES;
    });
}

#pragma mark - actions
-(void)openItem:(RGCardItem *)item {
    if ([item isEqual:self.items.lastObject]) {
        if (self.cardDelegate && [self.cardDelegate respondsToSelector:@selector(cardScrollView:didSelectViewAtIndex:)]) {
                [self.cardDelegate cardScrollView:self didSelectViewAtIndex:[self.items indexOfObject:item]];
        }
    } else {
        if (item.opened || [item isEqual:self.items.lastObject]) {
            item.opened = NO;
            if (self.cardDelegate || [self.cardDelegate respondsToSelector:@selector(cardScrollView:didSelectViewAtIndex:)]) {
                [self.cardDelegate cardScrollView:self didSelectViewAtIndex:[self.items indexOfObject:item]];
            }
        } else {
            for (RGCardItem *item in self.items) item.opened = NO;
            item.opened = YES;
        }
        [self animatedSortIntoPlaces];
    }
}
-(void)longPressedItem:(RGCardItem *)item {
    if (self.cardDelegate && [self.cardDelegate respondsToSelector:@selector(cardScrollView:didSelectViewAtIndex:)]) {
        [self.cardDelegate cardScrollView:self didLongPressViewAtIndex:[self.items indexOfObject:item]];
    }
}

#pragma mark - helper methods
-(RGCardItem *)itemForSubview:(UIView *)subview {
    for (RGCardItem *item in self.items) {
        if ([item.view isEqual:subview]) return item;
    }
    return nil;
}
-(void)animatedSortIntoPlaces {
    [self.animationQueue addOperation:(id<RGAnimationQueueOperationProtocol>)[self.sorter compositeSortingAnimation]];
    [self.animationQueue run:nil];
}

#pragma mark - getters
-(NSUInteger)count {
    return  self.items.count;
}

#pragma mark - setters
-(void)setEditing:(BOOL)canReorder {
    _editing = canReorder;
    for (RGCardItem *item in self.items) {
        RGDraggrableView *view = (RGDraggrableView *)item.view;
        view.draggable = canReorder;
    }
}
-(void)setClosedPadding:(CGFloat)closedPadding {
    _closedPadding = closedPadding;
    self.sorter.closedPadding = closedPadding;
}
-(void)setItemsUserInteraction:(BOOL)u {
    for (RGCardItem * item in self.items) {
        [item.view setUserInteractionEnabled:u];
    }
}

#pragma mark - dealloc
-(void)dealloc {
    NSLog(@"Dealloced");
}

@end
