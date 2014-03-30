//
//  PSBNBasketball.m
//  PSBN
//
//  Created by Victor Ilisei on 3/29/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNBasketball.h"

@implementation PSBNBasketball

- (void)setObject:(PFObject *)object {
    self.objectColor = [UIColor colorWithRed:1/3.0f green:0.5/3.0f blue:0.0f alpha:1.0f];
    [super setObject:object];
}

@end