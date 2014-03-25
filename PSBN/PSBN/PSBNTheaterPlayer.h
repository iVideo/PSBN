//
//  PSBNTheaterPlayer.h
//  PSBN
//
//  Created by Victor Ilisei on 12/17/13.
//  Copyright (c) 2013 Tech Genius. All rights reserved.
//

#import "PSBNMoviePlayerController.h"

@interface PSBNTheaterPlayer : UIViewController {
    NSString *objectID;
    
    int playerHeight;
    float viewPadding;
    
    NSURL *customPlayerURL;
    NSURL *fallbackPlayerURL;
    
    UIActivityIndicatorView *loadingWheel;
    
    PSBNMoviePlayerController *customPlayer;
    UIWebView *fallbackPlayer;
    
    UIImageView *poster;
    UIImageView *posterMask;
    UILabel *eventName;
    UILabel *eventDate;
}

- (void)readyToPlay:(NSNotification *)notification;
- (void)fallbackWithNotification:(NSNotification *)notification;

@end