//
//  PSBNTheaterList.m
//  PSBN
//
//  Created by Victor Ilisei on 4/23/14.
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
        @autoreleasepool {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont fontWithName:@"Tahoma-Bold" size:21.0f];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            self.navigationItem.titleView = label;
            label.text = self.title;
            [label sizeToFit];
        }
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // iOS 7 Slide to go back
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    // Setup refresh control
    @autoreleasepool {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f];
        [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
    [self refresh];
    
    // Setup tableview color
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
}

- (UIColor *)lighterColor:(UIColor *)baseColor {
    @autoreleasepool {
        CGFloat h, s, b, a;
        if ([baseColor getHue:&h saturation:&s brightness:&b alpha:&a]) {
            return [UIColor colorWithHue:h saturation:s brightness:MIN(b * 1.5f, 0.65f) alpha:a];
        } else {
            return nil;
        }
    }
}

- (void)refresh {
    // Animate start
    [self.refreshControl beginRefreshing];
    
    // Clear array
    events = [[NSMutableArray alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @autoreleasepool {
            NSString *channelAPIURL = @"https://api.new.livestream.com/accounts/5145446";
            NSData *channelAPI = [NSData dataWithContentsOfURL:[NSURL URLWithString:channelAPIURL]];
            NSError *channelError;
            NSDictionary *channelContent = [NSJSONSerialization JSONObjectWithData:channelAPI options:kNilOptions error:&channelError];
            if (channelError) {
                @autoreleasepool {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:channelError.localizedFailureReason message:channelError.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    [errorAlert show];
                }
            } else {
                @autoreleasepool {
                    NSDictionary *allEvents = [channelContent objectForKey:@"upcoming_events"];
                    
                    [events addObject:[allEvents objectForKey:@"data"]];
                }
                
                @autoreleasepool {
                    NSDictionary *allEvents = [channelContent objectForKey:@"past_events"];
                    
                    [events addObject:[allEvents objectForKey:@"data"]];
                }
                
            }
        }
        
        // Update table
        [self.tableView reloadData];
        // Animate end
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Upcoming & Live Events";
    } else {
        return @"Archived Events";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 300;
    } else {
        return 100;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [events count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[events objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    @autoreleasepool {
        float cellHeight;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cellHeight = 300.0f;
        } else {
            cellHeight = 100.0f;
        }
        UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cellHeight)];
        @autoreleasepool {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = selectedView.frame;
            gradient.colors = @[(id)[UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f].CGColor, (id)[self lighterColor:[self lighterColor:[UIColor colorWithRed:229/255.0f green:46/255.0f blue:23/255.0f alpha:1.0f]]].CGColor];
            [selectedView.layer addSublayer:gradient];
        }
        cell.selectedBackgroundView = selectedView;
    }
    
    @autoreleasepool {
        NSURL *url;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if ([[UIScreen mainScreen] scale] == 2.00) {
                url = [NSURL URLWithString:[[[[[events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"logo"] objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]];
            } else {
                url = [NSURL URLWithString:[[[[[[events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"logo"] objectForKey:@"small_url"] stringByReplacingOccurrencesOfString:@"170x255" withString:@"200x300"] stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]];
            }
        } else {
            if ([[UIScreen mainScreen] scale] == 2.00) {
                url = [NSURL URLWithString:[[[[[[events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"logo"] objectForKey:@"small_url"] stringByReplacingOccurrencesOfString:@"170x255" withString:@"133x200"] stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]];
            } else {
                url = [NSURL URLWithString:[[[[[[events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"logo"] objectForKey:@"small_url"] stringByReplacingOccurrencesOfString:@"170x255" withString:@"67x100"] stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"]];
            }
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
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
    }
    
    cell.textLabel.text = [[[events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"full_name"];
    cell.textLabel.numberOfLines = 3;
    
    @autoreleasepool {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
        NSDate *date = [dateFormatter dateFromString:[[[events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"start_time"]];
        
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
    }
    cell.detailTextLabel.textColor = [UIColor colorWithRed:100/255.0f green:0.0f blue:0.0f alpha:1.0f];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PSBNTheaterPlayer *player = [[PSBNTheaterPlayer alloc] init];
    player.title = [[[events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"full_name"];
    player.eventID = [[[[events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id"] longValue];
    @autoreleasepool {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
        player.eventDate = [dateFormatter dateFromString:[[[events objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"start_time"]];
    }
    [self.navigationController pushViewController:player animated:YES];
}

@end