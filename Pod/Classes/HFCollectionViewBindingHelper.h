//
//  HFCollectionBindingHelper.h
//  SpicyGymLog
//
//  Created by Lono on 2015/5/21.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KVOMutableArray.h>


typedef void (^CollectionSelectionBlock)(id model);

@interface HFCollectionViewBindingHelper : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionViewCell        *_templateCell;
}

@property (nonatomic, strong) KVOMutableArray* data;
@property (nonatomic, copy) CollectionSelectionBlock selectionBlock;
@property (nonatomic, weak) UICollectionView* collectionView;
+ (instancetype)bindingForCollectionView:(UICollectionView *)collectionView
                              sourceList:(KVOMutableArray *)source
                       didSelectionBlock:(CollectionSelectionBlock)block
                            templateCell:(UINib *)templateCellNib
                                isNested:(BOOL)isNested;

@end