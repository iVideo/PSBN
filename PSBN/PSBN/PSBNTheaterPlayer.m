//
//  PSBNTheaterPlayer.m
//  PSBN
//
//  Created by Victor Ilisei on 12/17/13.
//  Copyright (c) 2013 Tech Genius. All rights reserved.
//

#import "PSBNTheaterPlayer.h"

@interface PSBNTheaterPlayer ()

@end

@implementation PSBNTheaterPlayer

- (NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
    }
    // Set background color
	self.view.backgroundColor = [UIColor whiteColor];
    // Find player height
    if (self.navigationController.view.frame.size.width == 703) {
        playerHeight = 395;
    } else if (self.navigationController.view.frame.size.width == 447) {
        playerHeight = 251;
    } else if (self.navigationController.view.frame.size.width == 320) {
        playerHeight = 180;
    } else if (self.navigationController.view.frame.size.width == 480) {
        playerHeight = 270;
    } else if (self.navigationController.view.frame.size.width == 568) {
        playerHeight = 320;
    }
    // Set padding
    viewPadding = 10.0f;
    
    if ([self.eventDate timeIntervalSinceNow] > 0) {
        // Future Event
        @autoreleasepool {
            upcomingTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, playerHeight/2-21, self.navigationController.view.frame.size.width, 21)];
            upcomingTitle.textColor = [UIColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:1.0f];
            upcomingTitle.font = [UIFont boldSystemFontOfSize:18.0f];
            upcomingTitle.textAlignment = NSTextAlignmentCenter;
            upcomingTitle.text = @"Coming Soon";
            [self.view addSubview:upcomingTitle];
        }
        
        @autoreleasepool {
            upcomingDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, playerHeight/2, self.navigationController.view.frame.size.width, playerHeight/2)];
            upcomingDescription.textColor = [UIColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:1.0f];
            upcomingDescription.font = [UIFont systemFontOfSize:16.0f];
            upcomingDescription.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:upcomingDescription];
            [self updateLiveTimer];
        }
    } else {
        // Past Event
        customPlayer = [[PSBNMoviePlayerController alloc] init];
        [customPlayer.view setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
        customPlayer.view.backgroundColor = self.view.backgroundColor;
        customPlayer.controlStyle = MPMovieControlStyleEmbedded;
        
        loadingView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
        loadingViewContent = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
        loadingViewContent.contentMode = UIViewContentModeScaleAspectFill;
        loadingView.contentView = loadingViewContent;
    }
    
    poster = [[UIImageView alloc] initWithFrame:CGRectMake(viewPadding, playerHeight+viewPadding, 100, 150)];
    poster.backgroundColor = [UIColor whiteColor];
    poster.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    poster.contentMode = UIViewContentModeRedraw;
    
    posterMask = [[UIImageView alloc] initWithFrame:poster.frame];
    posterMask.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    posterMask.contentMode = UIViewContentModeRedraw;
    posterMask.image = [UIImage imageNamed:@"posterMask"];
    [self.view insertSubview:posterMask aboveSubview:poster];
    
    eventName = [[UILabel alloc] initWithFrame:CGRectMake(viewPadding+poster.frame.size.width+viewPadding, playerHeight+viewPadding, self.navigationController.view.frame.size.width-viewPadding-poster.frame.size.width-viewPadding - viewPadding, 63)];
    eventName.text = self.title;
    eventName.textAlignment = NSTextAlignmentCenter;
    eventName.numberOfLines = 3;
    [self.view addSubview:eventName];
    
    eventDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewPadding+poster.frame.size.width+viewPadding, playerHeight+viewPadding+eventName.frame.size.height+viewPadding, self.navigationController.view.frame.size.width-viewPadding-poster.frame.size.width-viewPadding-viewPadding, 21)];
    @autoreleasepool {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        eventDateLabel.text = [dateFormatter stringFromDate:self.eventDate];
    }
    eventDateLabel.textAlignment = NSTextAlignmentCenter;
    eventDateLabel.textColor = [UIColor colorWithRed:100/255.0f green:0.0f blue:0.0f alpha:1.0f];
    eventDateLabel.adjustsFontSizeToFitWidth = YES;
    eventDateLabel.adjustsLetterSpacingToFitWidth = YES;
    [self.view addSubview:eventDateLabel];
    
    [self refresh];
}

