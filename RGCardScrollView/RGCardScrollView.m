
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

@interface RGCardScrollView () <UIScrollViewDelegate>

@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) RGCardItemSorter *sorter;
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
    self.editing = YES;
    
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
    if (self.shouldSortOnLayoutSubviews) [self.sorter sort:NO];
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
        
        __block RGCardItemScrollingShifter *shifter = [[RGCardItemScrollingShifter alloc] initWithItems:welf.items andSorter:welf.sorter];

        draggableView.startDraggingCallback = ^(RGDraggrableViewCallbackStructure structure) {
            [welf setScrollEnabled:NO];
        };
        draggableView.draggingCallback = ^(RGDraggrableViewCallbackStructure structure){
            if (welf.editing) {
                if (structure.direction == RGDraggrableViewDirectionVertical) {
                    shifter.item = wCardItem;
                    [shifter trackDraggingWithLocation:structure.viewPosition];
                    shifter.shifted = ^{
                        [welf.sorter sort:YES];
                    };
                } else {
                    RGCardItemRemover *remover = [[RGCardItemRemover alloc] initWithItem:wCardItem];
                    if (welf.cardDelegate && [welf.cardDelegate respondsToSelector:@selector(cardScrollView:canDeleteViewAtIndex:)]) {
                        if ([welf.cardDelegate cardScrollView:welf canDeleteViewAtIndex:[welf.items indexOfObject:wCardItem]]) {
                            [remover trackingHorizontalCardScrolling:structure.speed andDeletionCallback:^{
                                [welf setShoudLayoutOnDraggableEndDragging:NO];
                                [remover removeWithCompletion:^{
                                    [welf setShouldCalculateContentSize:NO];
                                    [welf setShoudLayoutOnDraggableEndDragging:YES];
                                    [welf.sorter sort:YES];
                                }];
                            }];
                        }
                    }
                }
            }
        };
        draggableView.endDraggingCallback = ^(RGDraggrableViewCallbackStructure structure) {
            if (self.shoudLayoutOnDraggableEndDragging) [welf.sorter sort:YES];
            [welf setScrollEnabled:YES];
        
        };
        cardItem.tapped = ^(NSUInteger xZorder, UIView *view) {
            [welf openItem:wCardItem];
        };
        
        [self.items insertObject:cardItem atIndex:order];
        
        return cardItem;
    }
    
    return nil;
}
-(void)willRemoveSubview:(UIView *)subview {
    RGCardItem *item = [self itemForSubview:subview];
    if (item)
        [self.items removeObject:item];

}
-(void)didMoveToSuperview {
    [self reloadData];
}

#pragma mark - runtime insertion and deletion
-(void)insertSubview:(UIView *)view atOrder:(NSUInteger)order animated:(BOOL)animated {
    RGCardItem *item = [self addSubview:view withOrder:order];
    item.view.layer.opacity = animated ? 0.0f : 1.0f;
    [self.sorter sort:animated];
}
-(void)deleteSubviewAtOrder:(NSUInteger)order animated:(BOOL)animated completion:(void(^)())completion {
    __weak typeof(self) welf = self;
    if (order >= self.items.count) return;
    RGCardItem *item = self.items[order];
    [RGCardItemRemover removeItem:item animated:animated andCompletion:^{
        [welf setShouldCalculateContentSize:NO];
        [welf.sorter sort:animated];
        if (completion) completion();
    }];
}
-(void)deleteSubviewAtOrder:(NSUInteger)order animated:(BOOL)animated {
    [self deleteSubviewAtOrder:order animated:animated completion:nil];
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
            self.editing = YES;
        } else {
            for (RGCardItem *item in self.items) item.opened = NO;
            item.opened = YES;
            self.editing = NO;
        }
        [self.sorter sort:YES];
    }
}

#pragma mark - helper methods
-(RGCardItem *)itemForSubview:(UIView *)subview {
    for (RGCardItem *item in self.items) {
        if ([item.view isEqual:subview]) return item;
    }
    return nil;
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
    
}

@end
