//
//  PSBNTheaterList.m
//  PSBN
//
//  Created by Victor Ilisei on 12/17/13.
//  Copyright (c) 2013 Tech Genius. All rights reserved.
//

#import "PSBNTheaterList.h"

#import "PSBNTheaterPlayer.h"

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

- (BOOL)shouldAutorotate {
    return YES;
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
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    // Setup tableview color
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.toolbarHidden = YES;
}

- (void)refresh {
    [self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    PFQuery *livestreamQuery = [PFQuery queryWithClassName:@"livestreamAvailable"];
    [livestreamQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            UIAlertView *errorLoadingLive = [[UIAlertView alloc] initWithTitle:@"Error checking if live" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [errorLoadingLive show];
        } else {
            if ([[object objectForKey:@"liveBool"] boolValue]) {
                self.tabBarItem.badgeValue = @"";
            } else {
                self.tabBarItem.badgeValue = nil;
            }
            customPlayerReloadInterval = [[object objectForKey:@"customPlayerUpdateInterval"] doubleValue];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"improve_enabled"]) {
            self.navigationController.toolbarHidden = NO;
            self.navigationController.toolbar.barStyle = UIBarStyleBlack;
            self.navigationController.toolbar.translucent = YES;
            // self.hidesBottomBarWhenPushed = YES;
            
            backgroundProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, self.navigationController.toolbar.frame.size.height/2-3, self.navigationController.toolbar.frame.size.width-20, 6)];
            backgroundProgress.progress = 0.0f;
            backgroundProgress.progressTintColor = [UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f];
            backgroundProgress.trackTintColor = [UIColor blackColor];
            [self.navigationController.toolbar addSubview:backgroundProgress];
            
            PFQuery *improveQuery = [PFQuery queryWithClassName:@"eventList"];
            improveQuery.limit = 1000;
            numberOfVideos = 0.0f;
            videosProcessed = 0.0f;
            
            [improveQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                if (error) {
                    self.navigationController.toolbarHidden = YES;
                } else {
                    numberOfVideos += (float)(number);
                    numberOfVideos += (float)(number);
                }
                [improveQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        for (PFObject *object in objects) {
                            NSURL *customPlayerURL = [NSURL URLWithString:[object objectForKey:@"customPlayer"]];
                            NSURL *eventPageURL = [NSURL URLWithString:[object objectForKey:@"eventPage"]];
                            
                            if ([[object objectForKey:@"fallbackPlayer"] rangeOfString:@"iframe"].location != NSNotFound) {
                                [object setObject:[[[[[[[object objectForKey:@"fallbackPlayer"] stringByReplacingOccurrencesOfString:@"<iframe src=\"" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"] stringByReplacingOccurrencesOfString:@"autoPlay=false" withString:@"autoPlay=true"] stringByReplacingOccurrencesOfString:@"\" width=\"640\" height=\"360\" frameborder=\"0\" scrolling=\"no\"></iframe>" withString:@""] stringByReplacingOccurrencesOfString:@"\" width=\"640\" height=\"360\" frameborder=\"0\" scrolling=\"no\"> </iframe>" withString:@""] stringByReplacingOccurrencesOfString:@"width=640&height=360&" withString:@""] forKey:@"fallbackPlayer"];
                            }
                            
                            if ([[object updatedAt] timeIntervalSinceNow] < customPlayerReloadInterval || [customPlayerURL.absoluteString isEqualToString:@"(undefined)"] || [customPlayerURL.absoluteString isEqualToString:@""]) {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                    NSURL *url = [NSURL URLWithString:[object objectForKey:@"fallbackPlayer"]];
                                    NSError *error;
                                    NSString *sourceCode = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
                                    
                                    if (error) {
                                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                            [errorAlert show];
                                        });
                                    } else {
                                        // Custom Player Video URL
                                        NSArray *components = [sourceCode componentsSeparatedByString:@"\""];
                                        
                                        if ([components containsObject:@"views"]) {
                                            int index = (int)([components indexOfObject:@"views"]);
                                            NSString *viewsRetrieved = [[[components objectAtIndex:index+1] stringByReplacingOccurrencesOfString:@":" withString:@""] stringByReplacingOccurrencesOfString:@", " withString:@""];
                                            [object setObject:viewsRetrieved forKey:@"views"];
                                            [object saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
                                                if ([components containsObject:@"secure_m3u8_url"]) {
                                                    int index = (int)([components indexOfObject:@"secure_m3u8_url"]);
                                                    NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                                                    [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                                                    [object saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
                                                        videosProcessed++;
                                                        [backgroundProgress setProgress:videosProcessed/numberOfVideos animated:YES];
                                                        if (videosProcessed == numberOfVideos) {
                                                            self.navigationController.toolbarHidden = YES;
                                                        }
                                                    }];
                                                } else if ([components containsObject:@"m3u8_url"]) {
                                                    int index = (int)([components indexOfObject:@"m3u8_url"]);
                                                    NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                                                    [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                                                    [object saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
                                                        videosProcessed++;
                                                        [backgroundProgress setProgress:videosProcessed/numberOfVideos animated:YES];
                                                        if (videosProcessed == numberOfVideos) {
                                                            self.navigationController.toolbarHidden = YES;
                                                        }
                                                    }];
                                                } else if ([components containsObject:@"progressive_url_hd"]) {
                                                    int index = (int)([components indexOfObject:@"progressive_url_hd"]);
                                                    NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                                                    [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                                                    [object saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
                                                        videosProcessed++;
                                                        [backgroundProgress setProgress:videosProcessed/numberOfVideos animated:YES];
                                                        if (videosProcessed == numberOfVideos) {
                                                            self.navigationController.toolbarHidden = YES;
                                                        }
                                                    }];
                                                } else if ([components containsObject:@"progressive_url"]) {
                                                    int index = (int)([components indexOfObject:@"progressive_url"]);
                                                    NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                                                    [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                                                    [object saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
                                                        videosProcessed++;
                                                        [backgroundProgress setProgress:videosProcessed/numberOfVideos animated:YES];
                                                        if (videosProcessed == numberOfVideos) {
                                                            self.navigationController.toolbarHidden = YES;
                                                        }
                                                    }];
                                                }
                                            }];
                                        }
                                    }
                                });
                            } else {
                                videosProcessed++;
                                [backgroundProgress setProgress:videosProcessed/numberOfVideos animated:YES];
                                if (videosProcessed == numberOfVideos) {
                                    self.navigationController.toolbarHidden = YES;
                                }
                            }
                            // Poster iPad Retina
                            NSURL *posterIpadRetina = [NSURL URLWithString:[object objectForKey:@"posterURLretina"]];
                            
                            if (posterIpadRetina.baseURL == nil) {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                    NSError *error;
                                    NSString *sourceCode = [NSString stringWithContentsOfURL:eventPageURL encoding:NSUTF8StringEncoding error:&error];
                                    if (error) {
                                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                            [errorAlert show];
                                        });
                                    } else {
                                        NSArray *components = [sourceCode componentsSeparatedByString:@"\""];
                                        if ([components containsObject:@"geo_restriction"]) {
                                            int index = (int)([components indexOfObject:@"geo_restriction"]);
                                            NSString *posterIpadRetinaURLretrieved = [components objectAtIndex:index-8];
                                            NSString *posterIpadRetinaURLretrievedNoEXT = [posterIpadRetinaURLretrieved stringByDeletingPathExtension];
                                            NSString *posterIpadRetinaURLretrievedNoEXTcorrectSize = [posterIpadRetinaURLretrievedNoEXT stringByReplacingOccurrencesOfString:@"170x255" withString:@"400x600"];
                                            NSString *posterIpadRetinaURLretrievedCorrectSize = [posterIpadRetinaURLretrievedNoEXTcorrectSize stringByAppendingPathExtension:[posterIpadRetinaURLretrieved pathExtension]];
                                            [object setObject:posterIpadRetinaURLretrievedCorrectSize forKey:@"posterURLretina"];
                                            [object saveInBackground];
                                        }
                                    }
                                });
                            }
                            
                            // Poster iPad
                            NSURL *posterIpad = [NSURL URLWithString:[object objectForKey:@"posterURL"]];
                            
                            if (posterIpad.baseURL == nil) {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                    NSError *error;
                                    NSString *sourceCode = [NSString stringWithContentsOfURL:eventPageURL encoding:NSUTF8StringEncoding error:&error];
                                    if (error) {
                                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                            [errorAlert show];
                                        });
                                    } else {
                                        NSArray *components = [sourceCode componentsSeparatedByString:@"\""];
                                        if ([components containsObject:@"geo_restriction"]) {
                                            int index = (int)([components indexOfObject:@"geo_restriction"]);
                                            NSString *posterIpadURLretrieved = [components objectAtIndex:index-8];
                                            NSString *posterIpadURLretrievedNoEXT = [posterIpadURLretrieved stringByDeletingPathExtension];
                                            NSString *posterIpadURLretrievedNoEXTcorrectSize = [posterIpadURLretrievedNoEXT stringByReplacingOccurrencesOfString:@"170x255" withString:@"200x300"];
                                            NSString *posterIpadURLretrievedCorrectSize = [posterIpadURLretrievedNoEXTcorrectSize stringByAppendingPathExtension:[posterIpadURLretrieved pathExtension]];
                                            [object setObject:posterIpadURLretrievedCorrectSize forKey:@"posterURL"];
                                            [object saveInBackground];
                                        }
                                    }
                                });
                            }
                            
                            // Poster iPhone Retina
                            NSURL *posterIphoneRetina = [NSURL URLWithString:[object objectForKey:@"posterURLretina_iPhone"]];
                            
                            if (posterIphoneRetina.baseURL == nil) {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                    NSError *error;
                                    NSString *sourceCode = [NSString stringWithContentsOfURL:eventPageURL encoding:NSUTF8StringEncoding error:&error];
                                    if (error) {
                                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                            [errorAlert show];
                                        });
                                    } else {
                                        NSArray *components = [sourceCode componentsSeparatedByString:@"\""];
                                        if ([components containsObject:@"geo_restriction"]) {
                                            int index = (int)([components indexOfObject:@"geo_restriction"]);
                                            NSString *posterIphoneRetinaURLretrieved = [components objectAtIndex:index-8];
                                            NSString *posterIphoneRetinaURLretrievedNoEXT = [posterIphoneRetinaURLretrieved stringByDeletingPathExtension];
                                            NSString *posterIphoneRetinaURLretrievedNoEXTcorrectSize = [posterIphoneRetinaURLretrievedNoEXT stringByReplacingOccurrencesOfString:@"170x255" withString:@"133x200"];
                                            NSString *posterIphoneRetinaURLretrievedCorrectSize = [posterIphoneRetinaURLretrievedNoEXTcorrectSize stringByAppendingPathExtension:[posterIphoneRetinaURLretrieved pathExtension]];
                                            [object setObject:posterIphoneRetinaURLretrievedCorrectSize forKey:@"posterURLretina_iPhone"];
                                            [object saveInBackground];
                                        }
                                    }
                                });
                            }
                            
                            // Poster iPhone
                            NSURL *posterIphone = [NSURL URLWithString:[object objectForKey:@"posterURL_iPhone"]];
                            
                            if (posterIphone.baseURL == nil) {
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                    NSError *error;
                                    NSString *sourceCode = [NSString stringWithContentsOfURL:eventPageURL encoding:NSUTF8StringEncoding error:&error];
                                    if (error) {
                                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:error.localizedDescription message:error.localizedFailureReason delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                            [errorAlert show];
                                        });
                                    } else {
                                        NSArray *components = [sourceCode componentsSeparatedByString:@"\""];
                                        if ([components containsObject:@"geo_restriction"]) {
                                            int index = (int)([components indexOfObject:@"geo_restriction"]);
                                            NSString *posterIphoneURLretrieved = [components objectAtIndex:index-8];
                                            NSString *posterIphoneURLretrievedNoEXT = [posterIphoneURLretrieved stringByDeletingPathExtension];
                                            NSString *posterIphoneURLretrievedNoEXTcorrectSize = [posterIphoneURLretrievedNoEXT stringByReplacingOccurrencesOfString:@"170x255" withString:@"67x100"];
                                            NSString *posterIphoneURLretrievedCorrectSize = [posterIphoneURLretrievedNoEXTcorrectSize stringByAppendingPathExtension:[posterIphoneURLretrieved pathExtension]];
                                            [object setObject:posterIphoneURLretrievedCorrectSize forKey:@"posterURL_iPhone"];
                                            [object saveInBackground];
                                        }
                                    }
                                });
                            }
                        }
                    }
                    
                    PFQuery *postQuery = [PFQuery queryWithClassName:@"eventList"];
                    postQuery.limit = 1000;
                    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (error) {
                            UIAlertView *loadFeedError = [[UIAlertView alloc] initWithTitle:@"Error loading feed" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                            [loadFeedError show];
                        } else {
                            // Load events
                            feedContent = [[NSMutableArray alloc] init];
                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                            for (PFObject *object in objects) {
                                [feedContent addObject:object];
                                
                                videosProcessed++;
                                [backgroundProgress setProgress:videosProcessed/numberOfVideos animated:YES];
                                if (videosProcessed == numberOfVideos) {
                                    self.navigationController.toolbarHidden = YES;
                                }
                            }
                            [feedContent sortUsingComparator:^NSComparisonResult(id dict1, id dict2) {
                                NSDate *date1 = [(PFObject *)dict1 objectForKey:@"filmedOn"];
                                NSDate *date2 = [(PFObject *)dict2 objectForKey:@"filmedOn"];
                                return [date2 compare:date1];
                            }];
                        }
                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        [self.tableView reloadData];
                        [self.refreshControl endRefreshing];
                        [self.tableView flashScrollIndicators];
                    }];
                }];
            }];
        } else {
            PFQuery *postQuery = [PFQuery queryWithClassName:@"eventList"];
            postQuery.limit = 1000;
            [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    UIAlertView *loadFeedError = [[UIAlertView alloc] initWithTitle:@"Error loading feed" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [loadFeedError show];
                } else {
                    // Load events
                    feedContent = [[NSMutableArray alloc] init];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    for (PFObject *object in objects) {
                        [feedContent addObject:object];
                    }
                    [feedContent sortUsingComparator:^NSComparisonResult(id dict1, id dict2) {
                        NSDate *date1 = [(PFObject *)dict1 objectForKey:@"filmedOn"];
                        NSDate *date2 = [(PFObject *)dict2 objectForKey:@"filmedOn"];
                        return [date2 compare:date1];
                    }];
                }
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
                [self.tableView flashScrollIndicators];
            }];
        }
    }];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (animated) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        if (animated) {
            [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [feedContent count];
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
    
    PFObject *object = [feedContent objectAtIndex:indexPath.row];
    
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
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    url = nil;
    
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
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                UIToolbar *blur = [[UIToolbar alloc] initWithFrame:CGRectMake(15, 300-(300/3), 200, 300/3)];
                blur.barStyle = UIBarStyleBlack;
                blur.barTintColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
                blur.tintColor = [UIColor whiteColor];
                blur.translucent = YES;
                UIBarButtonItem *views = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"▶ %@", [object objectForKey:@"views"]] style:UIBarButtonItemStylePlain target:self action:nil];
                views.enabled = YES;
                blur.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], views, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]];
                [cell addSubview:blur];
            } else {
                UIToolbar *blur = [[UIToolbar alloc] initWithFrame:CGRectMake(15, 100-(100/3), 66, 100/3)];
                blur.barStyle = UIBarStyleBlack;
                blur.barTintColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
                blur.tintColor = [UIColor whiteColor];
                blur.translucent = YES;
                UIBarButtonItem *views = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"▶ %@", [object objectForKey:@"views"]] style:UIBarButtonItemStylePlain target:self action:nil];
                views.enabled = YES;
                blur.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil], views, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil]];
                [cell addSubview:blur];
            }
        }
        [cell setNeedsLayout]; 
    }];
    request = nil;
    
    cell.textLabel.text = [object objectForKey:@"title"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:[object objectForKey:@"filmedOn"]];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:100/255.0f green:0.0f blue:0.0f alpha:1.0f];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFObject *object = [feedContent objectAtIndex:indexPath.row];
    
    [[NSUserDefaults standardUserDefaults] setObject:[object objectId] forKey:@"videoChosen"];
    
    PSBNTheaterPlayer *player = [[PSBNTheaterPlayer alloc] init];
    player.title = [object objectForKey:@"title"];
    [self.navigationController pushViewController:player animated:YES];
}

@end