- (void)refresh {
    @autoreleasepool {
        NSString *eventAPIURL = [NSString stringWithFormat:@"https://api.new.livestream.com/accounts/5145446/events/%ld", self.eventID];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:eventAPIURL]];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *eventAPI, NSError *connectionError) {
            NSError *eventError;
            NSDictionary *eventContent = [NSJSONSerialization JSONObjectWithData:eventAPI options:kNilOptions error:&eventError];
            if (eventError) {
                @autoreleasepool {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:eventError.localizedFailureReason message:eventError.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    [errorAlert show];
                }
            } else {
                NSDictionary *stream_info = [eventContent objectForKey:@"stream_info"];
                NSDictionary *feed = [eventContent objectForKey:@"feed"];
                
                if ([stream_info isKindOfClass:[NSNull class]]) {
                    customPlayer.movieSourceType = MPMovieSourceTypeFile;
                    
                    NSArray *data = [feed objectForKey:@"data"];
                    NSDictionary *firstPost = [data firstObject];
                    NSDictionary *postData = [firstPost objectForKey:@"data"];
                    
                    NSString *secureHD = [postData objectForKey:@"secure_progressive_url_hd"];
                    NSString *normalHD = [postData objectForKey:@"progressive_url_hd"];
                    NSString *secureSD = [postData objectForKey:@"secure_progressive_url"];
                    NSString *normalSD = [postData objectForKey:@"progressive_url"];
                    
                    if (secureHD) {
                        [customPlayer setContentURL:[NSURL URLWithString:secureHD]];
                    } else if (normalHD) {
                        [customPlayer setContentURL:[NSURL URLWithString:normalHD]];
                    } else if (secureSD) {
                        [customPlayer setContentURL:[NSURL URLWithString:secureSD]];
                    } else if (normalSD) {
                        [customPlayer setContentURL:[NSURL URLWithString:normalSD]];
                    }
                } else {
                    customPlayer.movieSourceType = MPMovieSourceTypeStreaming;
                    
                    NSString *secureM3U8 = [stream_info objectForKey:@"secure_m3u8_url"];
                    NSString *normalM3U8 = [stream_info objectForKey:@"m3u8_url"];
                    
                    if (secureM3U8) {
                        [customPlayer setContentURL:[NSURL URLWithString:secureM3U8]];
                    } else if (normalM3U8) {
                        [customPlayer setContentURL:[NSURL URLWithString:normalM3U8]];
                    }
                }
                [customPlayer prepareToPlay];
                
                @autoreleasepool {
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[eventContent objectForKey:@"logo"] objectForKey:@"url"]]];
                    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                        if (!error) {
                            loadingViewContent.image = [[UIImage imageWithData:data] applyBlurWithRadius:10 tintColor:nil saturationDeltaFactor:1.8 maskImage:nil];
                            [self.view addSubview:loadingView];
                            loadingView.shimmering = YES;
                            
                            poster.image = [UIImage imageWithData:data];
                            [self.view insertSubview:poster belowSubview:posterMask];
                        }
                    }];
                }
            }
        }];
    }
}

