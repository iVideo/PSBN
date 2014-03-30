//
//  PSBNFootball.m
//  PSBN
//
//  Created by Victor Ilisei on 3/29/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNFootball.h"

@implementation PSBNFootball

- (void)setObject:(PFObject *)object {
    self.objectColor = [UIColor colorWithRed:0.0f green:1/3.0f blue:0.0f alpha:1.0f];
    [super setObject:object];
}

@end