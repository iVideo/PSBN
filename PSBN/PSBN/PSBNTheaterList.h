//
//  PSBNTheaterList.h
//  PSBN
//
//  Created by Victor Ilisei on 3/20/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNTheaterPlayer.h"

@interface PSBNTheaterList : UITableViewController {
    NSMutableArray *feedContent;
    
    double customPlayerReloadInterval;
    
    UIProgressView *backgroundProgress;
    float videosProcessed;
    float numberOfVideos;
}

- (void)refresh;
- (void)improve;

@end