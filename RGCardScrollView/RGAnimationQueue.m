//
//  RGAnimationQueue.m
//  RGCardScrollView
//
//  Created by Rafael Gonzalves on 8/14/15.
//  Copyright (c) 2015 Rafael Gonçalves. All rights reserved.
//

#import "RGAnimationQueue.h"

@interface RGAnimationQueue ()

@property (nonatomic,strong) NSMutableArray *mQueue;

#pragma mark - state
@property (nonatomic,assign, getter=isRunningAnimationNow) BOOL running;
@property (nonatomic,copy  ) void(^finishAnimationsCallback)();

@end

@implementation RGAnimationQueue

#pragma mark - constructor
-(instancetype)init {
    if (self = [super init]) {
        self.mQueue = [[NSMutableArray alloc] init];
    } return self;
}

#pragma mark - adding and removing
-(void)addOperation:(id<RGAnimationQueueOperationProtocol>)operation {
    if ([self hasAnimationWithSameKey:[operation key]] == NO) [self.mQueue addObject:operation];
}
-(void)removeOperation:(id<RGAnimationQueueOperationProtocol>)operation {
    [self.mQueue removeObject:operation];
}
-(void)removeAllOperationsForKey:(NSString *)key {
    NSMutableArray *toDelete = [@[] mutableCopy];
    for (id<RGAnimationQueueOperationProtocol> opToCheckKey in self.mQueue) {
        if ([[opToCheckKey key] isEqualToString:key]) [toDelete addObject:opToCheckKey];
    }
    [self.mQueue removeObjectsInArray:toDelete];
}

#pragma mark - running
-(void)run:(void(^)())finishCallback {
    self.finishAnimationsCallback = finishCallback;
    id<RGAnimationQueueOperationProtocol> next = (id<RGAnimationQueueOperationProtocol>)self.mQueue.firstObject;
    if ([self isNotRunningAnimationOrQueueIsEmpty]) {
        self.running = YES;
        [next runWithCompletion:^{
            [self.mQueue removeObject:self.mQueue.firstObject];
            self.running = NO;
            [self run:finishCallback];
        }];
    } else {
        if (self.finishAnimationsCallback) self.finishAnimationsCallback();
    }
}

#pragma mark - helper metods
-(BOOL)hasAnimationWithSameKey:(NSString *)key {
    for (id<RGAnimationQueueOperationProtocol> a in self.mQueue) {
        if ([[a key] isEqualToString:key]) return YES;
    }
    return NO;
}

#pragma mark - getters and setters
-(NSArray *)queue {
    return [self.mQueue copy];
}
-(BOOL)isNotRunningAnimationOrQueueIsEmpty {
    return self.isRunningAnimationNow == NO && self.mQueue.count > 0;
}

#pragma mark - dealloc
-(void)dealloc {
    NSLog(@"%@ - DEALLOC", NSStringFromClass(self.class));
}

@end
