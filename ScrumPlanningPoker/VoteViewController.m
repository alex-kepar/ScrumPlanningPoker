//
//  VoteViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/24/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "VoteViewController.h"

@interface VoteViewController ()
{
    NSArray *cardsList;
}

@end

@implementation VoteViewController

//@synthesize vote;
@synthesize promptRoot;
@synthesize content;
//@synthesize isOveralVote;
@synthesize voteDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    cardsList = @[@0, @1, @2, @3, @5, @8, @13, @21];

    self.navigationItem.prompt = [NSString stringWithFormat:@"%@/Voting", promptRoot];

    _tvContent.text = content;//vote.content;
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.vlCardsLayout initialize];
    //[self.vlCardsLayout invalidateLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark + UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return cardsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SPPVoteCardViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CardCell" forIndexPath:indexPath];
    
    if(cell!=nil)
    {
        cell.label.text = [NSString stringWithFormat:@"%d", [cardsList[indexPath.row] integerValue]];
    }
    return cell;
}

#pragma mark - UICollectionViewDataSource

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [_vlCardsLayout didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (IBAction)actVote:(id)sender {
    if (_vlCardsLayout.currentItem < cardsList.count) {
        if (voteDelegate && [voteDelegate respondsToSelector:@selector(VoteViewDoVote:forSegueIdentifier:)]) {
            [voteDelegate VoteViewDoVote:[cardsList[_vlCardsLayout.currentItem] integerValue] forSegueIdentifier:_segueIdentifier];
        }
        //[vote doVote:[cardsList[_vlCardsLayout.currentItem] integerValue]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
