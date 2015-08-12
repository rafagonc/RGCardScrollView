//
//  RGCardAnimation.h
//  Components
//
//  Created by Rafael Gonzalves on 8/7/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

@import UIKit;
@class RGCardItem;
@class RGCardItemSorter;

typedef enum : NSInteger {
    
    RGCardAnimationTypeSwap = 0,
    RGCardAnimationTypeShift = 1
    
} RGCardAnimationType;

@interface RGCardSwapAnimation : NSObject

#pragma mark - constructor
-(instancetype)initFromItem:(RGCardItem *)fromItem toItem:(RGCardItem *)toItem andSorter:(RGCardItemSorter *)sorter andAnimationType:(RGCardAnimationType)type andItems:(NSMutableArray *)items;

@property (nonatomic,strong) RGCardItem *fromItem;
@property (nonatomic,strong) RGCardItem *toItem;
@property (nonatomic,assign) RGCardAnimationType type;

#pragma mark - run
-(void)runWithCompletion:(void(^)(void))completion;

@end
