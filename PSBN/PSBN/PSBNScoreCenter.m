//
//  PSBNScoreCenter.m
//  PSBN
//
//  Created by Victor Ilisei on 3/29/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNScoreCenter.h"

@interface PSBNScoreCenter ()

@end

@implementation PSBNScoreCenter

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(320, 81);
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {
        // Custom initialization
        self.title = @"Score Center";
        self.tabBarItem.image = [UIImage imageNamed:@"scores"];
        
        // this will appear as the title in the navigation bar
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"Tahoma-Bold" size:21.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = label;
        label.text = self.title;
        [label sizeToFit];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup submit button
    @autoreleasepool {
        UIBarButtonItem *submitScores = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(chooseSubmit:)];
        self.navigationItem.leftBarButtonItem = submitScores;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        @autoreleasepool {
            if ([self respondsToSelector:@selector(imageWithRenderingMode:)]) {
                UIBarButtonItem *showRadio = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"UITabBarPodcasts"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(showRadio:)];
                self.navigationItem.rightBarButtonItem = showRadio;
            } else {
                UIBarButtonItem *showRadio = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UITabBarPodcasts"] style:UIBarButtonItemStyleBordered target:self action:@selector(showRadio:)];
                self.navigationItem.rightBarButtonItem = showRadio;
            }
        }
    }
    
    // Auto-refresh every minute
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(refresh) userInfo:nil repeats:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Refresh
    [self refresh];
}

- (void)refresh {
    
}

- (IBAction)resetTimer:(id)sender {
    
}

- (IBAction)chooseSubmit:(id)sender {
    if ([composeActionSheet isVisible]) {
        [composeActionSheet dismissWithClickedButtonIndex:[composeActionSheet cancelButtonIndex] animated:YES];
    } else {
        if ([showRadioFrame isPopoverVisible]) {
            [showRadioFrame dismissPopoverAnimated:YES];
        }
        NSString *emailButtonText;
        if ([MFMailComposeViewController canSendMail]) {
            emailButtonText = @"Email";
        } else {
            emailButtonText = nil;
        }
        NSString *textButtonText;
        if ([MFMessageComposeViewController canSendText]) {
            textButtonText = @"Text Message";
        } else {
            textButtonText = nil;
        }
        
        // composeActionSheet = [[UIActionSheet alloc] initWithTitle:@"Submit Scores" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:emailButtonText, textButtonText, nil];
        composeActionSheet = [[UIActionSheet alloc] initWithTitle:@"Submit Scores" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:emailButtonText, nil];
        composeActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            composeActionSheet.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            composeActionSheet.tintColor = [UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f];
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [composeActionSheet showFromBarButtonItem:sender animated:YES];
        } else {
            [composeActionSheet showFromTabBar:self.tabBarController.tabBar];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        if (buttonIndex == 0) {
            // E-Mail
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
                mailViewController.mailComposeDelegate = self;
                mailViewController.navigationBar.barStyle = UIBarStyleBlack;
                [mailViewController setToRecipients:[NSArray arrayWithObjects:@"psbn@pusd11.org", nil]];
                [mailViewController setSubject:@"Game Score Update"];
                [mailViewController setMessageBody:@"Sport: \nTeams: \nHome Score: \nAway Score: \nQuarter/Set/Innings/Round: " isHTML:NO];
                if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
                    mailViewController.navigationBar.tintColor = [UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f];
                }
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
                }
                [self presentViewController:mailViewController animated:YES completion:nil];
            } else {
                UIAlertView *emailError = [[UIAlertView alloc] initWithTitle:@"Email Error" message:@"It appears that you can't send email for some reason. Please check your device's email settings." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [emailError show];
            }
        } else if (buttonIndex == 1) {
            // Text
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
                messageViewController.delegate = self;
                messageViewController.navigationBar.barStyle = UIBarStyleBlack;
                // [messageViewController setRecipients:[NSArray arrayWithObjects:@"622030979", nil]];
                [messageViewController setBody:@"Game Score Update\nSport: \nTeams: \nHome Score: \nAway Score: \nQuarter/Set/Innings/Round: "];
                if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
                    messageViewController.navigationBar.tintColor = [UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f];
                }
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    messageViewController.modalPresentationStyle = UIModalPresentationFormSheet;
                }
                [self presentViewController:messageViewController animated:YES completion:nil];
            } else {
                UIAlertView *textError = [[UIAlertView alloc] initWithTitle:@"Text Message Error" message:@"It appears that you can't send texts for some reason. Please check your device's text message settings." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [textError show];
            }
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showRadio:(id)sender {
    
}

@end