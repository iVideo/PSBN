//
//  PSBNScores.m
//  PSBN
//
//  Created by Victor Ilisei on 10/16/13.
//  Copyright (c) 2013 Tech Genius. All rights reserved.
//

#import "PSBNScores.h"

@interface PSBNScores ()

@end

@implementation PSBNScores

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Scores";
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

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup submit button
    submitScores = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(chooseSubmit:)];
    self.navigationItem.leftBarButtonItem = submitScores;
    
    // Setup tableview color
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    // Setup refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(refresh) userInfo:nil repeats:NO];
    // [refreshTimer initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:5.0] interval:5.0 target:self selector:@selector(refresh) userInfo:nil repeats:NO];
    
    // Scoreboard fonts are @"DS-Digital" or @"DS-Digital-Bold"
}

- (IBAction)chooseSubmit:(id)sender {
    if (![composeActionSheet isVisible]) {
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

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void)refresh {
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.translucent = YES;
    // self.hidesBottomBarWhenPushed = YES;
    
    backgroundProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, self.navigationController.toolbar.frame.size.height/2-3, self.navigationController.toolbar.frame.size.width-20, 6)];
    backgroundProgress.progress = 0.0f;
    backgroundProgress.progressTintColor = [UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f];
    backgroundProgress.trackTintColor = [UIColor blackColor];
    [self.navigationController.toolbar addSubview:backgroundProgress];
    numberOfScores = 0.0f;
    scoresProcessed = 0.0f;
    
    PFQuery *footballScoreQuery = [PFQuery queryWithClassName:@"footballScores"];
    footballScoreQuery.limit = 1000;
    [footballScoreQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        numberOfScores += (float)(number);
        [backgroundProgress setProgress:scoresProcessed/numberOfScores animated:YES];
        [footballScoreQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                UIAlertView *loadFeedError = [[UIAlertView alloc] initWithTitle:@"Error loading football scores" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                [loadFeedError show];
            } else {
                footballGames = [[NSMutableArray alloc] init];
                for (PFObject *object in objects) {
                    [footballGames addObject:object];
                    
                    scoresProcessed++;
                    [backgroundProgress setProgress:scoresProcessed/numberOfScores animated:YES];
                }
                [footballGames sortUsingComparator:^NSComparisonResult(id dict1, id dict2) {
                    NSDate *date1 = [(PFObject *)dict1 objectForKey:@"gameDate"];
                    NSDate *date2 = [(PFObject *)dict2 objectForKey:@"gameDate"];
                    return [date2 compare:date1];
                }];
            }
            PFQuery *volleyballScoreQuery = [PFQuery queryWithClassName:@"volleyballScores"];
            volleyballScoreQuery.limit = 1000;
            [volleyballScoreQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                numberOfScores += (float)(number);
                [backgroundProgress setProgress:scoresProcessed/numberOfScores animated:YES];
                [volleyballScoreQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (error) {
                        UIAlertView *loadFeedError = [[UIAlertView alloc] initWithTitle:@"Error loading volleyball scores" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                        [loadFeedError show];
                    } else {
                        volleyballGames = [[NSMutableArray alloc] init];
                        for (PFObject *object in objects) {
                            [volleyballGames addObject:object];
                            
                            scoresProcessed++;
                            [backgroundProgress setProgress:scoresProcessed/numberOfScores animated:YES];
                        }
                        [volleyballGames sortUsingComparator:^NSComparisonResult(id dict1, id dict2) {
                            NSDate *date1 = [(PFObject *)dict1 objectForKey:@"gameDate"];
                            NSDate *date2 = [(PFObject *)dict2 objectForKey:@"gameDate"];
                            return [date2 compare:date1];
                        }];
                    }
                    PFQuery *basketallScoreQuery = [PFQuery queryWithClassName:@"basketballScores"];
                    basketallScoreQuery.limit = 1000;
                    [basketallScoreQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                        numberOfScores += (float)(number);
                        [backgroundProgress setProgress:scoresProcessed/numberOfScores animated:YES];
                        [basketallScoreQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (error) {
                                UIAlertView *loadFeedError = [[UIAlertView alloc] initWithTitle:@"Error loading basketball scores" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                                [loadFeedError show];
                            } else {
                                basketballGames = [[NSMutableArray alloc] init];
                                for (PFObject *object in objects) {
                                    [basketballGames addObject:object];
                                    
                                    scoresProcessed++;
                                    [backgroundProgress setProgress:scoresProcessed/numberOfScores animated:YES];
                                }
                                [basketballGames sortUsingComparator:^NSComparisonResult(id dict1, id dict2) {
                                    NSDate *date1 = [(PFObject *)dict1 objectForKey:@"gameDate"];
                                    NSDate *date2 = [(PFObject *)dict2 objectForKey:@"gameDate"];
                                    return [date2 compare:date1];
                                }];
                            }
                            PFQuery *soccerScoreQuery = [PFQuery queryWithClassName:@"soccerScores"];
                            soccerScoreQuery.limit = 1000;
                            [soccerScoreQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                                numberOfScores += (float)(number);
                                [backgroundProgress setProgress:scoresProcessed/numberOfScores animated:YES];
                                [soccerScoreQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                    if (error) {
                                        UIAlertView *loadFeedError = [[UIAlertView alloc] initWithTitle:@"Error loading soccer scores" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                                        [loadFeedError show];
                                    } else {
                                        soccerGames = [[NSMutableArray alloc] init];
                                        for (PFObject *object in objects) {
                                            [soccerGames addObject:object];
                                            
                                            scoresProcessed++;
                                            [backgroundProgress setProgress:scoresProcessed/numberOfScores animated:YES];
                                        }
                                        [soccerGames sortUsingComparator:^NSComparisonResult(id dict1, id dict2) {
                                            NSDate *date1 = [(PFObject *)dict1 objectForKey:@"gameDate"];
                                            NSDate *date2 = [(PFObject *)dict2 objectForKey:@"gameDate"];
                                            return [date2 compare:date1];
                                        }];
                                    }
                                    self.navigationController.toolbarHidden = YES;
                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                    [self.refreshControl endRefreshing];
                                    [self.tableView reloadData];
                                    [self.tableView flashScrollIndicators];
                                    [refreshTimer invalidate];
                                    refreshTimer = nil;
                                    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh) userInfo:nil repeats:NO];
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];
    }];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Football";
    } else if (section == 1) {
        return @"Volleyball";
    } else if (section == 2) {
        return @"Basketball";
    } else if (section == 3) {
        return @"Soccer";
    } else if (section == 4) {
        return @"Wrestling";
    } else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(15, 0, 305, 23);
    label.backgroundColor = [UIColor colorWithWhite:77/255.0f alpha:1.0f];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor clearColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:15];
    label.text = [NSString stringWithFormat:@"  %@", sectionTitle];
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath {
    return 184;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return [footballGames count];
    } else if (section == 1) {
        return [volleyballGames count];
    } else if (section == 2) {
        return [basketballGames count];
    } else if (section == 3) {
        return [soccerGames count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        NSArray *nib;
        if (indexPath.section == 0) {
            nib = [[NSBundle mainBundle] loadNibNamed:@"Scoreboard_Football" owner:self options:nil];
        } else if (indexPath.section == 1) {
            nib = [[NSBundle mainBundle] loadNibNamed:@"Scoreboard_Volleyball_Varsity" owner:self options:nil];
        } else if (indexPath.section == 2) {
            nib = [[NSBundle mainBundle] loadNibNamed:@"Scoreboard_Basketball" owner:self options:nil];
        } else if (indexPath.section == 3) {
            nib = [[NSBundle mainBundle] loadNibNamed:@"Scoreboard_Soccer" owner:self options:nil];
        } else if (indexPath.section == 4) {
            nib = [[NSBundle mainBundle] loadNibNamed:@"Scoreboard_Wrestling" owner:self options:nil];
        } else {
            nib = nil;
        }
        cell = (UITableViewCell *)[nib objectAtIndex:0];
    }
    // Configure the cell...
    cell.backgroundView = nil;
    cell.backgroundColor = [UIColor blackColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        PFObject *object = [footballGames objectAtIndex:indexPath.row];
        
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        title.text = [NSString stringWithFormat:@"%@ %@", [object objectForKey:@"teamLevel"], [object objectForKey:@"sportName"]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        }
        [title sizeToFit];
        
        UILabel *videoDate = (UILabel *)[cell viewWithTag:2];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            videoDate.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        videoDate.text = [dateFormatter stringFromDate:[object objectForKey:@"gameDate"]];
        videoDate.backgroundColor = [UIColor blackColor];
        videoDate.textColor = [UIColor lightTextColor];
        [videoDate sizeToFit];
        
        UILabel *teams = (UILabel *)[cell viewWithTag:3];
        teams.text = [NSString stringWithFormat:@"%@ @ %@", [object objectForKey:@"awayTeam"], [object objectForKey:@"homeTeam"]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            teams.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        [teams sizeToFit];
        
        UIImageView *scoreBackground = (UIImageView *)[cell viewWithTag:4];
        scoreBackground.image = [UIImage imageNamed:@"ScoreboardPlaceholder"];
        
        UILabel *homeScore = (UILabel *)[cell viewWithTag:5];
        homeScore.text = [object objectForKey:@"homeScore"];
        homeScore.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [homeScore sizeToFit];
        
        UILabel *awayScore = (UILabel *)[cell viewWithTag:6];
        awayScore.text = [object objectForKey:@"awayScore"];
        awayScore.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [awayScore sizeToFit];
        
        UILabel *quarter = (UILabel *)[cell viewWithTag:7];
        if ([[object objectForKey:@"quarter"] isEqualToString:@"Game Over"]) {
            quarter.text = [object objectForKey:@"quarter"];
        } else {
            quarter.text = [NSString stringWithFormat:@"%@ Quarter", [object objectForKey:@"quarter"]];
        }
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            quarter.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        [quarter sizeToFit];
        
        NSDateFormatter *lastUpdatedFormatter = [[NSDateFormatter alloc] init];
        [lastUpdatedFormatter setDateStyle:NSDateFormatterShortStyle];
        [lastUpdatedFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        UILabel *lastUpdated = (UILabel *)[cell viewWithTag:8];
        lastUpdated.text = [NSString stringWithFormat:@"Last Updated: %@", [lastUpdatedFormatter stringFromDate:[object updatedAt]]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            lastUpdated.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        [lastUpdated sizeToFit];
    } else if (indexPath.section == 1) {
        PFObject *object = [volleyballGames objectAtIndex:indexPath.row];
        
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        title.text = [NSString stringWithFormat:@"%@ %@", [object objectForKey:@"teamLevel"], [object objectForKey:@"sportName"]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        }
        [title sizeToFit];
        
        UILabel *videoDate = (UILabel *)[cell viewWithTag:2];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            videoDate.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        videoDate.text = [dateFormatter stringFromDate:[object objectForKey:@"gameDate"]];
        videoDate.backgroundColor = [UIColor blackColor];
        videoDate.textColor = [UIColor lightTextColor];
        [videoDate sizeToFit];
        
        UILabel *teams = (UILabel *)[cell viewWithTag:3];
        teams.text = [NSString stringWithFormat:@"%@ @ %@", [object objectForKey:@"awayTeam"], [object objectForKey:@"homeTeam"]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            teams.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        [teams sizeToFit];
        
        UIImageView *scoreBackground1 = (UIImageView *)[cell viewWithTag:4];
        scoreBackground1.image = [UIImage imageNamed:@"ScoreboardPlaceholder"];
        
        UILabel *homeScore1 = (UILabel *)[cell viewWithTag:5];
        homeScore1.text = [object objectForKey:@"game1home"];
        homeScore1.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [homeScore1 sizeToFit];
        
        UILabel *awayScore1 = (UILabel *)[cell viewWithTag:6];
        awayScore1.text = [object objectForKey:@"game1away"];
        awayScore1.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [awayScore1 sizeToFit];
        
        UIImageView *scoreBackground2 = (UIImageView *)[cell viewWithTag:7];
        scoreBackground2.image = [UIImage imageNamed:@"ScoreboardPlaceholder"];
        
        UILabel *homeScore2 = (UILabel *)[cell viewWithTag:8];
        homeScore2.text = [object objectForKey:@"game2home"];
        homeScore2.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [homeScore2 sizeToFit];
        
        UILabel *awayScore2 = (UILabel *)[cell viewWithTag:9];
        awayScore2.text = [object objectForKey:@"game2away"];
        awayScore2.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [awayScore2 sizeToFit];
        
        UIImageView *scoreBackground3 = (UIImageView *)[cell viewWithTag:10];
        scoreBackground3.image = [UIImage imageNamed:@"ScoreboardPlaceholder"];
        
        UILabel *homeScore3 = (UILabel *)[cell viewWithTag:11];
        homeScore3.text = [object objectForKey:@"game3home"];
        homeScore3.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [homeScore3 sizeToFit];
        
        UILabel *awayScore3 = (UILabel *)[cell viewWithTag:12];
        awayScore3.text = [object objectForKey:@"game3away"];
        awayScore3.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [awayScore3 sizeToFit];
        
        UIImageView *scoreBackground4 = (UIImageView *)[cell viewWithTag:13];
        scoreBackground4.image = [UIImage imageNamed:@"ScoreboardPlaceholder"];
        
        UILabel *homeScore4 = (UILabel *)[cell viewWithTag:14];
        homeScore4.text = [object objectForKey:@"game4home"];
        homeScore4.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [homeScore4 sizeToFit];
        
        UILabel *awayScore4 = (UILabel *)[cell viewWithTag:15];
        awayScore4.text = [object objectForKey:@"game4away"];
        awayScore4.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [awayScore4 sizeToFit];
        
        UIImageView *scoreBackground5 = (UIImageView *)[cell viewWithTag:16];
        scoreBackground5.image = [UIImage imageNamed:@"ScoreboardPlaceholder"];
        
        UILabel *homeScore5 = (UILabel *)[cell viewWithTag:17];
        homeScore5.text = [object objectForKey:@"game5home"];
        homeScore5.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [homeScore5 sizeToFit];
        
        UILabel *awayScore5 = (UILabel *)[cell viewWithTag:18];
        awayScore5.text = [object objectForKey:@"game5away"];
        awayScore5.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [awayScore5 sizeToFit];
        
        NSDateFormatter *lastUpdatedFormatter = [[NSDateFormatter alloc] init];
        [lastUpdatedFormatter setDateStyle:NSDateFormatterShortStyle];
        [lastUpdatedFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        UILabel *lastUpdated = (UILabel *)[cell viewWithTag:19];
        lastUpdated.text = [NSString stringWithFormat:@"Last Updated: %@", [lastUpdatedFormatter stringFromDate:[object updatedAt]]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            lastUpdated.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        [lastUpdated sizeToFit];
    } else if (indexPath.section == 2) {
        PFObject *object = [basketballGames objectAtIndex:indexPath.row];
        
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        title.text = [NSString stringWithFormat:@"%@ %@", [object objectForKey:@"teamLevel"], [object objectForKey:@"sportName"]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        }
        [title sizeToFit];
        
        UILabel *videoDate = (UILabel *)[cell viewWithTag:2];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            videoDate.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        videoDate.text = [dateFormatter stringFromDate:[object objectForKey:@"gameDate"]];
        videoDate.backgroundColor = [UIColor blackColor];
        videoDate.textColor = [UIColor lightTextColor];
        [videoDate sizeToFit];
        
        UILabel *teams = (UILabel *)[cell viewWithTag:3];
        teams.text = [NSString stringWithFormat:@"%@ @ %@", [object objectForKey:@"awayTeam"], [object objectForKey:@"homeTeam"]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            teams.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        [teams sizeToFit];
        
        UIImageView *scoreBackground = (UIImageView *)[cell viewWithTag:4];
        scoreBackground.image = [UIImage imageNamed:@"ScoreboardPlaceholder"];
        
        UILabel *homeScore = (UILabel *)[cell viewWithTag:5];
        homeScore.text = [object objectForKey:@"homeScore"];
        homeScore.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [homeScore sizeToFit];
        
        UILabel *awayScore = (UILabel *)[cell viewWithTag:6];
        awayScore.text = [object objectForKey:@"awayScore"];
        awayScore.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [awayScore sizeToFit];
        
        UILabel *quarter = (UILabel *)[cell viewWithTag:7];
        if ([[object objectForKey:@"quarter"] isEqualToString:@"Game Over"]) {
            quarter.text = [object objectForKey:@"quarter"];
        } else {
            quarter.text = [NSString stringWithFormat:@"%@ Quarter", [object objectForKey:@"quarter"]];
        }
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            quarter.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        [quarter sizeToFit];
        
        NSDateFormatter *lastUpdatedFormatter = [[NSDateFormatter alloc] init];
        [lastUpdatedFormatter setDateStyle:NSDateFormatterShortStyle];
        [lastUpdatedFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        UILabel *lastUpdated = (UILabel *)[cell viewWithTag:8];
        lastUpdated.text = [NSString stringWithFormat:@"Last Updated: %@", [lastUpdatedFormatter stringFromDate:[object updatedAt]]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            lastUpdated.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        [lastUpdated sizeToFit];
    } else if (indexPath.section == 3) {
        PFObject *object = [soccerGames objectAtIndex:indexPath.row];
        
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        title.text = [NSString stringWithFormat:@"%@ %@", [object objectForKey:@"teamLevel"], [object objectForKey:@"sportName"]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        }
        [title sizeToFit];
        
        UILabel *videoDate = (UILabel *)[cell viewWithTag:2];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            videoDate.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        videoDate.text = [dateFormatter stringFromDate:[object objectForKey:@"gameDate"]];
        videoDate.backgroundColor = [UIColor blackColor];
        videoDate.textColor = [UIColor lightTextColor];
        [videoDate sizeToFit];
        
        UILabel *teams = (UILabel *)[cell viewWithTag:3];
        teams.text = [NSString stringWithFormat:@"%@ @ %@", [object objectForKey:@"awayTeam"], [object objectForKey:@"homeTeam"]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            teams.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        [teams sizeToFit];
        
        UIImageView *scoreBackground = (UIImageView *)[cell viewWithTag:4];
        scoreBackground.image = [UIImage imageNamed:@"ScoreboardPlaceholder"];
        
        UILabel *homeScore = (UILabel *)[cell viewWithTag:5];
        homeScore.text = [object objectForKey:@"homeScore"];
        homeScore.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [homeScore sizeToFit];
        
        UILabel *awayScore = (UILabel *)[cell viewWithTag:6];
        awayScore.text = [object objectForKey:@"awayScore"];
        awayScore.font = [UIFont fontWithName:@"DS-Digital-Bold" size:25.0f];
        // [awayScore sizeToFit];
        
        UILabel *quarter = (UILabel *)[cell viewWithTag:7];
        if ([[object objectForKey:@"half"] isEqualToString:@"Game Over"]) {
            quarter.text = [object objectForKey:@"half"];
        } else {
            quarter.text = [NSString stringWithFormat:@"%@ Half", [object objectForKey:@"half"]];
        }
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            quarter.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        [quarter sizeToFit];
        
        NSDateFormatter *lastUpdatedFormatter = [[NSDateFormatter alloc] init];
        [lastUpdatedFormatter setDateStyle:NSDateFormatterShortStyle];
        [lastUpdatedFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        UILabel *lastUpdated = (UILabel *)[cell viewWithTag:8];
        lastUpdated.text = [NSString stringWithFormat:@"Last Updated: %@", [lastUpdatedFormatter stringFromDate:[object updatedAt]]];
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            lastUpdated.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        }
        [lastUpdated sizeToFit];
    }
    
    return cell;
}

- (IBAction)resetTimer:(id)sender {
    // [refreshTimer invalidate];
    [self refresh];
}

- (void)dealloc {
    [refreshTimer invalidate];
    refreshTimer = nil;
}

@end