- (void)updateLiveTimer {
    [refreshTimer invalidate];
    refreshTimer = nil;
    
    if ([self.eventDate timeIntervalSinceNow] > 0) {
        @autoreleasepool {
            NSTimeInterval secondsUntilEvent = floor([self.eventDate timeIntervalSinceNow]);
            
            NSTimeInterval days = floor(secondsUntilEvent / 86400);
            NSTimeInterval hours = floor((secondsUntilEvent - days*86400) / 3600);
            NSTimeInterval minutes = floor((secondsUntilEvent - days*86400 - hours*3600) / 60);
            NSTimeInterval seconds = floor(secondsUntilEvent - days*86400 - hours*3600 - minutes*60);
            
            upcomingDescription.text = [NSString stringWithFormat:@"%.fd %.fh %.fm %.fs", days, hours, minutes, seconds];
        }
        
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateLiveTimer) userInfo:nil repeats:NO];
    } else {
        // Remove upcoming labels
        [upcomingTitle removeFromSuperview];
        [upcomingDescription removeFromSuperview];
        
        // Past Event
        customPlayer = [[PSBNMoviePlayerController alloc] init];
        [customPlayer.view setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
        customPlayer.view.backgroundColor = self.view.backgroundColor;
        customPlayer.controlStyle = MPMovieControlStyleEmbedded;
        
        loadingView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
        loadingViewContent = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
        loadingViewContent.contentMode = UIViewContentModeScaleAspectFill;
        loadingView.contentView = loadingViewContent;
        
        [self refresh];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // Find player height
    if (self.navigationController.view.frame.size.width == 703) {
        playerHeight = 395;
    } else if (self.navigationController.view.frame.size.width == 447) {
        playerHeight = 251;
    } else if (self.navigationController.view.frame.size.width == 320) {
        playerHeight = 180;
    } else if (self.navigationController.view.frame.size.width == 480) {
        playerHeight = 270;
    } else if (self.navigationController.view.frame.size.width == 568) {
        playerHeight = 320;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readyToPlay:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fallbackWithNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    if (customPlayer != nil) {
        if (!customPlayer.fullscreen) {
            [customPlayer stop];
            customPlayer.initialPlaybackTime = -1;
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (customPlayer != nil) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
                [customPlayer setFullscreen:YES animated:YES];
            } else {
                [customPlayer setFullscreen:NO animated:YES];
            }
        }
    }
    
    // Find player height
    if (self.navigationController.view.frame.size.width == 703) {
        playerHeight = 395;
    } else if (self.navigationController.view.frame.size.width == 447) {
        playerHeight = 251;
    } else if (self.navigationController.view.frame.size.width == 320) {
        playerHeight = 180;
    } else if (self.navigationController.view.frame.size.width == 480) {
        playerHeight = 270;
    } else if (self.navigationController.view.frame.size.width == 568) {
        playerHeight = 320;
    }
    
    if (customPlayer != nil) {
        [customPlayer.view setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
    }
    
    [poster setFrame:CGRectMake(viewPadding, playerHeight+viewPadding, 100, 150)];
    
    [posterMask setFrame:poster.frame];
    
    [eventName setFrame:CGRectMake(viewPadding+poster.frame.size.width+viewPadding, viewPadding+playerHeight+viewPadding, self.navigationController.view.frame.size.width-viewPadding-poster.frame.size.width-viewPadding-viewPadding, 63)];
    
    [eventDateLabel setFrame:CGRectMake(poster.frame.size.width+viewPadding, playerHeight+viewPadding+eventName.frame.size.height+viewPadding, self.navigationController.view.frame.size.width-viewPadding-poster.frame.size.width-viewPadding-viewPadding, 21)];
}

- (void)readyToPlay:(NSNotification *)notification {
    if (customPlayer.loadState == MPMovieLoadStatePlayable) {
        loadingView.shimmering = NO;
        [loadingView removeFromSuperview];
        [self.view addSubview:customPlayer.view];
        [customPlayer play];
    }
}

- (void)fallbackWithNotification:(NSNotification *)notification {
    // Check if error
    if ([[[notification userInfo] objectForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] intValue] == MPMovieFinishReasonPlaybackError) {
        [customPlayer stop];
        @autoreleasepool {
            UILabel *errorTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, playerHeight/2-21, self.navigationController.view.frame.size.width, 21)];
            errorTitle.textColor = [UIColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:1.0f];
            errorTitle.font = [UIFont boldSystemFontOfSize:18.0f];
            errorTitle.textAlignment = NSTextAlignmentCenter;
            errorTitle.text = @"Error loading video";
            [self.view addSubview:errorTitle];
        }
        
        @autoreleasepool {
            NSNumber *errorNumber = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
            NSError *error = [[notification userInfo] objectForKey:@"error"];
            
            UILabel *errorDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, playerHeight/2, self.navigationController.view.frame.size.width, playerHeight/2)];
            errorDescription.textColor = [UIColor colorWithRed:0.5f green:0.0f blue:0.0f alpha:1.0f];
            errorDescription.font = [UIFont systemFontOfSize:16.0f];
            errorDescription.textAlignment = NSTextAlignmentCenter;
            errorDescription.numberOfLines = 0;
            errorDescription.text = [NSString stringWithFormat:@"Error %d (%@)\nPlease try again later", [errorNumber intValue], error.localizedDescription];
            [self.view addSubview:errorDescription];
        }
    }
}

@end