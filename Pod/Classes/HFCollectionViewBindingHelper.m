//
//  HFCollectionBindingHelper.m
//  SpicyGymLog
//
//  Created by Lono on 2015/5/21.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import "HFCollectionViewBindingHelper.h"
#import "HFBindingViewDelegate.h"

#if !defined(SAFE_CAST)
#define SAFE_CAST(Object, Type) (Type *)safe_cast_helper(Object, [Type class])
static inline id safe_cast_helper(id x, Class c) {
    return [x isKindOfClass:c] ? x : nil;
}
#endif

@interface HFCollectionViewBindingHelper()
@property (nonatomic, copy) NSString * cellIdentifier;
@property (nonatomic, strong) AMBlockToken* primaryToken;
@property (nonatomic, strong) NSMutableArray* secondaryTokens;
@property (nonatomic, assign) BOOL isNested;
@end

@implementation HFCollectionViewBindingHelper

+ (instancetype)bindingForCollectionView:(UICollectionView *)collectionView
                              sourceList:(KVOMutableArray *)source
                       didSelectionBlock:(CollectionSelectionBlock)block
                            templateCell:(UINib *)templateCellNib
                                isNested:(BOOL)isNested
{
    return [[self alloc] initForCollectionView:collectionView sourceList:source didSelectionBlock:block templateCell:templateCellNib isNested:isNested];
}

- (instancetype)initForCollectionView:(UICollectionView *)collectionView
                           sourceList:(KVOMutableArray *)source
                    didSelectionBlock:(CollectionSelectionBlock)block
                         templateCell:(UINib *)templateCellNib
                            isNested:(BOOL)isNested
{
    self = [self initForCollectionView:collectionView sourceList:source didSelectionBlock:block isNested:isNested];
    if (!self) return nil;
    _templateCell = [[templateCellNib instantiateWithOwner:nil options:nil] firstObject];
    _cellIdentifier = _templateCell.reuseIdentifier;
    [_collectionView registerNib:templateCellNib forCellWithReuseIdentifier:_cellIdentifier];
    
    return self;
}

- (instancetype)initForCollectionView:(UICollectionView *)collectionView
                           sourceList:(KVOMutableArray *)source
                    didSelectionBlock:(CollectionSelectionBlock)block
                            isNested:(BOOL)isNested
{
    NSParameterAssert(collectionView);
    NSParameterAssert(source);
    
    self = [super init];
    if (!self) return nil;
    
    _collectionView = collectionView;
    _data = source;
    _selectionBlock = [block copy];
    _isNested = isNested;
    _secondaryTokens = [NSMutableArray new];
    
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [self startObserving];
    
    return self;
}

- (void)dealloc
{
    [self stopObserving];
}

- (void)stopObserving
{
    [_primaryToken removeObserver];
    for (AMBlockToken* token in _secondaryTokens) {
        [token removeObserver];
    }
    [_secondaryTokens removeAllObjects];
    
}

- (void)startObserving
{
    // remove all existing tokens
    [self stopObserving];
    
    if (YES == self.isNested) {
        // nested
        self.primaryToken = [self observeNestedArray:self.data secondaryTokens:self.secondaryTokens];
    } else {
        self.primaryToken = [self observeRowsInSection:0 array:self.data];
    }
}

