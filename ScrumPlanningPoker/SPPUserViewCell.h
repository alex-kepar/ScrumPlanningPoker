//
//  SPPRoomViewCell.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 3/20/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPUser.h"
#import "SPPVote.h"

@interface SPPUserViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *lVote;

-(void) initializeWithUser:(SPPUser*)initUser andVote:(SPPVote*)initVote;
@end
