//
//  HFCollectionBindingHelper.h
//  SpicyGymLog
//
//  Created by Lono on 2015/5/21.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HFMetaBindingHelper.h"

@interface HFCollectionViewBindingHelper : HFMetaBindingHelper <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) id <UICollectionViewDelegate>   delegate;
@property (nonatomic, weak) id <UICollectionViewDataSource>   dataSource;

+ (instancetype)bindingForCollectionView:(UICollectionView *)collectionView
                              sourceList:(KVOMutableArray*)source
                       didSelectionBlock:(HFSelectionBlock)block
                   templateCellClassName:(NSString *)templateCellClass
                                isNested:(BOOL)isNested;

+ (instancetype)bindingForCollectionView:(UICollectionView *)collectionView
                              sourceList:(KVOMutableArray*)source
                       didSelectionBlock:(HFSelectionBlock)block
                   cellReuseIdentifier:(NSString *)reuseIdentifier
                                isNested:(BOOL)isNested;
@end