- (AMBlockToken*)observeNestedArray:(KVOMutableArray*)array secondaryTokens:(NSMutableArray*)secondaryTokens
{
    typeof(self) __weak selfRef = self;
    
    
    // observe the existing workout sets
    for (NSUInteger i = 0; i < array.count; ++i) {
        AMBlockToken* token = [self observeRowsInSection:i array:array[i]];
        [secondaryTokens addObject:token];
    }
    
    // register KVO events
    AMBlockToken* primaryToken = [array addObserverWithTask:^BOOL(id obj, NSDictionary *change) {
        NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
        NSNumber *kind = change[NSKeyValueChangeKindKey];
        NSArray* new = change[NSKeyValueChangeNewKey];
        
        if (indexes == nil || indexes.count <= 0){
            return YES; // Nothing to do
        }
        
        // stop the observation if the seciton is removed
        if ([kind integerValue] == NSKeyValueChangeRemoval){
            NSArray* beRemovedTokens = [selfRef.secondaryTokens objectsAtIndexes:indexes];
            for (AMBlockToken* token in beRemovedTokens) {
                [token removeObserver];
            }
            [selfRef.secondaryTokens removeObjectsAtIndexes:indexes];
        } else if ([kind integerValue] == NSKeyValueChangeInsertion) {
            NSMutableArray* tokens = [NSMutableArray new];
            // observe the new rows
            
            NSUInteger __block itemId = 0;
            [indexes enumerateIndexesUsingBlock:^(NSUInteger sectionId, BOOL *stop) {
                AMBlockToken* token = [selfRef observeRowsInSection:sectionId array:new[itemId]];
            
                [tokens addObject:token];
                ++itemId;
                *stop = NO;
            }];
            
            [selfRef.secondaryTokens insertObjects:tokens atIndexes:indexes];
        }
        
        // add new cells in row
//        NSUInteger __block itemId = 0;
//        NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
//        [indexes enumerateIndexesUsingBlock:^(NSUInteger sectionId, BOOL *stop) {
//            KVOMutableArray* row = new[itemId];
//            for (NSUInteger i = 0; i < row.count; ++i) {
//                [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:sectionId]];
//            }
//            ++itemId;
//            *stop = NO;
//        }];
//        
//        
//        if (indexPaths.count > 0)
//        {
//            if ([kind integerValue] == NSKeyValueChangeInsertion)
//            {
//                    // Need performBatchUpdates to avoid
//                    // Fatal Exception: NSInternalInconsistencyException
//                    // too many update animations on one view - limit is 31 in flight at a time
//                    
//                    [selfRef.collectionView performBatchUpdates:^{
//                        [selfRef.collectionView insertItemsAtIndexPaths:indexPaths];
//                    } completion:nil];
//            } else if ([kind integerValue] == NSKeyValueChangeRemoval)
//            {
//                [selfRef.collectionView performBatchUpdates:^{
//                    [selfRef.collectionView deleteItemsAtIndexPaths:indexPaths];
//                } completion:nil];
//            }
//        }
        
        [selfRef.collectionView reloadData];
//        
        return YES;
    }];
    
    return primaryToken;
    
}

- (AMBlockToken*)observeRowsInSection:(NSUInteger)sectionId array:(KVOMutableArray*)array
{
    typeof(self) __weak selfRef = self;
    // register KVO events
    AMBlockToken* token = [array addObserverWithTask:^BOOL(id obj, NSDictionary *change) {
        NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
        NSNumber *kind = change[NSKeyValueChangeKindKey];
        
        if (indexes == nil || indexes.count <= 0){
            return YES; // Nothing to do
        }
        
        NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:sectionId]];
            *stop = NO;
        }];
        
        
        if (indexPaths.count > 0)
        {
            if ([kind integerValue] == NSKeyValueChangeInsertion)
            {
                    // Need performBatchUpdates to avoid
                    // Fatal Exception: NSInternalInconsistencyException
                    // too many update animations on one view - limit is 31 in flight at a time
                    
                    [selfRef.collectionView performBatchUpdates:^{
                        [selfRef.collectionView insertItemsAtIndexPaths:indexPaths];
                    } completion:nil];
            } else if ([kind integerValue] == NSKeyValueChangeRemoval)
            {
                [selfRef.collectionView performBatchUpdates:^{
                    [selfRef.collectionView deleteItemsAtIndexPaths:indexPaths];
                } completion:nil];
            }
        }
        
        return YES;
    }];
    
    return token;
}

- (id)itemAtIndexPath:(NSIndexPath*)indexPath
{
    KVOMutableArray* array = self.data;
    if (YES == self.isNested) {
        if (self.data.count > indexPath.section) {
            array = SAFE_CAST(self.data[indexPath.section], KVOMutableArray);
        }
    }
    if (array.count > indexPath.row) {
        return array[indexPath.row];
    }
    NSAssert(NO, @"should not happen");
    return nil; // something goes wrong
}

#pragma mark - DataSource and Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (YES == self.isNested) {
        return self.data.count;
    }
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (YES == self.isNested) {
        if (self.data.count > section) {
            KVOMutableArray* array = SAFE_CAST(self.data[section], KVOMutableArray);
            return array.count;
        } else {
            // something goes wrong
            NSAssert(NO, @"should not happen");
            return 0;
        }
        
    } else {
        return self.data.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self dequeueCellAndBindInCollectionView:collectionView indexPath:indexPath];
}

- (UICollectionViewCell *)dequeueCellAndBindInCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    id<HFBindingViewDelegate> cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    id item = [self itemAtIndexPath:indexPath];
    if (item && [cell conformsToProtocol:@protocol(HFBindingViewDelegate)]) {
        [cell bindModel:item];
    }
    return (UICollectionViewCell *)cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath:indexPath];
    if (self.selectionBlock && item) {
        self.selectionBlock(item);
    }
}

@end
