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
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]];
        
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        lp.minimumPressDuration = 1.5;
        [view addGestureRecognizer:lp];

    } return self;
}

#pragma mark - getters and setters
-(void)tapped:(UITapGestureRecognizer *)tapGesture {
    if (self.tapped) self.tapped(self.view);
}
-(void)longPressed:(UILongPressGestureRecognizer *)longPress {
    if (self.longPressed && longPress.state == UIGestureRecognizerStateBegan) self.longPressed(self.view);
}

#pragma mark  - getters and setters
-(void)setOpened:(BOOL)opened {
    _opened = opened;
}

@end
