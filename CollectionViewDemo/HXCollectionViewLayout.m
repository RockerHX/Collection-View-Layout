//
//  HXCollectionViewLayout.m
//  CollectionViewDemo
//
//  Created by miaios on 16/4/19.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXCollectionViewLayout.h"


@implementation HXCollectionViewLayout {
    NSArray<UICollectionViewLayoutAttributes *> *_layoutAttributes;
    
    CGPoint _finialPotin;
}

#pragma mark - Init Methods
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Load Methods
- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

#pragma mark - Configure Methods
- (void)setup {
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
}

#pragma mark - Property
- (CGFloat)controlWidht {
    return self.collectionView.frame.size.width;
}

- (CGFloat)controlHeight {
    return self.collectionView.frame.size.height;
}

- (CGFloat)itemWidth {
    return self.controlWidht - _itemSpacing*2 - _itemSpilled*2;
}

- (CGFloat)itemHeight {
    return self.controlHeight;
}

#pragma mark - Required Methods
// 1.计算Item位置
- (void)prepareLayout {
    [super prepareLayout];
    
    NSInteger sectionCount = [self.collectionView numberOfSections];
    NSInteger itemsCount = [self.collectionView numberOfItemsInSection:0];
    
    if (sectionCount > 1) {
        assert(@"Collection View Section Count Must Only One!");
        return;
    }
    
    // 计算控件宽度
    CGFloat controlWidht = self.controlWidht;
    CGFloat controlHeight = self.controlHeight;
    
    // 计算卡片宽度
    CGFloat itemWidth = self.itemWidth;
    CGFloat itemHeith = self.itemHeight;
    
    // 计算x轴
    CGFloat x = _itemSpacing + _itemSpilled;
    NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemsCount];
    // 遍历item
    for(NSInteger itemIndex = 0; itemIndex < itemsCount; itemIndex++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        // 通过协议回传卡片风格
        HXCollectionViewLayoutStyle style = [_delegate collectionView:self.collectionView layout:self styleForItemAtIndexPath:indexPath];
        
        // 计算y轴
        CGFloat y = 0.0f;
        HXCollectionViewLayoutStyle lastStyle = HXCollectionViewLayoutStyleHeavy;
        if (style == HXCollectionViewLayoutStylePetty) {
            itemHeith = (controlHeight - _itemSpacing) / 2;
            itemWidth = (controlWidht - _itemSpacing*3 - _itemSpilled*2) / 2;
            
            NSIndexPath *lastIndexPath = nil;
            if (itemIndex) {
                lastIndexPath = [NSIndexPath indexPathForItem:(itemIndex - 1) inSection:0];
                lastStyle = [_delegate collectionView:self.collectionView layout:self styleForItemAtIndexPath:lastIndexPath];
            }
            if (lastIndexPath && (lastStyle == HXCollectionViewLayoutStylePetty)) {
                UICollectionViewLayoutAttributes *lastAttributes = [itemAttributes lastObject];
                if (lastAttributes.frame.origin.y == 0.0f) {
                    y = itemHeith + _itemSpacing;
                }
            }
        }
        
//        NSLog(@"%@:%@", @(itemIndex).stringValue, @(x).stringValue);
        attributes.frame = CGRectMake(x, y, itemWidth, itemHeith);
        // 下一个item的x坐标
        switch (style) {
            case HXCollectionViewLayoutStyleHeavy: {
                x += (itemWidth + _itemSpacing);
                break;
            }
            case HXCollectionViewLayoutStylePetty: {
                if (y > 0.0f) {
                    x += (itemWidth + _itemSpacing);
                }
                break;
            }
        }
        // 保存item属性
        [itemAttributes addObject:attributes];
    }
    _layoutAttributes = [itemAttributes copy];
}

// 2.计算拖动范围
- (CGSize)collectionViewContentSize {
    CGFloat sizeHeight = [_layoutAttributes firstObject].frame.size.height;
    __block CGFloat sizeWidth = 0;
    [_layoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attributes, NSUInteger index, BOOL * _Nonnull stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        HXCollectionViewLayoutStyle style = [_delegate collectionView:self.collectionView layout:self styleForItemAtIndexPath:indexPath];
        
        switch (style) {
            case HXCollectionViewLayoutStyleHeavy: {
                sizeWidth += (attributes.frame.size.width + _itemSpacing);
                break;
            }
            case HXCollectionViewLayoutStylePetty: {
                if (attributes.frame.origin.y == 0.0f) {
                    sizeWidth += (attributes.frame.size.width + _itemSpacing);
                }
                break;
            }
        }
    }];
    
    sizeWidth += (_itemSpacing + _itemSpilled);
    
    return CGSizeMake(sizeWidth, sizeHeight);
}

// 3.根据可视范围显示Item
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *visibleAttributes = @[].mutableCopy;
    [_layoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [visibleAttributes addObject:attributes];
        }
    }];
    return visibleAttributes;
}

#pragma mark - Optional Methods
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    NSLog(@"proposedContentOffset:%@", NSStringFromCGPoint(proposedContentOffset));
    NSLog(@"velocity:%@", NSStringFromCGPoint(velocity));
    
    UICollectionViewLayoutAttributes *finialAttribute = [self layoutAttributesForElementsInPoint:proposedContentOffset];
    if (finialAttribute) {
        CGPoint finialPoint = CGPointMake(finialAttribute.frame.origin.x - _itemSpacing, proposedContentOffset.y);
        if (ABS(proposedContentOffset.x - _finialPotin.x) < self.controlWidht) {
            NSLog(@"ABS:%@", @(ABS(proposedContentOffset.x - _finialPotin.x)).stringValue);
            if (proposedContentOffset.x >= _finialPotin.x) {
                finialPoint.x += (finialAttribute.frame.size.width + _itemSpacing);
            }
        }
        
        _indexPath = [self indexPathAtPoint:finialPoint];
        HXCollectionViewLayoutStyle style = [_delegate collectionView:self.collectionView layout:self styleForItemAtIndexPath:_indexPath];
        if (style == HXCollectionViewLayoutStyleHeavy) {
            finialPoint.x -= _itemSpilled;
        }
        
        NSLog(@"finial index:%@", @(_indexPath.row).stringValue);
        _finialPotin = finialPoint;
        return finialPoint;
    } else {
        _indexPath = [self indexPathAtPoint:proposedContentOffset];
        _finialPotin = proposedContentOffset;
        return proposedContentOffset;
    }
}

#pragma mark - Public Methods
- (NSIndexPath *)indexPathAtPoint:(CGPoint)point {
    UICollectionViewLayoutAttributes *finialAttribute = [self layoutAttributesForElementsInPoint:point];
    NSInteger itemIndex = [_layoutAttributes indexOfObject:finialAttribute];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:0];
    return indexPath;
}

#pragma mark - Private Methods
- (UICollectionViewLayoutAttributes *)layoutAttributesForElementsInPoint:(CGPoint)point {
    CGFloat placeholder = _itemSpacing + _itemSpilled;
    __block UICollectionViewLayoutAttributes *visibleAttributes = nil;
    [_layoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull attributes, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect rect = (CGRect){attributes.frame.origin.x - placeholder, attributes.frame.origin.y, attributes.frame.size.width + placeholder, attributes.frame.size.height};
        if (CGRectContainsPoint(rect, point)) {
            visibleAttributes = attributes;
            return;
        }
    }];
    return visibleAttributes;
}

@end
