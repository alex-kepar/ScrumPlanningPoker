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


typedef void(^VoteViewControllerAction)(NSInteger voteValue);

@interface VoteViewController : SPPBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

//@property SPPVote *vote;
@property NSString *promptRoot;
@property NSString *content;
@property (nonatomic, copy) VoteViewControllerAction action;

@property (weak, nonatomic) IBOutlet SPPVoteCardViewCell *cvCards;
@property (weak, nonatomic) IBOutlet SPPVoteCardsViewLayout *vlCardsLayout;
@property (weak, nonatomic) IBOutlet UITextView *tvContent;
- (IBAction)actVote:(id)sender;
@end
