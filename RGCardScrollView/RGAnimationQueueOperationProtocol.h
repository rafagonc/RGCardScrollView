//
//  RGAnimationQueueOperationItem.h
//  RGCardScrollView
//
//  Created by Rafael Gonzalves on 8/14/15.
//  Copyright (c) 2015 Rafael Gonçalves. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RGAnimationQueueOperationProtocol <NSObject>

-(void)runWithCompletion:(void(^)())completion;
-(NSString *)key;

@end
