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
    
    loadingWheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loadingWheel setFrame:CGRectMake(self.navigationController.view.frame.size.width/2-loadingWheel.frame.size.width/2, playerHeight/2-loadingWheel.frame.size.height/2, loadingWheel.frame.size.width, loadingWheel.frame.size.height)];
    [self.view addSubview:loadingWheel];
    [loadingWheel startAnimating];
    
    customPlayer = [[PSBNMoviePlayerController alloc] init];
    [customPlayer.view setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
    customPlayer.view.backgroundColor = self.view.backgroundColor;
    customPlayer.controlStyle = MPMovieControlStyleEmbedded;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readyToPlay:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    poster = [[UIImageView alloc] initWithFrame:CGRectMake(viewPadding, playerHeight+viewPadding, 100, 150)];
    poster.backgroundColor = [UIColor whiteColor];
    poster.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    poster.contentMode = UIViewContentModeRedraw;
    
    posterMask = [[UIImageView alloc] initWithFrame:poster.frame];
    posterMask.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    posterMask.contentMode = UIViewContentModeRedraw;
    posterMask.image = [UIImage imageNamed:@"posterMask"];
    [self.view insertSubview:posterMask aboveSubview:poster];
    
    eventName = [[UILabel alloc] initWithFrame:CGRectMake(viewPadding+poster.frame.size.width+viewPadding, playerHeight+viewPadding, self.navigationController.view.frame.size.width-viewPadding-poster.frame.size.width-viewPadding, 63)];
    eventName.text = self.title;
    eventName.numberOfLines = 3;
    eventName.adjustsFontSizeToFitWidth = YES;
    eventName.adjustsLetterSpacingToFitWidth = YES;
    [self.view addSubview:eventName];
    
    eventDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewPadding+poster.frame.size.width+viewPadding, playerHeight+viewPadding+eventName.frame.size.height+viewPadding, self.navigationController.view.frame.size.width-viewPadding-poster.frame.size.width-viewPadding, 21)];
    @autoreleasepool {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        eventDateLabel.text = [dateFormatter stringFromDate:self.eventDate];
    }
    eventDateLabel.textColor = [UIColor colorWithRed:100/255.0f green:0.0f blue:0.0f alpha:1.0f];
    eventDateLabel.adjustsFontSizeToFitWidth = YES;
    eventDateLabel.adjustsLetterSpacingToFitWidth = YES;
    [self.view addSubview:eventDateLabel];
    
    [self refresh];
}

- (void)refresh {
    @autoreleasepool {
        NSString *eventAPIURL = [NSString stringWithFormat:@"https://api.new.livestream.com/accounts/5145446/events/%ld", self.eventID];
        NSData *eventAPI = [NSData dataWithContentsOfURL:[NSURL URLWithString:eventAPIURL]];
        NSError *eventError;
        NSDictionary *eventContent = [NSJSONSerialization JSONObjectWithData:eventAPI options:kNilOptions error:&eventError];
        if (eventError) {
            @autoreleasepool {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:eventError.localizedFailureReason message:eventError.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [errorAlert show];
            }
        } else {
            if ([NSURL URLWithString:[[[[[eventContent objectForKey:@"feed"] objectForKey:@"data"] firstObject] objectForKey:@"data"] objectForKey:@"secure_progressive_url_hd"]]) {
                [customPlayer setContentURL:[NSURL URLWithString:[[[[[eventContent objectForKey:@"feed"] objectForKey:@"data"] firstObject] objectForKey:@"data"] objectForKey:@"secure_progressive_url_hd"]]];
            } else {
                [customPlayer setContentURL:[NSURL URLWithString:[[[[[eventContent objectForKey:@"feed"] objectForKey:@"data"] firstObject] objectForKey:@"data"] objectForKey:@"secure_progressive_url"]]];
            }
            [customPlayer prepareToPlay];
            
            @autoreleasepool {
                NSURL *url;
                
                if ([[UIScreen mainScreen] scale] == 2.00) {
                    url = [NSURL URLWithString:[[[eventContent objectForKey:@"logo"] objectForKey:@"small_url"] stringByReplacingOccurrencesOfString:@"170x255" withString:@"200x300"]];
                } else {
                    url = [NSURL URLWithString:[[[eventContent objectForKey:@"logo"] objectForKey:@"small_url"] stringByReplacingOccurrencesOfString:@"170x255" withString:@"100x150"]];
                }
                
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if (!error) {
                        poster.image = [UIImage imageWithData:data];
                    } else {
                        // Load image error
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                            poster.image = [UIImage imageNamed:@"errorLoading"];
                        } else {
                            poster.image = [UIImage imageNamed:@"errorLoading_iPhone"];
                        }
                    }
                    [self.view insertSubview:poster belowSubview:posterMask];
                }];
            }
        }
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
    
    if (fallbackPlayer != nil) {
        [fallbackPlayer setFrame:CGRectMake(0, 0, self.navigationController.view.frame.size.width, playerHeight)];
    }
    
    [poster setFrame:CGRectMake(0, playerHeight+5, 100, 150)];
    
    [posterMask setFrame:poster.frame];
    
    [eventName setFrame:CGRectMake(poster.frame.size.width+5, playerHeight+5, self.navigationController.view.frame.size.width-poster.frame.size.width-5, 21)];
    
    [eventDateLabel setFrame:CGRectMake(poster.frame.size.width+5, playerHeight+10+21+5, self.navigationController.view.frame.size.width-poster.frame.size.width-5, 21)];
}

- (void)readyToPlay:(NSNotification *)notification {
    if (customPlayer.loadState == MPMovieLoadStatePlayable) {
        [loadingWheel stopAnimating];
        [loadingWheel removeFromSuperview];
        [self.view addSubview:customPlayer.view];
        [customPlayer play];
    }
}

- (void)fallbackWithNotification:(NSNotification *)notification {
    @autoreleasepool {
        UIAlertView *videoError = [[UIAlertView alloc] initWithTitle:@"Error loading video" message:[NSString stringWithFormat:@"%@", [notification userInfo]] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [videoError show];
    }
    // Check if error
    if ([[[notification userInfo] objectForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] intValue] == MPMovieFinishReasonPlaybackError) {
        
    }
}

@end