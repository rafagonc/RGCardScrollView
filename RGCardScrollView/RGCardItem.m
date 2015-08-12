//
//  RGCardItem.m
//  Components
//
//  Created by Rafael Gonzalves on 8/6/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import "RGCardItem.h"

@implementation RGCardItem

#pragma mark - constructor
-(instancetype)initWithView:(UIView *)view andOrder:(NSUInteger)order {
    if (self = [super init]) {
        self.view = view;
        //self.order = order;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
    } return self;
}

#pragma mark - getters and setters
-(void)tapped:(UITapGestureRecognizer *)tapGesture {
    if (self.tapped) self.tapped(0, self.view);
}

#pragma mark  - getters and setters
-(void)setOpened:(BOOL)opened {
    _opened = opened;
}

@end
