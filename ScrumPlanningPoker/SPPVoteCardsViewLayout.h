//
//  SPPCollectionViewLayout.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/27/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPPVoteCardsViewLayout : UICollectionViewFlowLayout

@property (readonly)NSInteger currentItem;

- (void)initializeWithStartItem:(NSInteger)startItem;
- (void)setCurrentItem:(NSInteger)newCurrentItem animated:(BOOL)isAnimated;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
@end
