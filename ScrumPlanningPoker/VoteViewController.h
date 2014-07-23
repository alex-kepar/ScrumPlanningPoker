//
//  VoteViewController.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/24/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPBaseViewController.h"
#import "SPPVoteCardsViewLayout.h"
#import "SPPVoteCardViewCell.h"
#import "SPPVote.h"
#import "SPPAgileHub.h"
#import "SPPRoom.h"

@interface VoteViewController : SPPBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property SPPRoom *room;
@property SPPVote *vote;
@property NSString *promptRoot;
@property SPPAgileHub *agileHub;

@property (weak, nonatomic) IBOutlet SPPVoteCardViewCell *cvCards;
@property (weak, nonatomic) IBOutlet SPPVoteCardsViewLayout *vlCardsLayout;
- (IBAction)actVote:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *tvContent;
@end
