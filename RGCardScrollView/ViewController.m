//
//  ViewController.m
//  RGCardScrollView
//
//  Created by Rafael Gonzalves on 8/12/15.
//  Copyright (c) 2015 Rafael Gonçalves. All rights reserved.
//

#import "ViewController.h"
#import "RGCardScrollView.h"

@interface ViewController ()

@end

@interface ViewController () <RGCardScrollViewDelegate,RGCardScrollViewDatasource>

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    RGCardScrollView *card = [[RGCardScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.bounds.size.height)];
    card.closedPadding = 100;
    card.editing = YES;
    card.cardDatasource = self;
    card.cardDelegate = self;
    [self.view addSubview:card];
    
    [self performSelector:@selector(remove:) withObject:card afterDelay:3];
    
}
-(void)remove:(RGCardScrollView *)view {
    [view deleteSubviewAtOrder:2 animated:YES];
}

#pragma mark - card data source
-(NSInteger)numberOfCardsOnCardScrollView:(RGCardScrollView *)cardScrollView {
    return 10;
}
-(UIView *)cardScrollView:(RGCardScrollView *)cardScrollView viewForIndex:(NSInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    [view setBackgroundColor:[UIColor colorWithRed:(arc4random() % 255/255.0) green:(arc4random() % 255/255.0) blue:(arc4random() % 255/255.0) alpha:1]];
    return view;
}
-(BOOL)cardScrollView:(RGCardScrollView *)cardScrollView canDeleteViewAtIndex:(NSInteger)index {
    return YES;
}
-(void)cardScrollView:(RGCardScrollView *)cardScrollView didSelectViewAtIndex:(NSInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    [view setBackgroundColor:[UIColor colorWithRed:(arc4random() % 255/255.0) green:(arc4random() % 255/255.0) blue:(arc4random() % 255/255.0) alpha:1]];
    [cardScrollView insertSubview:view atOrder:index + 1 animated:YES];
    
}
-(void)cardScrollView:(RGCardScrollView *)cardScrollView didLongPressViewAtIndex:(NSInteger)index {
    [cardScrollView deleteSubviewAtOrder:index animated:YES];

}


@end
