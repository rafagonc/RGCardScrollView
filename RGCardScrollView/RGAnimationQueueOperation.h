//
//  RGAnimationQueueOperation.h
//  RGCardScrollView
//
//  Created by Rafael Gonzalves on 8/14/15.
//  Copyright (c) 2015 Rafael Gonçalves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RGAnimationQueueOperationProtocol.h"

@interface RGAnimationQueueOperation : NSObject <RGAnimationQueueOperationProtocol>

#pragma mark - constructor
-(instancetype)initWithAnimation:(CAAnimation *)animation onView:(UIView *)view forKey:(NSString *)key;

#pragma mark - properties
@property (nonatomic,strong,readonly) NSString     * key;
@property (nonatomic,strong,readonly) CAAnimation  * animation;
@property (nonatomic,strong,readonly) UIView       * view;
@property (nonatomic,copy) void(^modalLayerChangingCallback)();
@property (nonatomic,copy) void(^animationDidStopCallback)();

@end
