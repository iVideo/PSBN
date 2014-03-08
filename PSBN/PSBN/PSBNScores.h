//
//  PSBNScores.h
//  PSBN
//
//  Created by Victor Ilisei on 10/16/13.
//  Copyright (c) 2013 Tech Genius. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "PSBNRadio.h"

@interface PSBNScores : UITableViewController <UIActionSheetDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIPopoverControllerDelegate> {
    UIBarButtonItem *submitScores;
    UIActionSheet *composeActionSheet;
    
    UIBarButtonItem *showRadio;
    UIPopoverController *showRadioFrame;
    
    NSMutableArray *footballGames;
    NSMutableArray *volleyballGames;
    NSMutableArray *basketballGames;
    NSMutableArray *soccerGames;
    
    NSTimer *refreshTimer;
    
    UIProgressView *backgroundProgress;
    float scoresProcessed;
    float numberOfScores;
}

- (IBAction)resetTimer:(id)sender;
- (IBAction)chooseSubmit:(id)sender;
- (IBAction)showRadio:(id)sender;

@end