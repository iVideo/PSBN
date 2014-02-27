//
//  PSBNTheaterGrid.h
//  PSBN
//
//  Created by Victor Ilisei on 2/7/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

@interface PSBNTheaterGrid : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSMutableArray *feedContent;
    double customPlayerReloadInterval;
    
    CGSize cellSize;
    
    UIProgressView *backgroundProgress;
}

- (void)refresh;

@end