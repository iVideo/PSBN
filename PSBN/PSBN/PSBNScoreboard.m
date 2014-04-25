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
    
    self.layer.cornerRadius = 5.0f;
    self.layer.masksToBounds = YES;
    
    [self drawBackground];
    
    [self writeHeader];
    [self createTeamIcons];
    [self fillInScores];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    gradient.startPoint = CGPointMake(0, 0);
    gradient.locations = @[@0, @0.5, @0.5, @1.0];
    gradient.endPoint = CGPointMake(1.0, 1.0);
    gradient.colors = @[(id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor, (id)[UIColor colorWithWhite:1.0f alpha:0.1f].CGColor, (id)[UIColor colorWithWhite:0.75f alpha:0.0f].CGColor, (id)[UIColor colorWithWhite:1.0f alpha:0.1f].CGColor];
    [self.layer addSublayer:gradient];
}

- (void)drawBackground {
    @autoreleasepool {
        UIView *whiteBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height-21)];
        whiteBackground.backgroundColor = [UIColor whiteColor];
        whiteBackground.layer.borderColor = self.objectColor.CGColor;
        whiteBackground.layer.borderWidth = 5.0f;
        [self addSubview:whiteBackground];
    }
}

- (void)writeHeader {
    @autoreleasepool {
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 21)];
        locationLabel.backgroundColor = self.objectColor;
        locationLabel.textColor = [UIColor whiteColor];
        locationLabel.textAlignment = NSTextAlignmentCenter;
        
        locationLabel.text = [NSString stringWithFormat:@"%@ High School - %@", self.scoreObject[@"homeTeam"], self.scoreObject[@"city"]];
        locationLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:locationLabel];
    }
}

- (void)createTeamIcons {
    @autoreleasepool {
        self.awayIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 26, 75, 75)];
        self.awayIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.awayIcon.image = [UIImage imageNamed:self.scoreObject[@"awayTeam"]];
        [self addSubview:self.awayIcon];
    }
    
    @autoreleasepool {
        self.homeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(220, 26, 75, 75)];
        self.homeIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.homeIcon.image = [UIImage imageNamed:self.scoreObject[@"homeTeam"]];
        [self addSubview:self.homeIcon];
    }
}

- (void)fillInScores {
    @autoreleasepool {
        self.overallScore = [[UILabel alloc] initWithFrame:CGRectMake(90, 26, 125, 75)];
        self.overallScore.backgroundColor = [UIColor blackColor];
        self.overallScore.textColor = [UIColor whiteColor];
        self.overallScore.textAlignment = NSTextAlignmentCenter;
        self.overallScore.font = [UIFont fontWithName:@"DS-Digital-Bold" size:40.0f];
        self.overallScore.text = [NSString stringWithFormat:@"%@ - %@", self.scoreObject[@"awayScore"], self.scoreObject[@"homeScore"]];
                
        [self addSubview:self.overallScore];
    }
}

- (void)writeFooterWithType:(NSString *)type {
    @autoreleasepool {
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-21, self.frame.size.width, 21)];
        footerLabel.backgroundColor = self.objectColor;
        footerLabel.textColor = [UIColor whiteColor];
        footerLabel.adjustsFontSizeToFitWidth = YES;
        
        NSDateFormatter *lastUpdatedFormatter1 = [[NSDateFormatter alloc] init];
        [lastUpdatedFormatter1 setDateStyle:NSDateFormatterShortStyle];
        
        NSDateFormatter *lastUpdatedFormatter2 = [[NSDateFormatter alloc] init];
        [lastUpdatedFormatter2 setTimeStyle:NSDateFormatterShortStyle];
        
        footerLabel.text = [NSString stringWithFormat:@"%@ - %@ - UPD: %@", [lastUpdatedFormatter1 stringFromDate:self.scoreObject[@"gameDate"]], self.scoreObject[type], [lastUpdatedFormatter2 stringFromDate:self.scoreObject.updatedAt]];
        footerLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:footerLabel];
    }
}

@end