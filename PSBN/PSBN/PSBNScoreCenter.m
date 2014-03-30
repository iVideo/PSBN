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
    flowLayout.headerReferenceSize = CGSizeMake(self.navigationController.view.frame.size.width, 30);
    flowLayout.itemSize = CGSizeMake(310, 210);
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
    self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.collectionView.alwaysBounceVertical = YES;
    
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Refresh
    [self refresh];
}

- (void)refresh {
    // Stop timer
    [refreshTimer invalidate];
    refreshTimer = nil;
    
    // Reset array
    games = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        PFQuery *query = [PFQuery queryWithClassName:@"footballScores"];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cache_reset"]) {
            [query clearCachedResult];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cache_disable"]) {
            query.cachePolicy = kPFCachePolicyNetworkOnly;
        } else {
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
        query.limit = 1000;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            @autoreleasepool {
                NSMutableArray *footballGames = objects.mutableCopy;
                [footballGames sortUsingComparator:^NSComparisonResult(id dict1, id dict2) {
                    NSDate *date1 = [(PFObject *)dict1 objectForKey:@"gameDate"];
                    NSDate *date2 = [(PFObject *)dict2 objectForKey:@"gameDate"];
                    return [date2 compare:date1];
                }];
                NSDictionary *dict = @{@"index": @0, @"section": @"Football", @"scoreObjects": footballGames};
                
                [games addObject:dict];
                [games sortUsingComparator:^NSComparisonResult(id dict1, id dict2) {
                    NSNumber *index1 = [(NSDictionary *)dict1 objectForKey:@"index"];
                    NSNumber *index2 = [(NSDictionary *)dict2 objectForKey:@"index"];
                    return [index1 compare:index2];
                }];
                if ([games count] == 1) {
                    [self.collectionView reloadData];
                }
            }
        }];
    }
    
    // Start timer
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(refresh) userInfo:nil repeats:NO];
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
    @autoreleasepool {
        PSBNRadio *radioVC = [[PSBNRadio alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:radioVC];
        if ([showRadioFrame isPopoverVisible]) {
            [showRadioFrame dismissPopoverAnimated:YES];
        } else {
            if ([composeActionSheet isVisible]) {
                [composeActionSheet dismissWithClickedButtonIndex:[composeActionSheet cancelButtonIndex] animated:YES];
            }
            showRadioFrame = [[UIPopoverController alloc] initWithContentViewController:navController];
            showRadioFrame.delegate = self;
            [showRadioFrame presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

#pragma mark - Collection View Data Sources

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [games count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[games objectAtIndex:section] objectForKey:@"scoreObjects"] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        static NSString *HeaderIdentifier = @"HeaderView";
        [collectionView registerClass:[PSBNScoreHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderIdentifier];
        PSBNScoreHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderIdentifier forIndexPath:indexPath];
        // Configure the header...
        [headerView createHeaderTitleWith:[[games objectAtIndex:indexPath.section] objectForKey:@"section"]];
        
        return headerView;
    } else {
        return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    if (indexPath.section == 0) {
        [collectionView registerClass:[PSBNFootball class] forCellWithReuseIdentifier:CellIdentifier];
        PSBNFootball *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        // Configure the cell...
        [cell setObject:[[[games objectAtIndex:indexPath.section] objectForKey:@"scoreObjects"] objectAtIndex:indexPath.row]];
        
        return cell;
    } else {
        return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
}

@end