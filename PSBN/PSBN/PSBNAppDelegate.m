//
//  PSBNAppDelegate.m
//  PSBN
//
//  Created by Victor Ilisei on 2/26/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNAppDelegate.h"

#import "PSBNTheaterList.h"
#import "PSBNRadio.h"
#import "PSBNCamera.h"
#import "PSBNScoreCenter.h"

@implementation PSBNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.devMode = YES;
    // Override point for customization after application launch.
    
    // Parse stuff
    [Parse setApplicationId:@"CbGaoZLs7udS8ZKr9Tbl3AdqHbah90shGjBSomyx" clientKey:@"KvO9K9dqfC876Im9Rkzo9yUmHDfkNrhD9rbteIXy"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    UIViewController *theaterListController, *radioController, *scoreCenterController;
    UINavigationController *theaterListNavController, *radioNavController;
    
    radioController = [[PSBNRadio alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    radioNavController = [[UINavigationController alloc] initWithRootViewController:radioController];
    
    theaterListController = [[PSBNTheaterList alloc] init];
    theaterListNavController = [[UINavigationController alloc] initWithRootViewController:theaterListController];
    
    // cameraController = [[PSBNCamera alloc] init];
    
    scoreCenterController = [[PSBNScoreCenter alloc] init];
    scoreCenterController.title = @"Score Center";
    scoreCenterController.tabBarItem.image = [UIImage imageNamed:@"scores"];
    
    // Theme-ing
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    theaterListNavController.navigationBar.barStyle = UIBarStyleBlack;
    radioNavController.navigationBar.barStyle = UIBarStyleBlack;
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        
        [self.window setTintColor:[UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f]];
        
        // [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS7"] forBarMetrics:UIBarMetricsDefault];
        // [radioNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS7"] forBarMetrics:UIBarMetricsDefault];
        [theaterListNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS7"] forBarMetrics:UIBarMetricsDefault];
    } else {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS6"] forBarMetrics:UIBarMetricsDefault];
        [radioNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS6"] forBarMetrics:UIBarMetricsDefault];
        [theaterListNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS6"] forBarMetrics:UIBarMetricsDefault];
    }
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    // Reset app icon badge
    if (application.applicationIconBadgeNumber > 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = self;
        if (self.devMode) {
            self.splitViewController.viewControllers = @[scoreCenterController, theaterListNavController];
        } else {
            self.splitViewController.viewControllers = @[scoreCenterController, theaterListNavController];
        }
        
        theaterListNavController.navigationBar.shadowImage = [UIImage imageNamed:@"navBarShadow_iPad"];
        
        // [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraIcon_iPad"] highlightImage:nil];
        
        self.window.rootViewController = self.splitViewController;
    } else {
        self.tabBarController = [[UITabBarController alloc] init];
        self.tabBarController.delegate = self;
        if (self.devMode) {
            self.tabBarController.viewControllers = @[theaterListNavController, radioNavController, scoreCenterController];
        } else {
            self.tabBarController.viewControllers = @[theaterListNavController, scoreCenterController];
        }
        
        self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
        if ([[[UIDevice currentDevice] systemVersion] intValue] < 7) {
            self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"black"];
        } else {
            self.tabBarController.tabBar.barStyle = UIBarStyleBlack;
            self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        }
        
        theaterListNavController.navigationBar.shadowImage = [UIImage imageNamed:@"navBarShadow_iPhone"];
        radioNavController.navigationBar.shadowImage = [UIImage imageNamed:@"navBarShadow_iPhone"];
        
        self.tabBarController.tabBar.shadowImage = [UIImage imageNamed:@"navBarShadow_iPhone"];
        
        // [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraIcon_iPhone"] highlightImage:nil];
        
        self.window.rootViewController = self.tabBarController;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    @autoreleasepool {
        NSUInteger orientations = UIInterfaceOrientationMaskAllButUpsideDown;
        
        if (self.window.rootViewController) {
            @autoreleasepool {
                UIViewController *presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
                orientations = [presentedViewController supportedInterfaceOrientations];
            }
        }
        
        return orientations;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}

- (void)addCenterButtonWithImage:(UIImage *)buttonImage highlightImage:(UIImage *)highlightImage {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBarController.tabBar.frame.size.height;
    if (heightDifference < 0) {
        button.center = self.tabBarController.tabBar.center;
    } else {
        CGPoint center = self.tabBarController.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [button addTarget:self action:@selector(showCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:button];
}

- (void)showCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.tabBarController setSelectedIndex:1];
    } else {
        UIAlertView *cameraError = [[UIAlertView alloc] initWithTitle:@"Camera Error" message:@"No camera is found on your device" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [cameraError show];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [currentInstallation saveEventually];
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    UIAlertView *pushAlert = [[UIAlertView alloc] initWithTitle:@"Push Notification Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [pushAlert show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

@end