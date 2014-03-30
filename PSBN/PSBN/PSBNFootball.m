//
//  PSBNFootball.m
//  PSBN
//
//  Created by Victor Ilisei on 3/29/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNFootball.h"

@implementation PSBNFootball

- (void)setObject:(PFObject *)object {
    self.objectColor = [UIColor colorWithRed:0.0f green:1/3.0f blue:0.0f alpha:1.0f];
    [super setObject:object];
}

- (void)fillInScores {
    [super fillInScores];
    
    // Quarters
    @autoreleasepool {
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(5, 106, 300, 21)];
        background.backgroundColor = self.objectColor;
        [self addSubview:background];
        
        UILabel *quarter1 = [[UILabel alloc] initWithFrame:CGRectMake(85, background.frame.origin.y, 27, background.frame.size.height)];
        quarter1.backgroundColor = self.objectColor;
        quarter1.textColor = [UIColor whiteColor];
        quarter1.textAlignment = NSTextAlignmentCenter;
        quarter1.text = @"1";
        [self addSubview:quarter1];
        
        UILabel *quarter2 = [[UILabel alloc] initWithFrame:CGRectMake(132, background.frame.origin.y, 27, background.frame.size.height)];
        quarter2.backgroundColor = self.objectColor;
        quarter2.textColor = [UIColor whiteColor];
        quarter2.textAlignment = quarter1.textAlignment;
        quarter2.text = @"2";
        [self addSubview:quarter2];
        
        UILabel *quarter3 = [[UILabel alloc] initWithFrame:CGRectMake(179, background.frame.origin.y, 27, background.frame.size.height)];
        quarter3.backgroundColor = self.objectColor;
        quarter3.textColor = [UIColor whiteColor];
        quarter3.textAlignment = quarter1.textAlignment;
        quarter3.text = @"3";
        [self addSubview:quarter3];
        
        UILabel *quarter4 = [[UILabel alloc] initWithFrame:CGRectMake(226, background.frame.origin.y, 27, background.frame.size.height)];
        quarter4.backgroundColor = self.objectColor;
        quarter4.textColor = [UIColor whiteColor];
        quarter4.textAlignment = quarter1.textAlignment;
        quarter4.text = @"4";
        [self addSubview:quarter4];
        
        UILabel *quarterT = [[UILabel alloc] initWithFrame:CGRectMake(273, background.frame.origin.y, 27, background.frame.size.height)];
        quarterT.backgroundColor = self.objectColor;
        quarterT.textColor = [UIColor whiteColor];
        quarterT.textAlignment = quarter1.textAlignment;
        quarterT.text = @"T";
        [self addSubview:quarterT];
    }
    
    // Teams
    @autoreleasepool {
        UIView *background1 = [[UIView alloc] initWithFrame:CGRectMake(5, 132, 300, 33)];
        background1.backgroundColor = [UIColor blackColor];
        [self addSubview:background1];
        
        UIView *background2 = [[UIView alloc] initWithFrame:CGRectMake(5, 170, 300, 33)];
        background2.backgroundColor = [UIColor blackColor];
        [self addSubview:background2];
        
        UILabel *awayTeam = [[UILabel alloc] initWithFrame:CGRectMake(10, 132, 65, 33)];
        awayTeam.backgroundColor = background1.backgroundColor;
        awayTeam.textColor = [UIColor whiteColor];
        awayTeam.text = self.scoreObject[@"awayTeam"];
        awayTeam.adjustsFontSizeToFitWidth = YES;
        [self addSubview:awayTeam];
        
        UILabel *homeTeam = [[UILabel alloc] initWithFrame:CGRectMake(10, 170, 65, 33)];
        homeTeam.backgroundColor = background2.backgroundColor;
        homeTeam.textColor = [UIColor whiteColor];
        homeTeam.text = self.scoreObject[@"homeTeam"];
        homeTeam.adjustsFontSizeToFitWidth = YES;
        [self addSubview:homeTeam];
    }
    
    // Per Quarter scores
    @autoreleasepool {
        UIColor *backgroundColor = [UIColor blackColor];
        
        UILabel *away1 = [[UILabel alloc] initWithFrame:CGRectMake(85, 132, 27, 33)];
        away1.backgroundColor = backgroundColor;
        away1.textColor = [UIColor whiteColor];
        away1.text = [NSString stringWithFormat:@"%@", self.scoreObject[@"away1"]];
        away1.textAlignment = NSTextAlignmentCenter;
        away1.adjustsFontSizeToFitWidth = YES;
        [self addSubview:away1];
        
        UILabel *away2 = [[UILabel alloc] initWithFrame:CGRectMake(132, 132, 27, 33)];
        away2.backgroundColor = backgroundColor;
        away2.textColor = [UIColor whiteColor];
        away2.text = [NSString stringWithFormat:@"%@", self.scoreObject[@"away2"]];
        away2.textAlignment = NSTextAlignmentCenter;
        away2.adjustsFontSizeToFitWidth = YES;
        [self addSubview:away2];
        
        UILabel *away3 = [[UILabel alloc] initWithFrame:CGRectMake(179, 132, 27, 33)];
        away3.backgroundColor = backgroundColor;
        away3.textColor = [UIColor whiteColor];
        away3.text = [NSString stringWithFormat:@"%@", self.scoreObject[@"away3"]];
        away3.textAlignment = NSTextAlignmentCenter;
        away3.adjustsFontSizeToFitWidth = YES;
        [self addSubview:away3];
        
        UILabel *away4 = [[UILabel alloc] initWithFrame:CGRectMake(226, 132, 27, 33)];
        away4.backgroundColor = backgroundColor;
        away4.textColor = [UIColor whiteColor];
        away4.text = [NSString stringWithFormat:@"%@", self.scoreObject[@"away4"]];
        away4.textAlignment = NSTextAlignmentCenter;
        away4.adjustsFontSizeToFitWidth = YES;
        [self addSubview:away4];
        
        UILabel *awayT = [[UILabel alloc] initWithFrame:CGRectMake(273, 132, 27, 33)];
        awayT.backgroundColor = backgroundColor;
        awayT.textColor = [UIColor whiteColor];
        awayT.text = [NSString stringWithFormat:@"%@", self.scoreObject[@"awayScore"]];
        awayT.textAlignment = NSTextAlignmentCenter;
        awayT.adjustsFontSizeToFitWidth = YES;
        [self addSubview:awayT];
    }
    
    // Per Quarter scores
    @autoreleasepool {
        UIColor *backgroundColor = [UIColor blackColor];
        
        UILabel *home1 = [[UILabel alloc] initWithFrame:CGRectMake(85, 170, 27, 33)];
        home1.backgroundColor = backgroundColor;
        home1.textColor = [UIColor whiteColor];
        home1.text = [NSString stringWithFormat:@"%@", self.scoreObject[@"home1"]];
        home1.textAlignment = NSTextAlignmentCenter;
        home1.adjustsFontSizeToFitWidth = YES;
        [self addSubview:home1];
        
        UILabel *home2 = [[UILabel alloc] initWithFrame:CGRectMake(132, 170, 27, 33)];
        home2.backgroundColor = backgroundColor;
        home2.textColor = [UIColor whiteColor];
        home2.text = [NSString stringWithFormat:@"%@", self.scoreObject[@"home2"]];
        home2.textAlignment = NSTextAlignmentCenter;
        home2.adjustsFontSizeToFitWidth = YES;
        [self addSubview:home2];
        
        UILabel *home3 = [[UILabel alloc] initWithFrame:CGRectMake(179, 170, 27, 33)];
        home3.backgroundColor = backgroundColor;
        home3.textColor = [UIColor whiteColor];
        home3.text = [NSString stringWithFormat:@"%@", self.scoreObject[@"home3"]];
        home3.textAlignment = NSTextAlignmentCenter;
        home3.adjustsFontSizeToFitWidth = YES;
        [self addSubview:home3];
        
        UILabel *home4 = [[UILabel alloc] initWithFrame:CGRectMake(226, 170, 27, 33)];
        home4.backgroundColor = backgroundColor;
        home4.textColor = [UIColor whiteColor];
        home4.text = [NSString stringWithFormat:@"%@", self.scoreObject[@"home4"]];
        home4.textAlignment = NSTextAlignmentCenter;
        home4.adjustsFontSizeToFitWidth = YES;
        [self addSubview:home4];
        
        UILabel *homeT = [[UILabel alloc] initWithFrame:CGRectMake(273, 170, 27, 33)];
        homeT.backgroundColor = backgroundColor;
        homeT.textColor = [UIColor whiteColor];
        homeT.text = [NSString stringWithFormat:@"%@", self.scoreObject[@"homeScore"]];
        homeT.textAlignment = NSTextAlignmentCenter;
        homeT.adjustsFontSizeToFitWidth = YES;
        [self addSubview:homeT];
    }
}

@end