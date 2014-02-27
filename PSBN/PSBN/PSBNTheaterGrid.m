//
//  PSBNTheaterGrid.m
//  PSBN
//
//  Created by Victor Ilisei on 2/7/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNTheaterGrid.h"

@interface PSBNTheaterGrid ()

@end

@implementation PSBNTheaterGrid

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Grid";
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

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        cellSize = CGSizeMake(133, 225);
        flowLayout.itemSize = cellSize;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self = [super initWithCollectionViewLayout:flowLayout];
        
        self.title = @"Grid";
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
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [feedContent count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, cellSize.width, cellSize.height)];
    }
    
    return cell;
}

@end