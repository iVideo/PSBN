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
    self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        self.title = @"Radio";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

@end