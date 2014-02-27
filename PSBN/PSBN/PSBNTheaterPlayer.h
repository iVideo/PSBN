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
    BOOL validCustomPlayerURL;
    double customPlayerReloadInterval;
    
    NSURL *customPlayerURL;
    NSURL *fallbackPlayerURL;
    
    PSBNMoviePlayerController *customPlayer;
    UIWebView *fallbackPlayer;
    
    UIImageView *poster;
    UIImageView *posterMask;
    UILabel *eventName;
    UILabel *eventDate;
}

@end