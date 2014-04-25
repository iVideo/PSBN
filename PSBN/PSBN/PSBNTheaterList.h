//
//  PSBNTheaterList.h
//  PSBN
//
//  Created by Victor Ilisei on 4/23/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNTheaterPlayer.h"

@interface PSBNTheaterList : UITableViewController {
    NSMutableArray *events;
}

- (void)refresh;

@end