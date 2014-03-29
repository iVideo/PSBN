//
//  PSBNScoreHeader.m
//  PSBN
//
//  Created by Victor Ilisei on 3/29/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNScoreHeader.h"

@implementation PSBNScoreHeader

- (void)createHeaderTitleWith:(NSString *)title {
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, self.frame.size.height/4, self.frame.size.width, self.frame.size.height/2)];
    // headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.font = [UIFont boldSystemFontOfSize:19.0f];
    headerTitle.backgroundColor = [UIColor clearColor];
    headerTitle.textColor = [UIColor whiteColor];
    headerTitle.text = title;
    [self addSubview:headerTitle];
}

@end