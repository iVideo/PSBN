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

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
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
    }
    // Set padding
    viewPadding = 10.0f;
    // Check if video file for custom player exists
    objectID = [[NSUserDefaults standardUserDefaults] objectForKey:@"videoChosen"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"eventList"];
    [query getObjectInBackgroundWithId:objectID block:^(PFObject *object, NSError *error) {
        customPlayerURL = [NSURL URLWithString:[object objectForKey:@"customPlayer"]];
        fallbackPlayerURL = [NSURL URLWithString:[object objectForKey:@"fallbackPlayer"]];
        // Check if valid custom player URL
        
        customPlayer = [[PSBNMoviePlayerController alloc] initWithContentURL:customPlayerURL];
        [customPlayer prepareToPlay];
        [customPlayer.view setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
        customPlayer.view.backgroundColor = [UIColor blackColor];
        customPlayer.controlStyle = MPMovieControlStyleEmbedded;
        if ([[customPlayerURL pathExtension] isEqualToString:@"m3u8"]) {
            customPlayer.movieSourceType = MPMovieSourceTypeStreaming;
        } else {
            customPlayer.movieSourceType = MPMovieSourceTypeFile;
        }
        [customPlayer play];
        [self.view addSubview:customPlayer.view];
        
        poster = [[UIImageView alloc] initWithFrame:CGRectMake(viewPadding, playerHeight+5, 100, 150)];
        poster.backgroundColor = [UIColor whiteColor];
        poster.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        poster.contentMode = UIViewContentModeRedraw;
        
        NSURL *url = [NSURL URLWithString:[object objectForKey:@"posterURL"]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (!error) {
                poster.image = [UIImage imageWithData:data];
            } else {
                // Load image error
                poster.image = [UIImage imageNamed:@"errorLoading"];
            }
        }];
        [self.view addSubview:poster];
        
        posterMask = [[UIImageView alloc] initWithFrame:poster.frame];
        posterMask.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        posterMask.contentMode = UIViewContentModeRedraw;
        posterMask.image = [UIImage imageNamed:@"posterMask"];
        [self.view addSubview:posterMask];
        
        eventName = [[UILabel alloc] initWithFrame:CGRectMake(viewPadding+poster.frame.size.width+viewPadding, playerHeight+5, self.navigationController.view.frame.size.width-viewPadding-poster.frame.size.width-viewPadding, 21)];
        eventName.text = [object objectForKey:@"title"];
        eventName.adjustsFontSizeToFitWidth = YES;
        eventName.adjustsLetterSpacingToFitWidth = YES;
        [self.view addSubview:eventName];
        
        eventDate = [[UILabel alloc] initWithFrame:CGRectMake(viewPadding+poster.frame.size.width+viewPadding, playerHeight+5+21+5, self.navigationController.view.frame.size.width-viewPadding-poster.frame.size.width-viewPadding, 21)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        eventDate.text = [dateFormatter stringFromDate:[object objectForKey:@"filmedOn"]];
        eventDate.textColor = [UIColor colorWithRed:100/255.0f green:0.0f blue:0.0f alpha:1.0f];
        eventDate.adjustsFontSizeToFitWidth = YES;
        eventDate.adjustsLetterSpacingToFitWidth = YES;
        [self.view addSubview:eventDate];
    }];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"videoChosen"];
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
    
    if (customPlayer != nil) {
        [customPlayer.view setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
    }
    
    if (fallbackPlayer != nil) {
        [fallbackPlayer setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
    }
    
    [poster setFrame:CGRectMake(0, playerHeight+5, 100, 150)];
    
    [posterMask setFrame:poster.frame];
    
    [eventName setFrame:CGRectMake(poster.frame.size.width+5, playerHeight+5, self.navigationController.view.frame.size.width-poster.frame.size.width-5, 21)];
    
    [eventDate setFrame:CGRectMake(poster.frame.size.width+5, playerHeight+10+21+5, self.navigationController.view.frame.size.width-poster.frame.size.width-5, 21)];
    // [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fallbackWithNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (customPlayer != nil) {
        if (!customPlayer.fullscreen) {
            [customPlayer pause];
            [customPlayer stop];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
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
        
        if (fallbackPlayer != nil) {
            [fallbackPlayer setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [poster setFrame:CGRectMake(0, playerHeight+5, 100, 150)];
            
            [posterMask setFrame:poster.frame];
            
            [eventName setFrame:CGRectMake(poster.frame.size.width+5, playerHeight+5, self.navigationController.view.frame.size.width-poster.frame.size.width-5, 21)];
            
            [eventDate setFrame:CGRectMake(poster.frame.size.width+5, playerHeight+10+21+5, self.navigationController.view.frame.size.width-poster.frame.size.width-5, 21)];
        });
    });
}

- (void)fallbackWithNotification:(NSNotification *)notification {
    // Check if error
    if ([[[notification userInfo] objectForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] intValue] == MPMovieFinishReasonPlaybackError) {
        // Remove custom player
        [customPlayer pause];
        [customPlayer stop];
        [customPlayer.view removeFromSuperview];
        
        // Set not playable flag
        PFQuery *query = [PFQuery queryWithClassName:@"eventList"];
        [query getObjectInBackgroundWithId:objectID block:^(PFObject *object, NSError *error) {
            object[@"playable"] = @NO;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    [object saveEventually];
                }
            }];
        }];
        
        // Create fallback player
        fallbackPlayer = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
        [self.view addSubview:fallbackPlayer];
        fallbackPlayer.scrollView.bounces = NO;
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:fallbackPlayerURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
        [fallbackPlayer loadRequest:urlRequest];
    }
}

@end