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
        eventQuery.limit = 1000;
        [eventQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"improve_enabled"]) {
                    numberOfVideos += (float)(number*2);
                } else {
                    numberOfVideos += (float)(number);
                }
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
                    } else {
                        [self.refreshControl endRefreshing];
                    }
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
            NSURL *posterIpadRetina = [NSURL URLWithString:[object objectForKey:@"posterURLretina"]];
            if ([posterIpadRetina.absoluteString isEqualToString:@"(undefined)"] || [posterIpadRetina.absoluteString isEqualToString:@""]) {
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
                        [object saveEventually];
                    }
                }
            }
            
            // Poster iPad
            NSURL *posterIpad = [NSURL URLWithString:[object objectForKey:@"posterURL"]];
            if ([posterIpad.absoluteString isEqualToString:@"(undefined)"] || [posterIpad.absoluteString isEqualToString:@""]) {
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
                        [object saveEventually];
                    }
                }
            }
            
            // Poster iPhone Retina
            NSURL *posterIphoneRetina = [NSURL URLWithString:[object objectForKey:@"posterURLretina_iPhone"]];
            if ([posterIphoneRetina.absoluteString isEqualToString:@"(undefined)"] || [posterIphoneRetina.absoluteString isEqualToString:@""]) {
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
                        [object saveEventually];
                    }
                }
            }
            
            // Poster iPhone
            NSURL *posterIphone = [NSURL URLWithString:[object objectForKey:@"posterURL_iPhone"]];
            if ([posterIphone.absoluteString isEqualToString:@"(undefined)"] || [posterIphone.absoluteString isEqualToString:@""]) {
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
                        [object saveEventually];
                    }
                }
            }
            
            NSURL *customPlayerURL = [NSURL URLWithString:[object objectForKey:@"customPlayer"]];
            if ([[object updatedAt] timeIntervalSinceNow] < customPlayerReloadInterval || [customPlayerURL.absoluteString isEqualToString:@"(undefined)"] || [customPlayerURL.absoluteString isEqualToString:@""]) {
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
                    }
                    // Update custom player
                    if ([components containsObject:@"secure_m3u8_url"]) {
                        int index = (int)([components indexOfObject:@"secure_m3u8_url"]);
                        NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                        [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                    } else if ([components containsObject:@"m3u8_url"]) {
                        int index = (int)([components indexOfObject:@"m3u8_url"]);
                        NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                        [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                    } else if ([components containsObject:@"secure_progressive_url_hd"]) {
                        int index = (int)([components indexOfObject:@"secure_progressive_url_hd"]);
                        NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                        [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                    } else if ([components containsObject:@"progressive_url_hd"]) {
                        int index = (int)([components indexOfObject:@"progressive_url_hd"]);
                        NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                        [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                    } else if ([components containsObject:@"secure_progressive_url"]) {
                        int index = (int)([components indexOfObject:@"secure_progressive_url"]);
                        NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                        [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                    } else if ([components containsObject:@"progressive_url"]) {
                        int index = (int)([components indexOfObject:@"progressive_url"]);
                        NSString *customPlayerURLretrieved = [components objectAtIndex:index+2];
                        [object setObject:customPlayerURLretrieved forKey:@"customPlayer"];
                    }
                }
                [object saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded && !error) {
                        videosProcessed++;
                        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Improving event %.f of %.f (%.f%%)", videosProcessed, numberOfVideos, (videosProcessed/numberOfVideos)*100]];
                    }
                }];
            } else {
                videosProcessed++;
                self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Improving event %.f of %.f (%.f%%)", videosProcessed, numberOfVideos, (videosProcessed/numberOfVideos)*100]];
                if (videosProcessed == numberOfVideos) {
                    [self.refreshControl endRefreshing];
                    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
                }
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
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
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
    cell.textLabel.numberOfLines = 2;
    
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