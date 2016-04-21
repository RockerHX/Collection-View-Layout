//
//  HXMainViewController.m
//  CollectionViewDemo
//
//  Created by miaios on 16/4/19.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXMainViewController.h"
#import "HXCollectionViewLayout.h"


@interface HXMainViewController() <
HXCollectionViewLayoutDelegate
>
@end


@implementation HXMainViewController {
    NSInteger _itemCount;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _itemCount = 20;
    
    HXCollectionViewLayout *layout = (HXCollectionViewLayout *)self.collectionView.collectionViewLayout;
    layout.delegate = self;
    layout.itemSpacing = 12.0f;
    layout.itemSpilled = 20.0f;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [(UILabel *)[cell viewWithTag:1] setText:@(indexPath.row).stringValue];
    return cell;
}

#pragma mark - HXCollectionViewLayoutDelegate Methods
- (HXCollectionViewLayoutStyle)collectionView:(UICollectionView *)collectionView layout:(HXCollectionViewLayout *)layout styleForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row < 5) ? HXCollectionViewLayoutStyleHeavy : HXCollectionViewLayoutStylePetty;
}

@end
