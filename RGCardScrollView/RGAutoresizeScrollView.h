//
//  RGAutoresizeScrollView.h
//  Components
//
//  Created by Rafael Gonzalves on 8/5/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : int {
    RGAutoresizeScrollViewDirectionLockHorizontal = 1,
    RGAutoresizeScrollViewDirectionLockVertical = 2,
    RGAutoresizeScrollViewDirectionLockNone = 0
}RGAutoresizeScrollViewDirectionLock;

@interface RGAutoresizeScrollView : UIScrollView

#pragma mark - properties
@property (nonatomic,strong) NSHashTable *addedSubviews; //Cant have scrollers and part of the subviews, this is the problem with self.subviews
@property (nonatomic,assign) RGAutoresizeScrollViewDirectionLock lock;

#pragma mark - protected (virtual)
-(void)commonInit;
-(bool)isProbablyAScrollBar:(UIView*)view;
-(CGSize)calculateContentSize;

@end
