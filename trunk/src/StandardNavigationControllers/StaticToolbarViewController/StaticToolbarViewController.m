//
//  Copyright 2009 Zerously.
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  

#import "StaticToolbarViewController.h"
#define kPushedToolbarTag 4000
#define kPulledToolbarTag 4001
#define kMockToolbarFrame CGRectMake(0, 436, 320, 44)
#define kRealToolbarFrame CGRectMake(0, 372, 320, 44)

@interface StaticToolbarViewController (Private_API)
- (UIWindow *)keyWindow;
- (UIViewController *)previousViewController;
@end

@implementation StaticToolbarViewController

@synthesize toolbar;

BOOL isNextViewControllerSameClass = YES;

#pragma mark UIViewController
- (void)viewDidAppear:(BOOL)animated {

    UIView *staticToolbar =
    [self.keyWindow viewWithTag:kPushedToolbarTag];
    
    if(staticToolbar != nil) { //We are going down on the navController hierarchy.

        UIViewController *previousViewController =
        [self previousViewController];

        [previousViewController.view addSubview:staticToolbar];

        //The toolbar is no longer pulled or pushed.
        staticToolbar.frame = kRealToolbarFrame;
        staticToolbar.tag = 0;

        return;
    }

    staticToolbar = 
    [self.keyWindow viewWithTag:kPulledToolbarTag];

    if(staticToolbar != nil) { //We are going up on the navController hierarchy.

        [staticToolbar removeFromSuperview];
    }
}

- (void)viewWillDisappear:(BOOL)animated {

    UIView *staticToolbar =
    [self.keyWindow viewWithTag:kPushedToolbarTag];

    if(staticToolbar == nil && isNextViewControllerSameClass) { //We are going up on the navController hierarchy.
        UIViewController *previousViewController = [self previousViewController];

        if([previousViewController isKindOfClass:[self class]]) {
            //It's the same kind of view controller.
            self.toolbar.frame = kMockToolbarFrame;
            self.toolbar.tag = kPulledToolbarTag;
            [self.keyWindow addSubview:self.toolbar];
        }
    }
}

- (void)dealloc {
    [toolbar release];
    [super dealloc];
}

#pragma mark -
#pragma mark StaticToolbarViewController
- (UIWindow *)keyWindow {
    return [UIApplication sharedApplication].keyWindow;
}

- (UIViewController *)previousViewController {
    //NOTE: When called from viewWillAppear:(BOOL)animated the previous ViewController
    //is 1 levels up the NavigationController hierarchy, when called from the
    //viewWillDisappear:(BOOL)animated the previous ViewController is on top of the
    //NavigationController hierarchy.

    NSInteger navigationStackCount =
    self.navigationController.viewControllers.count;

    UIViewController *previousViewController =
    [self.navigationController.viewControllers objectAtIndex:navigationStackCount - 1];

    if(previousViewController == self) {
        previousViewController =
        [self.navigationController.viewControllers objectAtIndex:navigationStackCount - 2];
    }

	return previousViewController;
}

- (void)pushViewController:(UIViewController *)viewController {

    isNextViewControllerSameClass = 
    [viewController isKindOfClass:[self class]];

    if(isNextViewControllerSameClass) {
        self.toolbar.frame = kMockToolbarFrame;
        self.toolbar.tag = kPushedToolbarTag;
        [self.keyWindow addSubview:self.toolbar];
    }
}

@end
