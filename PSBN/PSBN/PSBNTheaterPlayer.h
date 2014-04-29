//
//  PSBNTheaterPlayer.h
//  PSBN
//
//  Created by Victor Ilisei on 12/17/13.
//  Copyright (c) 2013 Tech Genius. All rights reserved.
//

#import "PSBNMoviePlayerController.h"

@interface PSBNTheaterPlayer : UIViewController {
    int playerHeight;
    float viewPadding;
    
    UIActivityIndicatorView *loadingWheel;
    
    UILabel *upcomingDescription;
    NSTimer *refreshTimer;
    
    PSBNMoviePlayerController *customPlayer;
    
    UIImageView *poster;
    UIImageView *posterMask;
    UILabel *eventName;
    UILabel *eventDateLabel;
}

@property (nonatomic) long eventID;
@property (nonatomic, retain) NSDate *eventDate;

- (void)refresh;

- (void)readyToPlay:(NSNotification *)notification;
- (void)fallbackWithNotification:(NSNotification *)notification;

@end