//
//  PSBNTheaterList.m
//  PSBN
//
//  Created by Victor Ilisei on 3/20/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNTheaterList.h"

@interface PSBNTheaterList ()

@end

@implementation PSBNTheaterList

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Theater";
        self.tabBarItem.image = [UIImage imageNamed:@"theater"];
        
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
    
    // iOS 7 Slide to go back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    // Setup refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // Setup tableview color
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    
    /*
    PFObject *object = [PFObject objectWithClassName:@"softballScores"];
    object[@"homeTeam"] = @"Kellis";
    object[@"awayTeam"] = @"Peoria";
    object[@"gameDate"] = [NSDate date];
    
    object[@"home1"] = @0;
    object[@"home2"] = @0;
    object[@"home3"] = @0;
    object[@"home4"] = @0;
    object[@"home5"] = @0;
    object[@"home6"] = @0;
    object[@"home7"] = @0;
    object[@"home8"] = @0;
    object[@"home9"] = @0;
    
    object[@"away1"] = @0;
    object[@"away2"] = @0;
    object[@"away3"] = @0;
    object[@"away4"] = @0;
    object[@"away5"] = @0;
    object[@"away6"] = @0;
    object[@"away7"] = @0;
    object[@"away8"] = @0;
    object[@"away9"] = @0;
    
    object[@"homeR"] = @0;
    object[@"homeH"] = @0;
    object[@"homeE"] = @0;
    object[@"homeOverall"] = @0;
    
    object[@"awayR"] = @0;
    object[@"awayH"] = @0;
    object[@"awayE"] = @0;
    object[@"awayOverall"] = @0;
    
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Saved");
        } else {
            NSLog(@"Error %@", error.localizedDescription);
        }
    }];
     */
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.toolbarHidden = YES;
}

- (void)refresh {
    [self.refreshControl beginRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Checking if any events are live..."];
    PFQuery *livestreamQuery = [PFQuery queryWithClassName:@"livestreamAvailable"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cache_reset"]) {
        [livestreamQuery clearCachedResult];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cache_disable"]) {
        livestreamQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    } else {
        livestreamQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    [livestreamQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            if ([[object objectForKey:@"liveBool"] boolValue]) {
                self.tabBarItem.badgeValue = @"";
            } else {
                self.tabBarItem.badgeValue = nil;
            }
            customPlayerReloadInterval = [[object objectForKey:@"customPlayerUpdateInterval"] doubleValue];
        }
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Downloading event %.f of %.f (%.f%%)", videosProcessed, numberOfVideos, (videosProcessed/numberOfVideos)*100]];
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"eventList"];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cache_reset"]) {
            [eventQuery clearCachedResult];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cache_disable"]) {
            eventQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
        } else {
            eventQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        }
        eventQuery.limit = 1000;
        [eventQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                numberOfVideos += (float)(number);
                self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Downloading event %.f of %.f (%.f%%)", videosProcessed, numberOfVideos, (videosProcessed/numberOfVideos)*100]];
            }
            [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    feedContent = [[NSMutableArray alloc] init];
                    [self.tableView reloadData];
                    NSMutableArray *section1 = [[NSMutableArray alloc] init];
                    for (PFObject *object in objects) {
                        [section1 addObject:object];
                        
                        videosProcessed++;
                        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Downloading event %.f of %.f (%.f%%)", videosProcessed, numberOfVideos, (videosProcessed/numberOfVideos)*100]];
                    }
                    [section1 sortUsingComparator:^NSComparisonResult(id dict1, id dict2) {
                        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Sorting events latest to earliest..."];
                        NSDate *date1 = [(PFObject *)dict1 objectForKey:@"filmedOn"];
                        NSDate *date2 = [(PFObject *)dict2 objectForKey:@"filmedOn"];
                        return [date2 compare:date1];
                    }];
                    [feedContent addObject:section1];
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"improve_enabled"]) {
                        [self improve];
                    }
                    [self.refreshControl endRefreshing];
                    videosProcessed = 0.0f;
                    numberOfVideos = 0.0f;
                    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
                    [self.tableView reloadData];
                }
            }];
        }];
    }];
}

