//
//  GTProjectViewCtrl.m
//  Zeta
//
//  Created by GOOT on 16/3/23.
//  Copyright © 2016年 GOOT. All rights reserved.
//

#import "GTProjectViewCtrl.h"

@interface GTProjectViewCtrl ()
{
    GTProjectLeftViewCtrl  *_left;
    GTProjectRightViewCtrl *_right;
    UIViewController *_currentViewController;
    
    UIView *_bigView;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation GTProjectViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];

    _bigView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, screenW, screenH - 45)];
    [self.view addSubview:_bigView];
    
     _left = [[GTProjectLeftViewCtrl alloc] init];
    [_left.view  setFrame:_bigView.bounds];
    [self addChildViewController:_left];
    
     _right = [[GTProjectRightViewCtrl alloc] init];
    [_right.view setFrame:_bigView.bounds];
    [self addChildViewController:_right];
    
    _currentViewController = _left;
    [_bigView addSubview:_left.view];
}

- (void)segmentAction:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    
    if (_currentViewController == _left  & index == 0) {return;}
    if (_currentViewController == _right & index == 1) {return;}
    
    UIViewController *oldViewController = _currentViewController;
    
    NSTimeInterval duration = 0.3;
    UIViewAnimationOptions option = UIViewAnimationOptionTransitionNone;
    
    switch (index) {
        case 0:
        {
            [self transitionFromViewController:_currentViewController toViewController:_left duration:duration options:option animations:^{
                
            } completion:^(BOOL finished) {
                if (finished) {
                    _currentViewController = _left;
                } else {
                    _currentViewController = oldViewController;
                }
            }];

        }
            break;
        case 1:
        {
            [self transitionFromViewController:_currentViewController toViewController:_right duration:duration options:option animations:^{
                
            } completion:^(BOOL finished) {
                if (finished) {
                    _currentViewController = _right;
                } else {
                    _currentViewController = oldViewController;
                }
            }];

        }
            break;
            
        default:
            break;
    }
    
}

@end
