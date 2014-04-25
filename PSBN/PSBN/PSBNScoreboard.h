//
//  PSBNScoreboard.h
//  PSBN
//
//  Created by Victor Ilisei on 3/27/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

#import <Parse/Parse.h>

@interface PSBNScoreboard : UICollectionViewCell

@property (nonatomic, retain) PFObject *scoreObject;
@property (nonatomic, retain) UIColor *objectColor;

@property (nonatomic, retain) UIImageView *awayIcon;
@property (nonatomic, retain) UILabel *overallScore;
@property (nonatomic, retain) UIImageView *homeIcon;

- (void)setObject:(PFObject *)object;

- (void)drawBackground;
- (void)writeHeader;
- (void)createTeamIcons;
- (void)fillInScores;
- (void)writeFooterWithType:(NSString *)type;

@end