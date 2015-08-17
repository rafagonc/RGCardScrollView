//
//  RGCardItemSorter.h
//  Components
//
//  Created by Rafael Gonzalves on 8/7/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

@import UIKit;
@class RGCardItem;
@class RGAnimationQueueOperationComposite;

@interface RGCardItemSorter : NSObject

#pragma mark - constructor
-(instancetype)initWithCardsArray:(NSMutableArray *)cardsArray;

#pragma mark - priperties
@property (nonatomic,assign) CGFloat closedPadding;;

#pragma mark - sorting
-(void)sortViewsAndSendThemToTheRightPlaces;
-(RGAnimationQueueOperationComposite *)compositeSortingAnimation;

#pragma mark - helper methods
-(CGRect)rectForCardItem:(RGCardItem *)item;

@end
