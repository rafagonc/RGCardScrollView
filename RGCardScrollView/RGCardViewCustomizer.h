//
//  RGCardViewCustomizer.h
//  Components
//
//  Created by Rafael Gonzalves on 8/11/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

@import UIKit;

@interface RGCardViewCustomizer : NSObject

#pragma mark - constructor
-(instancetype)initWithView:(UIView *)view;

#pragma mark - customize
-(void)customize;

#pragma mark - factory method
+(void)customizeView:(UIView *)view;

@end
