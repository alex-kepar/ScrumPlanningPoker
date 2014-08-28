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
    int minItem;
}

@end

@implementation VoteViewController

//@synthesize vote;
@synthesize promptRoot;
@synthesize vote;
@synthesize title;
@synthesize action;
@synthesize defaultValue;

- (void)viewDidLoad
{
    [super viewDidLoad];
    cardsList = @[@0, @1, @2, @3, @5, @8, @13, @21];

    self.navigationItem.prompt = [NSString stringWithFormat:@"%@/Voting", promptRoot];
    self.navigationItem.title = title;
    _tvContent.text = vote.content;
    minItem = 0;
    for (int curItem=1; curItem<cardsList.count; curItem++) {
        if (fabs(defaultValue - [cardsList[curItem] integerValue]) <
            fabs(defaultValue - [cardsList[minItem] integerValue])) {
            minItem = curItem;
        }
    }
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self.cvCardsList addGestureRecognizer:tapGestureRecognizer];

    //vote.content;
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.vlCardsLayout initializeWithStartItem:minItem];
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
        cell.label.text = [NSString stringWithFormat:@"%ld", (long)[cardsList[indexPath.row] integerValue]];
    }
    return cell;
}

#pragma mark - UICollectionViewDataSource


-(void)handleTapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateRecognized) return;
    
    NSIndexPath *indexPath = [self.cvCardsList indexPathForItemAtPoint:[recognizer locationInView:self.cvCardsList]];
    if (indexPath) {
        [self.vlCardsLayout setCurrentItem:indexPath.row animated:YES];
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [_vlCardsLayout didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (IBAction)actVote:(id)sender {
    if (_vlCardsLayout.currentItem < cardsList.count) {
        if (action) {
            action(vote, [cardsList[_vlCardsLayout.currentItem] integerValue]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
