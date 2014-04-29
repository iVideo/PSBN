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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.titleScrollerBackgroundColour = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navBarTile_iOS6"]];
        
        self.disableUIPageControl = YES;
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
            self.titleScrollerHeight = 64;
            self.hideStatusBarWhenScrolling = YES;
            self.triangleBackgroundColour = [UIColor clearColor];
        } else {
            self.titleScrollerHeight = 44;
        }
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.dataSource = self;
    self.delegate = self;
    
    @autoreleasepool {
        PSBNAppDelegate *delegate = (PSBNAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (delegate.devMode) {
            pageArray = @[[[PSBNScoreCenterChild alloc] initWithSport:@"Football_Scores"], [[PSBNScoreCenterChild alloc] initWithSport:@"Volleyball_Scores"], [[PSBNScoreCenterChild alloc] initWithSport:@"basketballScores"]];
        } else {
            pageArray = @[[[PSBNScoreCenterChild alloc] initWithSport:@"Football_Scores"], [[PSBNScoreCenterChild alloc] initWithSport:@"Volleyball_Scores"]];
        }
    }
}

- (int)numberOfPagesForSlidingPagesViewController:(TTScrollSlidingPagesController *)source {
    return (int)[pageArray count];
}

- (TTSlidingPageTitle *)titleForSlidingPagesViewController:(TTScrollSlidingPagesController *)source atIndex:(int)index {
    TTSlidingPageTitle *title;
    if (index == 0) {
        title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Football"];
    } else if (index == 1) {
        title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Volleyball"];
    } else if (index == 2) {
        title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Basketball"];
    } else if (index == 3) {
        title = [[TTSlidingPageTitle alloc] initWithHeaderText:@"Soccer"];
    }
    return title;
}

- (TTSlidingPage *)pageForSlidingPagesViewController:(TTScrollSlidingPagesController *)source atIndex:(int)index {
    return [[TTSlidingPage alloc] initWithContentViewController:[pageArray objectAtIndex:index]];
}

@end