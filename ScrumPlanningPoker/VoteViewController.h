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

typedef void(^VoteViewControllerActionBlock)(SPPVote *vote, NSInteger voteValue);

@interface VoteViewController : SPPBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

//@property SPPVote *vote;
@property NSString *promptRoot;
@property SPPVote *vote;
@property NSString *title;
@property double defaultValue;
@property (copy, nonatomic) VoteViewControllerActionBlock action;

//@property (weak, nonatomic) IBOutlet SPPVoteCardViewCell *cvCards;
@property (weak, nonatomic) IBOutlet SPPVoteCardsViewLayout *vlCardsLayout;
@property (weak, nonatomic) IBOutlet UITextView *tvContent;
@property (weak, nonatomic) IBOutlet UICollectionView *cvCardsList;
@end
