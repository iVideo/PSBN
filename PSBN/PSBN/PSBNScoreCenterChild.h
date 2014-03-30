//
//  PSBNScoreCenterChild.h
//  PSBN
//
//  Created by Victor Ilisei on 3/29/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNScoreHeader.h"

#import "PSBNFootball.h"
#import "PSBNVolleyball.h"
#import "PSBNBasketball.h"

@interface PSBNScoreCenterChild : UICollectionViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate> {
    NSString *queryClassName;
    
    UIActionSheet *composeActionSheet;
    
    UIPopoverController *showRadioFrame;
    
    NSMutableArray *games;
    
    NSTimer *refreshTimer;
}

- (id)initWithSport:(NSString *)sportName;
- (void)refresh;

@end