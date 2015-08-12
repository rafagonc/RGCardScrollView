//
//  RGDraggrableView.h
//  Components
//
//  Created by Rafael Gonzalves on 8/7/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    RGDraggrableViewDirectionVertical = 0,
    RGDraggrableViewDirectionHorizontal = 1,
    RGDraggrableViewDirectionUndecided = 2,
}RGDraggrableViewDirection;

typedef struct {
    RGDraggrableViewDirection direction;
    CGPoint firstTouchLocation;
    CGPoint movementTouchLocation;
    CGFloat speed;
    CGPoint viewPosition;
}RGDraggrableViewCallbackStructure;

typedef void(^RGDraggrableViewStartCallback)(RGDraggrableViewCallbackStructure);

@interface RGDraggrableView : UIView

@property (nonatomic,assign) BOOL draggable;
@property (nonatomic,assign) BOOL dragging;
@property (nonatomic,copy) RGDraggrableViewStartCallback startDraggingCallback;
@property (nonatomic,copy) RGDraggrableViewStartCallback draggingCallback;
@property (nonatomic,copy) RGDraggrableViewStartCallback endDraggingCallback;


@end
