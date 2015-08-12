//
//  RGDraggrableView.m
//  Components
//
//  Created by Rafael Gonzalves on 8/7/15.
//  Copyright (c) 2015 Rafael Gonzalves. All rights reserved.
//

#import "RGDraggrableView.h"

@interface RGDraggrableView ()

<UIGestureRecognizerDelegate>

{
    CGPoint initialPointOnView, firstTouch;
    CGFloat oldSpeed;
}

@property (nonatomic,assign) NSTimeInterval previousTimestamp;
@property (nonatomic,assign) RGDraggrableViewDirection direction;

@end

@implementation RGDraggrableView

#pragma mark - constructor
-(instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    } return self;
}
-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    } return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    } return self;
}
-(void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}
-(void)commonInit {
    self.draggable = YES;
    self.direction = RGDraggrableViewDirectionUndecided;
}

#pragma mark - touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    firstTouch = [self locationForTouches:touches];
    RGDraggrableViewCallbackStructure callbackStructure;
    callbackStructure.speed = 0.0f;;
    callbackStructure.firstTouchLocation = firstTouch;
    callbackStructure.direction = self.direction;
    callbackStructure.viewPosition = self.frame.origin;
    if (self.startDraggingCallback) self.startDraggingCallback(callbackStructure);
    initialPointOnView = [self convertPoint:firstTouch fromView:self.superview];
    self.dragging = YES;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isnan(oldSpeed)) oldSpeed = 1;
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.superview];
    CGPoint prevLocation = [touch previousLocationInView:self.superview];
    CGFloat distanceFromPrevious = [self distanceBetweenPoint:prevLocation toPoint:location];
    NSTimeInterval timeSincePrevious = event.timestamp - self.previousTimestamp;
    const float lambda = (timeSincePrevious>0.2? 1: timeSincePrevious/0.2);
    CGFloat newSpeed = (1.0 - lambda) * oldSpeed + lambda * (distanceFromPrevious/timeSincePrevious);
    oldSpeed = newSpeed;
    self.previousTimestamp = event.timestamp;
    
    if (self.direction == RGDraggrableViewDirectionUndecided) { //first movimentation
        self.direction = [self findDirectionOnFirstMovementLocation:location andFirstTouchLocation:firstTouch];
    }
    RGDraggrableViewCallbackStructure callbackStructure;
    callbackStructure.firstTouchLocation = firstTouch;
    callbackStructure.movementTouchLocation = location;
    callbackStructure.direction = self.direction;
    callbackStructure.speed = newSpeed;
    callbackStructure.viewPosition = self.frame.origin;
    if (self.draggable) {
        self.frame = [self rectForDraggingView:self andTouchLocation:location];
        if (self.draggingCallback) self.draggingCallback(callbackStructure);
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.superview];
    
    self.dragging = NO;
    RGDraggrableViewCallbackStructure callbackStructure;
    callbackStructure.firstTouchLocation = firstTouch;
    callbackStructure.movementTouchLocation = location;
    callbackStructure.direction = self.direction;
    callbackStructure.viewPosition = self.frame.origin;
    if (self.endDraggingCallback) self.endDraggingCallback(callbackStructure);
    [self reinitVariables];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.superview];
    
    self.dragging = NO;
    RGDraggrableViewCallbackStructure callbackStructure;
    callbackStructure.firstTouchLocation = firstTouch;
    callbackStructure.movementTouchLocation = location;
    callbackStructure.viewPosition = self.frame.origin;
    callbackStructure.direction = self.direction;
    if (self.endDraggingCallback) self.endDraggingCallback(callbackStructure);
    [self reinitVariables];
}

#pragma mark - helper methods
-(RGDraggrableViewDirection)findDirectionOnFirstMovementLocation:(CGPoint)firstMovement andFirstTouchLocation:(CGPoint)primalTouch {
    CGPoint diff = CGPointMake(primalTouch.x - firstMovement.x, primalTouch.y - firstMovement.y);
    CGFloat x = fabs(diff.x);
    CGFloat y = fabs(diff.y);
    if (x > y) {
        return RGDraggrableViewDirectionHorizontal;
    } else if (x < y) {
        return RGDraggrableViewDirectionVertical;
    } else {
        return RGDraggrableViewDirectionUndecided;
    }

}
-(CGPoint)locationForTouches:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[self superview]];
    return location;
}
-(CGRect)rectForDraggingView:(UIView *)view andTouchLocation:(CGPoint)touchLocation {
    CGRect rect;
    rect.origin.x = (self.direction == RGDraggrableViewDirectionHorizontal) ? touchLocation.x - initialPointOnView.x : view.frame.origin.x;
    rect.origin.y = (self.direction == RGDraggrableViewDirectionVertical) ? touchLocation.y - initialPointOnView.y : view.frame.origin.y;
    rect.size.width = view.frame.size.width;
    rect.size.height = view.frame.size.height;
    return rect;
}
-(CGFloat)distanceBetweenPoint:(CGPoint)p1 toPoint:(CGPoint)p2 {
    return fabs(sqrt(pow(p2.x - p1.x, 2) - pow(p2.y - p1.y, 2)));
}

-(void)reinitVariables {
    firstTouch = CGPointZero;
    self.direction =  RGDraggrableViewDirectionUndecided;
}

#pragma mark - overrides
-(void)willRemoveSubview:(UIView *)subview {
    [self removeFromSuperview];
}

#pragma mark - dealloc
-(void)dealloc {
    
}

@end
