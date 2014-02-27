//
//  PSBNTheaterList.h
//  PSBN
//
//  Created by Victor Ilisei on 12/17/13.
//  Copyright (c) 2013 Tech Genius. All rights reserved.
//

@interface PSBNTheaterList : UITableViewController {
    NSMutableArray *feedContent;
    double customPlayerReloadInterval;
    
    UIProgressView *backgroundProgress;
    float videosProcessed;
    float numberOfVideos;
}

- (void)refresh;

@end