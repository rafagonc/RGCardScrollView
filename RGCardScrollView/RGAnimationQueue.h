//
//  RGAnimationQueue.h
//  RGCardScrollView
//
//  Created by Rafael Gonzalves on 8/14/15.
//  Copyright (c) 2015 Rafael Gonçalves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RGAnimationQueueOperationProtocol.h"

@interface RGAnimationQueue : NSObject

#pragma mark - constructor
-(instancetype)init;

#pragma mark - properties
@property (nonatomic,readonly) NSArray *queue;

#pragma mark - adding and removing
-(void)addOperation:(id<RGAnimationQueueOperationProtocol>)operation;
-(void)removeOperation:(id<RGAnimationQueueOperationProtocol>)operation;
-(void)removeAllOperationsForKey:(NSString *)key;

#pragma mark - running
-(void)run:(void(^)())finishCallback;


@end
