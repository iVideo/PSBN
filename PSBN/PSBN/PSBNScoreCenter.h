//
//  PSBNScoreCenter.h
//  PSBN
//
//  Created by Victor Ilisei on 3/29/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import <Parse/Parse.h>

#import "TTScrollSlidingPagesController.h"
#import "TTUIScrollViewSlidingPages.h"

#import "PSBNScoreCenterChild.h"

@interface PSBNScoreCenter : TTScrollSlidingPagesController <TTSlidingPagesDataSource, TTSliddingPageDelegate> {
    NSArray *pageArray;
}

@end