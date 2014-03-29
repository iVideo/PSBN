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
#import "PSBNScores.h"
#import "PSBNScoreCenter.h"

@implementation PSBNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    devMode = YES;
    // Override point for customization after application launch.
    
    // Parse stuff
    [Parse setApplicationId:@"CbGaoZLs7udS8ZKr9Tbl3AdqHbah90shGjBSomyx" clientKey:@"KvO9K9dqfC876Im9Rkzo9yUmHDfkNrhD9rbteIXy"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    UIViewController *theaterListController, *radioController, *scoresController, *scoreCenterController;
    UINavigationController *theaterListNavController, *radioNavController, *scoresNavController, *scoreCenterNavController;
    
    radioController = [[PSBNRadio alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    radioNavController = [[UINavigationController alloc] initWithRootViewController:radioController];
    
    theaterListController = [[PSBNTheaterList alloc] init];
    theaterListNavController = [[UINavigationController alloc] initWithRootViewController:theaterListController];
    
    // cameraController = [[PSBNCamera alloc] init];
    
    scoresController = [[PSBNScores alloc] init];
    scoresNavController = [[UINavigationController alloc] initWithRootViewController:scoresController];
    
    scoreCenterController = [[PSBNScoreCenter alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    scoreCenterNavController = [[UINavigationController alloc] initWithRootViewController:scoreCenterController];
    
    // Theme-ing
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    theaterListNavController.navigationBar.barStyle = UIBarStyleBlack;
    scoresNavController.navigationBar.barStyle = UIBarStyleBlack;
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        
        [self.window setTintColor:[UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f]];
        
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS7"] forBarMetrics:UIBarMetricsDefault];
        [radioNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS7"] forBarMetrics:UIBarMetricsDefault];
        [theaterListNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS7"] forBarMetrics:UIBarMetricsDefault];
        [scoresNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS7"] forBarMetrics:UIBarMetricsDefault];
    } else {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS6"] forBarMetrics:UIBarMetricsDefault];
        [radioNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS6"] forBarMetrics:UIBarMetricsDefault];
        [theaterListNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS6"] forBarMetrics:UIBarMetricsDefault];
        [scoresNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBarTile_iOS6"] forBarMetrics:UIBarMetricsDefault];
    }
    
    scoresNavController.navigationBar.shadowImage = [UIImage imageNamed:@"navBarShadow_iPhone"];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    // Reset app icon badge
    if (application.applicationIconBadgeNumber > 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = self;
        if (devMode) {
            self.splitViewController.viewControllers = @[scoreCenterNavController, theaterListNavController];
        } else {
            self.splitViewController.viewControllers = @[scoresNavController, theaterListNavController];
        }
        
        theaterListNavController.navigationBar.shadowImage = [UIImage imageNamed:@"navBarShadow_iPad"];
        
        // [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraIcon_iPad"] highlightImage:nil];
        
        self.window.rootViewController = self.splitViewController;
    } else {
        self.tabBarController = [[UITabBarController alloc] init];
        self.tabBarController.delegate = self;
        if (devMode) {
            self.tabBarController.viewControllers = @[theaterListNavController, radioNavController, scoresNavController, scoreCenterNavController];
        } else {
            self.tabBarController.viewControllers = @[theaterListNavController, scoresNavController];
        }
        
        self.tabBarController.tabBar.selectedImageTintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.backgroundImage = [UIImage imageNamed:@"black"];
        
        theaterListNavController.navigationBar.shadowImage = [UIImage imageNamed:@"navBarShadow_iPhone"];
        radioNavController.navigationBar.shadowImage = [UIImage imageNamed:@"navBarShadow_iPhone"];
        
        self.tabBarController.tabBar.shadowImage = [UIImage imageNamed:@"navBarShadow_iPhone"];
        
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        }
        
        // [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraIcon_iPhone"] highlightImage:nil];
        
        self.window.rootViewController = self.tabBarController;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end