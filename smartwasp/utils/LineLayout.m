//
//  LineLayout.m
//  自定义UICollectionView的布局
//
//  Created by Tengfei on 15/12/27.
//  Copyright © 2015年 tengfei. All rights reserved.
//

#import "LineLayout.h"

@implementation LineLayout

/**
 *  控制最后srollview的最后去哪里
 *  用来设置collectionView停止滚动那一刻的位置
 *  @param proposedContentOffset 原本Scrollview停止滚动那一刻的位置
 *  @param velocity     滚动速度
 */
-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    CGRect visibleRect ;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.frame.size;
    NSArray *array = [self layoutAttributesForElementsInRect:visibleRect];
    CGRect intersection;
    CGFloat offsetX = 0;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        CGRect rect = CGRectIntersection(visibleRect, attrs.frame);
        if(intersection.size.width < rect.size.width){
            intersection = rect;
            offsetX = attrs.frame.origin.x;
        }
    }
    return CGPointMake(offsetX, 0);
}

@end









