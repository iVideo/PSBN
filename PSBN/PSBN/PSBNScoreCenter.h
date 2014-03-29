//
//  PSBNScoreCenter.h
//  PSBN
//
//  Created by Victor Ilisei on 3/29/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "PSBNRadio.h"

@interface PSBNScoreCenter : UICollectionViewController <UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, UIPopoverControllerDelegate> {
    UIActionSheet *composeActionSheet;
    
    UIPopoverController *showRadioFrame;
    
    NSMutableArray *games;
    
    NSTimer *refreshTimer;
}

- (void)refresh;
- (IBAction)resetTimer:(id)sender;
- (IBAction)chooseSubmit:(id)sender;
- (IBAction)showRadio:(id)sender;

@end