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
    
    [self drawBackground];
    
    [self writeHeader];
    [self createTeamIcons];
    [self writeFooter];
}

- (void)drawBackground {
    @autoreleasepool {
        UIView *whiteBackground = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 200)];
        whiteBackground.layer.borderColor = [UIColor grayColor].CGColor;
        whiteBackground.layer.borderWidth = 5.0f;
        [self addSubview:whiteBackground];
    }
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            @autoreleasepool {
                NSArray *schoolIconArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"School Logos" ofType:@"plist"]];
                for (NSDictionary *school in schoolIconArray) {
                    @autoreleasepool {
                        if ([[school objectForKey:@"School Name"] isEqualToString:self.scoreObject[@"awayTeam"]]) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                @autoreleasepool {
                                    if ([UIScreen mainScreen].scale == 2.0) {
                                        self.awayIcon.image = [UIImage imageWithData:[school objectForKey:@"Retina"]];
                                    } else {
                                        self.awayIcon.image = [UIImage imageWithData:[school objectForKey:@"Normal"]];
                                    }
                                }
                            });
                        }
                    }
                }
            }
        });
        [self addSubview:self.awayIcon];
    }
    
    @autoreleasepool {
        self.homeIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            @autoreleasepool {
                NSArray *schoolIconArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"School Logos" ofType:@"plist"]];
                for (NSDictionary *school in schoolIconArray) {
                    @autoreleasepool {
                        if ([[school objectForKey:@"School Name"] isEqualToString:self.scoreObject[@"homeTeam"]]) {
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                @autoreleasepool {
                                    if ([UIScreen mainScreen].scale == 2.0) {
                                        self.awayIcon.image = [UIImage imageWithData:[school objectForKey:@"Retina"]];
                                    } else {
                                        self.awayIcon.image = [UIImage imageWithData:[school objectForKey:@"Normal"]];
                                    }
                                }
                            });
                        }
                    }
                }
            }
        });
        [self addSubview:self.homeIcon];
    }
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