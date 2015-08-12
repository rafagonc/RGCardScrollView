//
//  RGCardItem.h
//  Components
//
//  Created by Rafael Gonzalves on 8/6/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

@import UIKit;

#pragma mark - blokcs
typedef void(^RGCardItemTapped)(NSUInteger order, UIView *view);

@interface RGCardItem : NSObject

#pragma mark - properties
@property (nonatomic,strong) UIView          * view;
@property (nonatomic,  copy) RGCardItemTapped  tapped;
@property (nonatomic,assign) BOOL              opened;

#pragma mark - constructor
-(instancetype)initWithView:(UIView *)view andOrder:(NSUInteger)order;

@end
