//
//  PageLineLayout.m
//  smartwasp
//
//  Created by luotao on 2021/5/20.
//

#import "PageLineLayout.h"

@interface PageLineLayout ()

@property CGPoint lastOffset;

@end

@implementation PageLineLayout

//准备
-(void)prepareLayout{
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = 30;
    self.minimumInteritemSpacing = 0;
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat pageWidth = self.itemSize.width + self.minimumLineSpacing;
    CGFloat rawPageValue = self.collectionView.contentOffset.x / pageWidth;
    CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
    CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
    BOOL flicked = fabs(velocity.x) > 0.01;
   if (pannedLessThanAPage && flicked) {
       proposedContentOffset.x = nextPage * pageWidth;
   } else {
       proposedContentOffset.x = round(rawPageValue) * pageWidth;
   }
   return proposedContentOffset;
}

@end
