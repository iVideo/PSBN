//
//  PSBNScoreCenterChild.m
//  PSBN
//
//  Created by Victor Ilisei on 3/29/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNScoreCenterChild.h"

@interface PSBNScoreCenterChild ()

@end

@implementation PSBNScoreCenterChild

- (id)initWithSport:(NSString *)sportName {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 20+44+self.tabBarController.tabBar.frame.size.height+229+29+5, 0);
    } else {
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 20+44+self.tabBarController.tabBar.frame.size.height+64, 0);
    }
    flowLayout.itemSize = CGSizeMake(310, 229);
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {
        queryClassName = sportName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [self refresh];
}

- (void)refresh {
    // Stop timer
    [refreshTimer invalidate];
    refreshTimer = nil;
    
    // Reset array
    games = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        PFQuery *query = [PFQuery queryWithClassName:queryClassName];
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
                games = objects.mutableCopy;
                [games sortUsingComparator:^NSComparisonResult(id dict1, id dict2) {
                    NSDate *date1 = [(PFObject *)dict1 objectForKey:@"gameDate"];
                    NSDate *date2 = [(PFObject *)dict2 objectForKey:@"gameDate"];
                    return [date2 compare:date1];
                }];
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            }
        }];
    }
    
    // Start timer
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(refresh) userInfo:nil repeats:NO];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [games count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    if ([queryClassName isEqualToString:@"Football_Scores"]) {
        [collectionView registerClass:[PSBNFootball class] forCellWithReuseIdentifier:CellIdentifier];
        PSBNFootball *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        // Configure the cell...
        [cell setObject:[games objectAtIndex:indexPath.row]];
        
        return cell;
    } else if ([queryClassName isEqualToString:@"Volleyball_Scores"]) {
        [collectionView registerClass:[PSBNVolleyball class] forCellWithReuseIdentifier:CellIdentifier];
        PSBNVolleyball *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        // Configure the cell...
        [cell setObject:[games objectAtIndex:indexPath.row]];
        
        return cell;
    } else if ([queryClassName isEqualToString:@"basketballScores"]) {
        [collectionView registerClass:[PSBNBasketball class] forCellWithReuseIdentifier:CellIdentifier];
        PSBNBasketball *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        // Configure the cell...
        [cell setObject:[games objectAtIndex:indexPath.row]];
        
        return cell;
    } else {
        return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
}

@end