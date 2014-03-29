//
//  PSBNScoreboard.h
//  PSBN
//
//  Created by Victor Ilisei on 3/27/14.
//  Copyright (c) 2014 Tech Genius. All rights reserved.
//

@interface PSBNScoreboard : UICollectionViewCell

@property (nonatomic, retain) PFObject *scoreObject;

@property (nonatomic, retain) UIImageView *awayIcon;
@property (nonatomic, retain) UIImageView *homeIcon;

- (void)setObject:(PFObject *)object;

- (void)drawBackground;
- (void)writeHeader;
- (void)createTeamIcons;
- (void)writeFooter;

@end