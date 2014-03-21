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
    // Check if video file for custom player exists
    PFQuery *livestreamQuery = [PFQuery queryWithClassName:@"livestreamAvailable"];
    [livestreamQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            UIAlertView *errorLoadingLive = [[UIAlertView alloc] initWithTitle:@"Error checking if live" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [errorLoadingLive show];
        } else {
            customPlayerReloadInterval = [[object objectForKey:@"customPlayerUpdateInterval"] doubleValue];
        }
    }];
    PFQuery *query = [PFQuery queryWithClassName:@"eventList"];
    [query getObjectInBackgroundWithId:[[NSUserDefaults standardUserDefaults] objectForKey:@"videoChosen"] block:^(PFObject *object, NSError *error) {
        customPlayerURL = [NSURL URLWithString:[object objectForKey:@"customPlayer"]];
        fallbackPlayerURL = [NSURL URLWithString:[object objectForKey:@"fallbackPlayer"]];
        // Check if valid custom player URL
        
        if ([[object updatedAt] timeIntervalSinceNow] < customPlayerReloadInterval || [customPlayerURL.absoluteString isEqualToString:@"(undefined)"] || [customPlayerURL.absoluteString isEqualToString:@""]) {
            validCustomPlayerURL = NO;
        } else {
            validCustomPlayerURL = YES;
        }
        if (validCustomPlayerURL) {
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
        } else {
            fallbackPlayer = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
            [self.view addSubview:fallbackPlayer];
            fallbackPlayer.scrollView.bounces = NO;
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:fallbackPlayerURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
            [fallbackPlayer loadRequest:urlRequest];
        }
        
        poster = [[UIImageView alloc] initWithFrame:CGRectMake(5, playerHeight+5, 100, 150)];
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
        
        eventName = [[UILabel alloc] initWithFrame:CGRectMake(poster.frame.size.width+20, playerHeight+5, self.navigationController.view.frame.size.width-poster.frame.size.width-20, 21)];
        eventName.text = [object objectForKey:@"title"];
        eventName.adjustsFontSizeToFitWidth = YES;
        eventName.adjustsLetterSpacingToFitWidth = YES;
        [self.view addSubview:eventName];
        
        eventDate = [[UILabel alloc] initWithFrame:CGRectMake(poster.frame.size.width+20, playerHeight+5+21+5, self.navigationController.view.frame.size.width-poster.frame.size.width-20, 21)];
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
    
    if (validCustomPlayerURL) {
        [customPlayer.view setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
    } else {
        [fallbackPlayer setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
    }
    
    [poster setFrame:CGRectMake(0, playerHeight+5, 100, 150)];
    
    [posterMask setFrame:poster.frame];
    
    [eventName setFrame:CGRectMake(poster.frame.size.width+5, playerHeight+5, self.navigationController.view.frame.size.width-poster.frame.size.width-5, 21)];
    
    [eventDate setFrame:CGRectMake(poster.frame.size.width+5, playerHeight+10+21+5, self.navigationController.view.frame.size.width-poster.frame.size.width-5, 21)];
    // [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (validCustomPlayerURL) {
        if (!customPlayer.fullscreen) {
            [customPlayer pause];
            [customPlayer stop];
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (validCustomPlayerURL) {
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
        
        if (validCustomPlayerURL) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [customPlayer.view setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
            });
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [fallbackPlayer setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
            });
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [poster setFrame:CGRectMake(0, playerHeight+5, 100, 150)];
            
            [posterMask setFrame:poster.frame];
            
            [eventName setFrame:CGRectMake(poster.frame.size.width+5, playerHeight+5, self.navigationController.view.frame.size.width-poster.frame.size.width-5, 21)];
            
            [eventDate setFrame:CGRectMake(poster.frame.size.width+5, playerHeight+10+21+5, self.navigationController.view.frame.size.width-poster.frame.size.width-5, 21)];
        });
    });
}

@end