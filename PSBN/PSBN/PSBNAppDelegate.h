//
//  PSBNAppDelegate.h
//  PSBN
//
//  Created by Victor Ilisei on 2/26/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSBNAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

- (void)addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;
- (void)showCamera;

@end