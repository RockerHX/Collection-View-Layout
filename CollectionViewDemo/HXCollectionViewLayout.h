//
//  HXCollectionViewLayout.h
//  CollectionViewDemo
//
//  Created by miaios on 16/4/19.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, HXCollectionViewLayoutStyle) {
    HXCollectionViewLayoutStyleHeavy,
    HXCollectionViewLayoutStylePetty,
};


@class HXCollectionViewLayout;


@protocol HXCollectionViewLayoutDelegate <NSObject>

- (HXCollectionViewLayoutStyle)collectionView:(UICollectionView *)collectionView layout:(HXCollectionViewLayout *)layout styleForItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface HXCollectionViewLayout : UICollectionViewLayout

@property (weak, nonatomic) id<HXCollectionViewLayoutDelegate> delegate;

@property (nonatomic, assign)    CGFloat itemSpacing;
@property (nonatomic, assign)    CGFloat itemSpilled;

@end
