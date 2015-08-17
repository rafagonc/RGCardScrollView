//
//  RGAnimationQueueOperationComposite.m
//  RGCardScrollView
//
//  Created by Rafael Gonzalves on 8/14/15.
//  Copyright (c) 2015 Rafael Gonçalves. All rights reserved.
//

#import "RGAnimationQueueOperationComposite.h"
#import "RGAnimationQueueOperationProtocol.h"
#import "RGAnimationQueueOperation.h"

@interface RGAnimationQueueOperationComposite ()

@property (nonatomic,strong) NSMutableArray *mOperations;
@property (nonatomic,copy) void(^runOnCompletion)();

@end

@implementation RGAnimationQueueOperationComposite

#pragma mark - constructor
-(instancetype)initWithKey:(NSString *)key {
    if (self = [super init]) {
        _key = key;
        _mOperations = [[NSMutableArray alloc] init];
    } return self;
}

#pragma mark - adding
-(void)addAnimation:(CAAnimation *)animation onView:(UIView *)view andModalLayerChanges:(void(^)())modalLayerCallback {
    RGAnimationQueueOperation *operation = [[RGAnimationQueueOperation alloc] initWithAnimation:animation onView:view forKey:self.key];
    operation.modalLayerChangingCallback = modalLayerCallback;
    [self.mOperations addObject:operation];
}

#pragma mark - running
-(void)runWithCompletion:(void (^)())completion {
    __weak typeof(self) welf = self;
    __block void(^blockCompletion)() = completion;
    __block NSUInteger operationsCount = self.mOperations.count - 1;
    __block NSUInteger countOperationsFinished = 0;
    for (RGAnimationQueueOperation *op in self.mOperations) {
        [op runWithCompletion:^{
            countOperationsFinished++;
            if (countOperationsFinished == operationsCount) {
                if (welf.runOnCompletion) welf.runOnCompletion();
                welf.runOnCompletion = nil;
                if (blockCompletion) blockCompletion();
                blockCompletion = nil;
            }
        }];
    }
}

#pragma mark - getters and setters
-(NSArray *)operations {
    return [self.mOperations copy];
}

#pragma mark - dealloc
-(void)dealloc {
    NSLog(@"%@ - DEALLOC", NSStringFromClass(self.class));
}

@end
