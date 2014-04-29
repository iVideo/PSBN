//
//  PSBNMoviePlayerController.m
//  PSBN
//
//  Created by Victor Ilisei on 1/25/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNMoviePlayerController.h"

@implementation PSBNMoviePlayerController

/*
- (id)initWithContentURL:(NSURL *)url {
    self = [super initWithContentURL:url];
    if (self) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)willRotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            [self setFullscreen:YES animated:NO];
        } else {
            [self setFullscreen:NO animated:NO];
            [self.view setFrame:CGRectMake(0, 0, 320, 180)];
        }
    }
}
 */

@end