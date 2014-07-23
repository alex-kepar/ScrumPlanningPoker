//
//  VoteViewController.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/24/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "VoteViewController.h"
#import "SPPProperties.h"

@interface VoteViewController ()
{
    NSArray *cardsList;
    SPPProperties* properties;
}

@end

@implementation VoteViewController

@synthesize room;
@synthesize vote;
@synthesize promptRoot;
@synthesize agileHub;

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    cardsList = @[@0, @1, @2, @3, @5, @8, @13, @21];

    properties = [SPPProperties sharedProperties];
    self.navigationItem.prompt = [NSString stringWithFormat:@"%@/Voting", promptRoot];

    _tvContent.text = vote.content;
	// Do any additional setup after loading the view.
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [_cvCards reloadData];
//}

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

/*- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}*/
#pragma mark - UICollectionViewDataSource

- (IBAction)actVote:(id)sender {
    if (_vlCardsLayout.currentItem < cardsList.count) {
        [agileHub vote:vote.entityId doVote:[cardsList[_vlCardsLayout.currentItem] integerValue] forRooom:room.name];
        //[vote doVote:[cardsList[_vlCardsLayout.currentItem] integerValue]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
