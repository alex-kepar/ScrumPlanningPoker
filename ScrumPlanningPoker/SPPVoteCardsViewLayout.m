//
//  SPPCollectionViewLayout.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 6/27/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPVoteCardsViewLayout.h"

#define INACTIVE_GREY_VALUE     0.3f
#define ZOOM_FACTOR             0.2f

@implementation SPPVoteCardsViewLayout {
    //NSInteger currentPage;
}

@synthesize currentItem;

/*-(id)init
{
    if (!(self = [super init])) return nil;
    
    // Set up our basic properties
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //self.itemSize = CGSizeMake(180, 180);
    self.minimumLineSpacing = -60;      // Gets items up close to one another
    self.minimumInteritemSpacing = 200; // Makes sure we only have 1 row of items in portrait mode
    
    return self;
}*/


-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat pageSize = self.itemSize.width + self.minimumInteritemSpacing;
    NSInteger newItem = round(proposedContentOffset.x / pageSize);
    if (newItem < currentItem) {
        currentItem --;
    } else if (newItem > currentItem) {
        currentItem ++;
    }
    CGFloat xOffset =  currentItem * pageSize;
    
    
    //UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath: [NSIndexPath indexPathForItem:currentPage inSection:0]];
    
    //attr.alpha=0;
    return CGPointMake(xOffset, proposedContentOffset.y);
}


-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    [self applyLayoutAttributes:attributes];
    return attributes;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *layoutAttributesArray = [super layoutAttributesForElementsInRect:rect];

    for (UICollectionViewLayoutAttributes* attributes in layoutAttributesArray)
    {
        // We're going to calculate the rect of the collection view visible to the user.
        // That way, we can avoid laying out cells that are not visible.
        if (CGRectIntersectsRect(attributes.frame, rect))
        {
            [self applyLayoutAttributes:attributes];
        }
    }
    return layoutAttributesArray;
}



#pragma mark + Private Custom Methods

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes
{
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));
    [self applyLayoutAttributes:attributes forVisibleRect:visibleRect];
}

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes forVisibleRect:(CGRect)visibleRect
{
    // Applies the cover flow effect to the given layout attributes.
    
    // We want to skip supplementary views.
    if (attributes.representedElementKind) return;

    // Calculate the distance from the center of the visible rect to the center of the attributes.
    // Then normalize it so we can compare them all. This way, all items further away than the
    // active get the same transform.
    CGFloat activeDistance = round(self.itemSize.width/2);
    CGFloat distanceFromVisibleRectToItem = CGRectGetMidX(visibleRect) - attributes.center.x;
    CGFloat normalizedDistance = distanceFromVisibleRectToItem / activeDistance;
    //BOOL isLeft = distanceFromVisibleRectToItem > 0;
    CATransform3D transform = CATransform3DIdentity;

    if (fabsf(distanceFromVisibleRectToItem) < activeDistance)
    {
        CGFloat ratioToCenter = (activeDistance - fabsf(distanceFromVisibleRectToItem)) / activeDistance;

        attributes.alpha = INACTIVE_GREY_VALUE + ratioToCenter * (1 - INACTIVE_GREY_VALUE);

        CGFloat zoom = 1 + ZOOM_FACTOR*(1 - ABS(normalizedDistance));
        transform = CATransform3DScale(transform, zoom, zoom, 1);
        attributes.zIndex = 1;
        
        //[attributes setValue:[NSNumber numberWithBool:YES] forKey:@"isSelected"];
    } else {
        attributes.alpha = INACTIVE_GREY_VALUE;
        
        attributes.zIndex = 0;
        //[attributes setValue:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
    }
    attributes.transform3D = transform;
}

@end
