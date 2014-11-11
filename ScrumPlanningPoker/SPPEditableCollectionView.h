//
//  SPPEditableCollectionView.h
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 10/27/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPPEditableCollectionView;
@protocol SPPEditableCollectionViewDelegate <NSObject>
@optional
- (void)collectionView:(UICollectionView*)collectionView shouldDeleteItemAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)collectionView:(UICollectionView *)collectionView canEditCellAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface SPPEditableCollectionView : UICollectionView

@property (nonatomic, assign) id <UICollectionViewDelegate,SPPEditableCollectionViewDelegate> delegate;
@property (nonatomic) CGFloat buttonHeight;
@property (nonatomic) BOOL isEditMode;

@end
