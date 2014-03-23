//
//  PSBNRadio.m
//  PSBN
//
//  Created by Victor Ilisei on 2/27/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNRadio.h"

@interface PSBNRadio ()

@end

@implementation PSBNRadio

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(262, 81);
    flowLayout.minimumInteritemSpacing = 5;
    // flowLayout.minimumLineSpacing = 10;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {
        // Custom initialization
        self.title = @"Radio";
        self.tabBarItem.image = [UIImage imageNamed:@"UITabBarPodcasts"];
        
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([self respondsToSelector:@selector(preferredContentSize)]) {
            // self.preferredContentSize = CGSizeMake(320, [self.collectionView contentSize].height);
            self.preferredContentSize = CGSizeMake(320, 568);
        } else {
            // self.contentSizeForViewInPopover = CGSizeMake(320, [self.collectionView contentSize].height);
            self.contentSizeForViewInPopover = CGSizeMake(320, 568);
        }
    }
	// Do any additional setup after loading the view.
}

#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    cell.backgroundColor = [UIColor blueColor];
    
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.frame];
    selectedView.backgroundColor = [UIColor redColor];
    cell.selectedBackgroundView = selectedView;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end