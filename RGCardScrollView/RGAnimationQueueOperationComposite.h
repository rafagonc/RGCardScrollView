//
//  RGAnimationQueueOperationComposite.h
//  RGCardScrollView
//
//  Created by Rafael Gonzalves on 8/14/15.
//  Copyright (c) 2015 Rafael Gonçalves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGAnimationQueueOperationProtocol.h"

@interface RGAnimationQueueOperationComposite : NSObject <RGAnimationQueueOperationProtocol>

#pragma mark - constructor
-(instancetype)initWithKey:(NSString *)key;

#pragma mark - adding
-(void)addAnimation:(CAAnimation *)animation onView:(UIView *)view andModalLayerChanges:(void(^)())modalLayerCallback;

#pragma mark - properties
@property (nonatomic,       readonly) NSArray *operations;
@property (nonatomic,strong,readonly) NSString *key;

@end
