//
//  QCCustomUICollectionViewFlowLayout.m
//  UICollectView
//
//  Created by vhbvbqc on 16/5/4.
//  Copyright © 2016年 YT. All rights reserved.
//

#import "QCCustomUICollectionViewFlowLayout.h"

@implementation QCCustomUICollectionViewFlowLayout

- (void)prepareLayout{
    [super prepareLayout];
    
    self.itemSize = CGSizeMake(kScreenWidth, 150);
    
    CGFloat offset = (self.collectionView.width - self.itemSize.width)/2 ;
    
    self.sectionInset = UIEdgeInsetsMake(0, offset, 0, offset);

    self.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES ;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSArray<UICollectionViewLayoutAttributes *> * atrbs = [super layoutAttributesForElementsInRect:rect];
    for (NSInteger i=0; i<atrbs.count; i++) {
        CGFloat colCenterX = self.collectionView.contentOffset.x+self.collectionView.frame.size.width/2;
        CGFloat cellCenterX = [atrbs[i] center].x ;
        CGFloat offset = ABS(colCenterX-cellCenterX);
        CGFloat scale = 1 - (offset/self.collectionView.frame.size.width)/2 ;
        [atrbs[i] setTransform:CGAffineTransformMakeScale(scale, scale)];
    }
    return atrbs ;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    
    CGRect rect ;
    rect.origin.y = 0 ;
    rect.origin.x = proposedContentOffset.x ;
    rect.size = self.collectionView.frame.size ;
    
    NSArray * atrbs = [super layoutAttributesForElementsInRect:rect];
    
    CGFloat offsetMin = MAXFLOAT ;
    CGFloat colCenterX = proposedContentOffset.x+self.collectionView.frame.size.width/2;
    
    for (UICollectionViewLayoutAttributes * obj in atrbs) {
        CGFloat cellCenterX = obj.center.x ;
        CGFloat offset = colCenterX-cellCenterX;
        if (ABS(offsetMin)>=ABS(offset)) {
            offsetMin = offset ;
        }
    }
    proposedContentOffset.x-=offsetMin;
    return proposedContentOffset ;
}


@end
