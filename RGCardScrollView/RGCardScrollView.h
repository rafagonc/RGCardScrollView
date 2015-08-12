//
//  RGCardScrollView.h
//  Components
//
//  Created by Rafael Gonzalves on 8/6/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import "RGAutoresizeScrollView.h"
#import "RGCardSwapAnimation.h"

@class RGCardItem;
@class RGDraggrableView;

@interface RGCardScrollView : RGAutoresizeScrollView

#pragma mark - properties
@property (nonatomic,readonly) NSUInteger count;
@property (nonatomic,assign) RGCardAnimationType animationType;
@property (nonatomic,assign) CGFloat closedPadding;
@property (nonatomic,assign) BOOL editing;

#pragma mark - methods
-(void)reloadData;

#pragma mark - insertion
-(void)insertSubview:(UIView *)view atOrder:(NSUInteger)order animated:(BOOL)animated;

#pragma mark -  deletion animation
-(void)deleteSubviewAtOrder:(NSUInteger)order animated:(BOOL)animated;
-(void)deleteSubviewAtOrder:(NSUInteger)order animated:(BOOL)animated completion:(void(^)())completion;

#pragma mark - swap animation
-(void)swapViewAtIndex:(NSUInteger)index withViewAtIndex:(NSUInteger)index2 andAnimationType:(RGCardAnimationType)animationType;
-(void)swapViewAtIndex:(NSUInteger)index withViewAtIndex:(NSUInteger)index2 andAnimationType:(RGCardAnimationType)animationType completion:(void(^)())completion;

@end

@protocol RGCardScrollViewDelegate <NSObject> @optional
-(void)cardScrollView:(RGCardScrollView *)cardScrollView didSelectViewAtIndex:(NSInteger)index;
-(void)cardScrollView:(RGCardScrollView *)cardScrollView didLongPressViewAtIndex:(NSInteger)index;
-(BOOL)cardScrollView:(RGCardScrollView *)cardScrollView canDeleteViewAtIndex:(NSInteger)index;
@end

@protocol RGCardScrollViewDatasource <NSObject> @required
-(NSInteger)numberOfCardsOnCardScrollView:(RGCardScrollView *)cardScrollView;
-(UIView *)cardScrollView:(RGCardScrollView *)cardScrollView  viewForIndex:(NSInteger)index;
@end

@interface RGCardScrollView ()
@property (nonatomic,weak) id<RGCardScrollViewDelegate> cardDelegate;
@property (nonatomic,weak) id<RGCardScrollViewDatasource> cardDatasource;
@end