- (void)improve {
    for (NSMutableArray *section in feedContent) {
        for (PFObject *object in section) {
            // Posters
            NSURL *eventPageURL = [NSURL URLWithString:[object objectForKey:@"eventPage"]];
            // Poster iPad Retina
            if ([object objectForKey:@"posterURLretina"] == nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSError *error;
                    NSString *sourceCode = [NSString stringWithContentsOfURL:eventPageURL encoding:NSUTF8StringEncoding error:&error];
                    if (!error) {
                        NSArray *components = [sourceCode componentsSeparatedByString:@"\""];
                        
                        if ([components containsObject:@"geo_restriction"]) {
                            int index = (int)([components indexOfObject:@"geo_restriction"]);
                            NSString *posterIpadRetinaURLretrieved = [components objectAtIndex:index-8];
                            NSString *posterIpadRetinaURLretrievedNoEXT = [posterIpadRetinaURLretrieved stringByDeletingPathExtension];
                            NSString *posterIpadRetinaURLretrievedNoEXTcorrectSize = [posterIpadRetinaURLretrievedNoEXT stringByReplacingOccurrencesOfString:@"170x255" withString:@"400x600"];
                            NSString *posterIpadRetinaURLretrievedCorrectSize = [posterIpadRetinaURLretrievedNoEXTcorrectSize stringByAppendingPathExtension:[posterIpadRetinaURLretrieved pathExtension]];
                            [object setObject:posterIpadRetinaURLretrievedCorrectSize forKey:@"posterURLretina"];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                                    [object saveEventually];
                                }
                            }];
                        }
                    }
                });
            }
            
            // Poster iPad
            if ([object objectForKey:@"posterURL"] == nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSError *error;
                    NSString *sourceCode = [NSString stringWithContentsOfURL:eventPageURL encoding:NSUTF8StringEncoding error:&error];
                    if (!error) {
                        NSArray *components = [sourceCode componentsSeparatedByString:@"\""];
                        
                        if ([components containsObject:@"geo_restriction"]) {
                            int index = (int)([components indexOfObject:@"geo_restriction"]);
                            NSString *posterIpadRetinaURLretrieved = [components objectAtIndex:index-8];
                            NSString *posterIpadRetinaURLretrievedNoEXT = [posterIpadRetinaURLretrieved stringByDeletingPathExtension];
                            NSString *posterIpadRetinaURLretrievedNoEXTcorrectSize = [posterIpadRetinaURLretrievedNoEXT stringByReplacingOccurrencesOfString:@"170x255" withString:@"200x300"];
                            NSString *posterIpadRetinaURLretrievedCorrectSize = [posterIpadRetinaURLretrievedNoEXTcorrectSize stringByAppendingPathExtension:[posterIpadRetinaURLretrieved pathExtension]];
                            [object setObject:posterIpadRetinaURLretrievedCorrectSize forKey:@"posterURL"];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                                    [object saveEventually];
                                }
                            }];
                        }
                    }
                });
            }
            
            // Poster iPhone Retina
            if ([object objectForKey:@"posterURLretina_iPhone"] == nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSError *error;
                    NSString *sourceCode = [NSString stringWithContentsOfURL:eventPageURL encoding:NSUTF8StringEncoding error:&error];
                    if (!error) {
                        NSArray *components = [sourceCode componentsSeparatedByString:@"\""];
                        
                        if ([components containsObject:@"geo_restriction"]) {
                            int index = (int)([components indexOfObject:@"geo_restriction"]);
                            NSString *posterIpadRetinaURLretrieved = [components objectAtIndex:index-8];
                            NSString *posterIpadRetinaURLretrievedNoEXT = [posterIpadRetinaURLretrieved stringByDeletingPathExtension];
                            NSString *posterIpadRetinaURLretrievedNoEXTcorrectSize = [posterIpadRetinaURLretrievedNoEXT stringByReplacingOccurrencesOfString:@"170x255" withString:@"133x200"];
                            NSString *posterIpadRetinaURLretrievedCorrectSize = [posterIpadRetinaURLretrievedNoEXTcorrectSize stringByAppendingPathExtension:[posterIpadRetinaURLretrieved pathExtension]];
                            [object setObject:posterIpadRetinaURLretrievedCorrectSize forKey:@"posterURLretina_iPhone"];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                                    [object saveEventually];
                                }
                            }];
                        }
                    }
                });
            }
            
            // Poster iPhone
            if ([object objectForKey:@"posterURL_iPhone"] == nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSError *error;
                    NSString *sourceCode = [NSString stringWithContentsOfURL:eventPageURL encoding:NSUTF8StringEncoding error:&error];
                    if (!error) {
                        NSArray *components = [sourceCode componentsSeparatedByString:@"\""];
                        
                        if ([components containsObject:@"geo_restriction"]) {
                            int index = (int)([components indexOfObject:@"geo_restriction"]);
                            NSString *posterIpadRetinaURLretrieved = [components objectAtIndex:index-8];
                            NSString *posterIpadRetinaURLretrievedNoEXT = [posterIpadRetinaURLretrieved stringByDeletingPathExtension];
                            NSString *posterIpadRetinaURLretrievedNoEXTcorrectSize = [posterIpadRetinaURLretrievedNoEXT stringByReplacingOccurrencesOfString:@"170x255" withString:@"67x100"];
                            NSString *posterIpadRetinaURLretrievedCorrectSize = [posterIpadRetinaURLretrievedNoEXTcorrectSize stringByAppendingPathExtension:[posterIpadRetinaURLretrieved pathExtension]];
                            [object setObject:posterIpadRetinaURLretrievedCorrectSize forKey:@"posterURL_iPhone"];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                                    [object saveEventually];
                                }
                            }];
                        }
                    }
                });
            }
            
            if ([[object objectForKey:@"fallbackPlayer"] rangeOfString:@"iframe"].location != NSNotFound) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSString *originalString = [object objectForKey:@"fallbackPlayer"];
                    
                    NSString *edit1 = [originalString stringByReplacingOccurrencesOfString:@"<iframe src=\"" withString:@""];
                    NSString *edit2 = [edit1 stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
                    NSString *edit3 = [edit2 stringByReplacingOccurrencesOfString:@"autoPlay=false" withString:@"autoPlay=true"];
                    NSString *edit4 = [edit3 stringByReplacingOccurrencesOfString:@"\" width=\"640\" height=\"360\" frameborder=\"0\" scrolling=\"no\"></iframe>" withString:@""];
                    NSString *edit5 = [edit4 stringByReplacingOccurrencesOfString:@"\" width=\"640\" height=\"360\" frameborder=\"0\" scrolling=\"no\"> </iframe>" withString:@""];
                    NSString *edit6 = [edit5 stringByReplacingOccurrencesOfString:@"?width=640&" withString:@"?"];
                    NSString *edit7 = [edit6 stringByReplacingOccurrencesOfString:@"&width=640&" withString:@"&"];
                    NSString *edit8 = [edit7 stringByReplacingOccurrencesOfString:@"&width=640" withString:@""];
                    NSString *edit9 = [edit8 stringByReplacingOccurrencesOfString:@"?height=360&" withString:@"?"];
                    NSString *edit10 = [edit9 stringByReplacingOccurrencesOfString:@"&height=360&" withString:@"&"];
                    NSString *edit11 = [edit10 stringByReplacingOccurrencesOfString:@"&height=360" withString:@""];
                    
                    [object setObject:edit11 forKey:@"fallbackPlayer"];
                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (error) {
                            NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                            [object saveEventually];
                        }
                    }];
                });
            }
            
            if ([[object updatedAt] timeIntervalSinceNow] < customPlayerReloadInterval || [object objectForKey:@"customPlayer"] == nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    // Auto-crop iframe url if existant
                    NSURL *url = [NSURL URLWithString:[object objectForKey:@"fallbackPlayer"]];
                    NSError *error;
                    NSString *sourceCode = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
                    
                    if (!error) {
                        // Custom Player Video URL
                        NSArray *components = [sourceCode componentsSeparatedByString:@"\""];
                        
                        // Update views
                        if ([components containsObject:@"views"]) {
                            int index = (int)([components indexOfObject:@"views"]);
                            int views = [[[[components objectAtIndex:index+1] stringByReplacingOccurrencesOfString:@":" withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""] intValue];
                            int lastViews = [[object objectForKey:@"views"] intValue];
                            [object incrementKey:@"views" byAmount:[NSNumber numberWithInt:views-lastViews]];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                                    [object saveEventually];
                                }
                            }];
                        }
                        // Update custom player
                        if ([components containsObject:@"secure_m3u8_url"]) {
                            int index = (int)([components indexOfObject:@"secure_m3u8_url"]);
                            NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                            [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                                    [object saveEventually];
                                }
                            }];
                        } else if ([components containsObject:@"m3u8_url"]) {
                            int index = (int)([components indexOfObject:@"m3u8_url"]);
                            NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                            [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                                    [object saveEventually];
                                }
                            }];
                        } else if ([components containsObject:@"secure_progressive_url_hd"]) {
                            int index = (int)([components indexOfObject:@"secure_progressive_url_hd"]);
                            NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                            [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                                    [object saveEventually];
                                }
                            }];
                        } else if ([components containsObject:@"progressive_url_hd"]) {
                            int index = (int)([components indexOfObject:@"progressive_url_hd"]);
                            NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                            [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                                    [object saveEventually];
                                }
                            }];
                        } else if ([components containsObject:@"secure_progressive_url"]) {
                            int index = (int)([components indexOfObject:@"secure_progressive_url"]);
                            NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                            [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                                    [object saveEventually];
                                }
                            }];
                        } else if ([components containsObject:@"progressive_url"]) {
                            int index = (int)([components indexOfObject:@"progressive_url"]);
                            NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                            [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (error) {
                                    NSLog(@"error (%@) trying to improve %@. We will automatically try improving this event at a later time.", error.localizedDescription, [object objectForKey:@"title"]);
                                    [object saveEventually];
                                }
                            }];
                        }
                    }
                });
            }
        }
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // return 300-(300/3);
        return 300;
    } else {
        // return 100-(100/3);
        return 100;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [feedContent count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[feedContent objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.frame];
    selectedView.backgroundColor = [UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f];
    cell.selectedBackgroundView = selectedView;
    
    PFObject *object = [[feedContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
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
        } else {
            // Load image error
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                cell.imageView.image = [UIImage imageNamed:@"errorLoading"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"errorLoading_iPhone"];
            }
        }
        [cell setNeedsLayout];
    }];
    
    cell.textLabel.text = [object objectForKey:@"title"];
    cell.textLabel.numberOfLines = 3;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:[object objectForKey:@"filmedOn"]];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:100/255.0f green:0.0f blue:0.0f alpha:1.0f];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *object = [[feedContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [[NSUserDefaults standardUserDefaults] setObject:[object objectId] forKey:@"videoChosen"];
    
    PSBNTheaterPlayer *player = [[PSBNTheaterPlayer alloc] init];
    player.title = [object objectForKey:@"title"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController pushViewController:player animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

@end