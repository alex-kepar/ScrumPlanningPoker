//
//  SPPEditableCollectionView.m
//  ScrumPlanningPoker
//
//  Created by Oleksandr Kiporenko on 10/27/14.
//  Copyright (c) 2014 Delphi. All rights reserved.
//

#import "SPPEditableCollectionView.h"

@interface SPPEditableCollectionView () <UIGestureRecognizerDelegate>
@property UIPanGestureRecognizer *delPanGesture;
@property (nonatomic) UIButton *delButton;
@property (nonatomic) UICollectionViewCell *delCell;
@property (nonatomic) UIView *delSnapshot;
@end

@implementation SPPEditableCollectionView

//@synthesize isEditMode = _isEditMode;

#pragma mark - Initialize
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.buttonHeight = 20;
        self.delPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanGestureInvoke:)];
        self.delPanGesture.delegate = self;
        [self addGestureRecognizer:self.delPanGesture];
    }
    return self;
}

- (void)setIsEditMode:(BOOL)isEditMode {
    if (!isEditMode && self.delCell) {
        [self setEditMode:NO ForCell:self.delCell];
    }
    _isEditMode = isEditMode;
}

- (BOOL)isIsEditMode {
    return _isEditMode;
}

#pragma mark - Events
- (void)delButtonDidTap {
    //NSLog(@"Delete button has pressed");
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:shouldDeleteItemAtIndexPath:)]) {
        __weak UICollectionView *weakSelf = self;
        NSIndexPath *indexPath = [self indexPathForCell:self.delCell];
        [self.delegate collectionView:weakSelf shouldDeleteItemAtIndexPath:indexPath];
    }
    
}

#pragma mark - UIPanGestureRecognizer handler
- (void)didPanGestureInvoke:(UIPanGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self setEditMode:NO ForCell:self.delCell];
        }
        return;
    }
    
    CGPoint location = [gestureRecognizer locationInView:self];
    NSIndexPath *cellIndexPath = [self indexPathForItemAtPoint:location];
    //NSLog(@"State = %ld", gestureRecognizer.state);
    CGPoint trans = [gestureRecognizer translationInView:self];
    if (trans.y < 0) {
        trans.y = 0;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"UIGestureRecognizerStateBegan");
        [self setEditMode:NO ForCell:self.delCell];
        if (cellIndexPath && abs(trans.y) >= abs(trans.x)) {
            if (self.panGestureRecognizer) {
                BOOL isEnabled = self.panGestureRecognizer.enabled;
                self.panGestureRecognizer.enabled = NO;
                self.panGestureRecognizer.enabled = isEnabled;
            }
            BOOL isCan = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(collectionView:canEditCellAtIndexPath:)]) {
                __weak UICollectionView *weakSelf = self;
                isCan = [self.delegate collectionView:weakSelf canEditCellAtIndexPath:cellIndexPath];
            }
            if (isCan) {
                [self setEditMode:YES ForCell:[self cellForItemAtIndexPath:cellIndexPath]];
            }
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged && self.delCell) {
        //NSLog(@"UIGestureRecognizerStateChanged");
        CGFloat shift = trans.y;
        CGFloat delButtonHeight = self.delButton.bounds.size.height;
        if (shift >= delButtonHeight) {
            shift = delButtonHeight + (shift - delButtonHeight)/5;
        }
        CGRect frame = [self.delSnapshot frame];
        frame.origin.y = shift;
        [self.delSnapshot setFrame:frame];
        //NSLog(@"shift = %f", shift);
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded && self.delCell) {
        //NSLog(@"UIGestureRecognizerStateEnded");
        CGFloat delButtonHeight = self.delButton.bounds.size.height;
        [self setDeleteButtonState:trans.y >= delButtonHeight/2];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self.delButton) {
        return NO;
    } else if (gestureRecognizer == self.delPanGesture) {
        if (self.delCell) {
            [self setEditMode:NO ForCell:self.delCell];
            //NSLog(@"*******************************************");
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.delPanGesture) {
        return self.isEditMode;
    }
    return YES;
}

-(void) setEditMode:(BOOL)isEditMode ForCell:(UICollectionViewCell*)cell{
    if (!isEditMode) {
        self.delCell.contentView.hidden = NO;
        if (self.delCell) {
            [self.delButton removeFromSuperview];
            [self.delSnapshot removeFromSuperview];
            self.delButton = nil;
            self.delSnapshot = nil;
            self.delCell = nil;
        }
    } else {
        if (self.delCell && self.delCell != cell) {
            [self setEditMode:NO ForCell:nil];
        }
        if (cell && cell != self.delCell) {
            self.delSnapshot = [self getSnapshotForCell:cell];
            self.delButton = [self getButtonForCell:cell];
            self.delCell = cell;
            [self.delCell addSubview:self.delButton];
            [self.delCell addSubview:self.delSnapshot];
            self.delCell.contentView.hidden = YES;
        }
    }
}

-(id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    id cell = [super dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (cell == self.delCell) {
        [self setEditMode:NO ForCell:nil];
    }
    return cell;
}
-(void) setDeleteButtonState:(BOOL)isDeleteButtonShow {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = [self.delSnapshot frame];
                         CGFloat delButtonHigh = self.delButton.bounds.size.height;
                         frame.origin.y = isDeleteButtonShow ? delButtonHigh : 0;
                         [self.delSnapshot setFrame:frame];
                     }
                     completion:nil];
}

- (UIView*)getSnapshotForCell:(UICollectionViewCell*)cell {
    UIView *snapshot = [cell snapshotViewAfterScreenUpdates:NO];
    return snapshot;
}

- (UIButton*)getButtonForCell:(UICollectionViewCell*)cell {
    CGRect rect = cell.bounds;
    rect.size.height = self.buttonHeight;
    UIButton *button = [[UIButton alloc] init];
    [button setFrame:rect];
    [button setBackgroundColor:[UIColor redColor]];
    [button setTitle:@"Delete" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button addTarget:self action:@selector(delButtonDidTap) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
