//
//  PSBNScoreboard.m
//  PSBN
//
//  Created by Victor Ilisei on 3/27/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNScoreboard.h"

@implementation PSBNScoreboard

- (void)setObject:(PFObject *)object {
    self.scoreObject = object;
}

- (void)writeHeader {
    @autoreleasepool {
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 21)];
        locationLabel.textAlignment = NSTextAlignmentCenter;
        locationLabel.text = [NSString stringWithFormat:@"%@ - %@", self.scoreObject[@"homeTeam"], self.scoreObject[@"city"]];
        locationLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:locationLabel];
    }
}

- (void)createTeamIcons {
    @autoreleasepool {
        self.awayIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.awayIcon];
    }
    
    @autoreleasepool {
        self.homeIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.homeIcon];
    }
    
    /*
    // Async loading of posters
    NSURL *url;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0)) {
        // Retina
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            url = [NSURL URLWithString:[object objectForKey:@"posterURLretina"]];
        } else {
            url = [NSURL URLWithString:[object objectForKey:@"posterURLretina_iPhone"]];
        }
    } else {
        // Non-Retina
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            url = [NSURL URLWithString:[object objectForKey:@"posterURL"]];
        } else {
            url = [NSURL URLWithString:[object objectForKey:@"posterURL_iPhone"]];
        }
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        cell.imageView.image = nil;
        if (!error) {
            cell.imageView.image = [UIImage imageWithData:data];
        }
    }];
     */
}

- (void)writeFooter {
    @autoreleasepool {
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-21, self.frame.size.width, 21)];
        
        NSDateFormatter *lastUpdatedFormatter = [[NSDateFormatter alloc] init];
        [lastUpdatedFormatter setDateStyle:NSDateFormatterShortStyle];
        [lastUpdatedFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        footerLabel.text = [NSString stringWithFormat:@"%@ - %@ - %@", self.scoreObject[@"gameDate"], self.scoreObject[@"quarter"], [lastUpdatedFormatter stringFromDate:self.scoreObject.updatedAt]];
        footerLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:footerLabel];
    }
}

@end