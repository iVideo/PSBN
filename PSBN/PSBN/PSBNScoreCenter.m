//
//  PSBNScoreCenter.m
//  PSBN
//
//  Created by Victor Ilisei on 3/29/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import "PSBNScoreCenter.h"

@interface PSBNScoreCenter ()

@end

@implementation PSBNScoreCenter

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(320, 81);
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {
        // Custom initialization
        self.title = @"Score Center";
        self.tabBarItem.image = [UIImage imageNamed:@"scores"];
        
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
    // Setup submit button
    @autoreleasepool {
        UIBarButtonItem *submitScores = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(chooseSubmit:)];
        self.navigationItem.leftBarButtonItem = submitScores;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        @autoreleasepool {
            if ([self respondsToSelector:@selector(imageWithRenderingMode:)]) {
                UIBarButtonItem *showRadio = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"UITabBarPodcasts"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStyleBordered target:self action:@selector(showRadio:)];
                self.navigationItem.rightBarButtonItem = showRadio;
            } else {
                UIBarButtonItem *showRadio = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UITabBarPodcasts"] style:UIBarButtonItemStyleBordered target:self action:@selector(showRadio:)];
                self.navigationItem.rightBarButtonItem = showRadio;
            }
        }
    }
    
    // Auto-refresh every minute
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(refresh) userInfo:nil repeats:NO];
}

- (void)refresh {
    
}

- (IBAction)resetTimer:(id)sender {
    
}

- (IBAction)chooseSubmit:(id)sender {
    
}

- (IBAction)showRadio:(id)sender {
    
}

@end