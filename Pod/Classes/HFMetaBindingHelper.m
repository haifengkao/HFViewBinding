//
//  HFMetaBindingHelper.m
//  SpicyGymLog
//
//  Created by Lono on 2015/5/30.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import "HFMetaBindingHelper.h"
#import "HFBindingViewDelegate.h"

#if !defined(SAFE_CAST)
#define SAFE_CAST(Object, Type) (Type *)safe_cast_helper(Object, [Type class])
static inline id safe_cast_helper(id x, Class c) {
    return [x isKindOfClass:c] ? x : nil;
}
#endif

@interface HFMetaBindingHelper()
@property (nonatomic, strong) AMBlockToken* primaryToken;
@property (nonatomic, strong) NSMutableArray* secondaryTokens;
@property (nonatomic, assign) BOOL isNested;
@end

@implementation HFMetaBindingHelper

- (instancetype)initForSourceList:(KVOMutableArray *)source
                    didSelectionBlock:(HFSelectionBlock)block
                             isNested:(BOOL)isNested
{
    NSParameterAssert(source);
    
    self = [super init];
    if (!self) return nil;
    
    _data = source;
    _selectionBlock = [block copy];
    _isNested = isNested;
    _secondaryTokens = [NSMutableArray new];
    
    
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
    
    // observe the rows change event in each setction
    for (NSUInteger i = 0; i < array.count; ++i) {
        AMBlockToken* token = [self observeRowsInSection:i array:array[i]];
        [secondaryTokens addObject:token];
    }
    
    // observe the section change event
    AMBlockToken* primaryToken = [array addObserverWithTask:^BOOL(id obj, NSDictionary *change) {
        
        typeof(self) selfObj = selfRef;
        NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
        NSNumber *kind = change[NSKeyValueChangeKindKey];
        NSArray* new = change[NSKeyValueChangeNewKey];
        
        if (indexes == nil || indexes.count <= 0){
            return YES; // Nothing to do
        }
        
        // stop the observation if the seciton is removed
        if ([kind integerValue] == NSKeyValueChangeRemoval){
            NSArray* beRemovedTokens = [selfObj.secondaryTokens objectsAtIndexes:indexes];
            for (AMBlockToken* token in beRemovedTokens) {
                [token removeObserver];
            }
            [selfObj.secondaryTokens removeObjectsAtIndexes:indexes];
        } else if ([kind integerValue] == NSKeyValueChangeInsertion) {
            NSMutableArray* tokens = [NSMutableArray new];
            // observe the new rows
            
            NSUInteger __block itemId = 0;
            [indexes enumerateIndexesUsingBlock:^(NSUInteger sectionId, BOOL *stop) {
                AMBlockToken* token = [selfObj observeRowsInSection:sectionId array:new[itemId]];
                
                [tokens addObject:token];
                ++itemId;
                *stop = NO;
            }];
            
            [selfObj.secondaryTokens insertObjects:tokens atIndexes:indexes];
        }
        
        return YES;
    }];
    
    return primaryToken;
}

- (AMBlockToken*)observeRowsInSection:(NSUInteger)sectionId array:(KVOMutableArray*)array
{
    typeof(self) __weak selfRef = self;
    // register KVO events
    AMBlockToken* token = [array addObserverWithTask:^BOOL(id obj, NSDictionary *change) {
        typeof(self) selfObj = selfRef;
        
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
                [selfObj insertItemsAtIndexPaths:indexPaths];
                
            } else if ([kind integerValue] == NSKeyValueChangeRemoval)
            {
                [selfObj deleteItemsAtIndexPaths:indexPaths];
            } else if ([kind integerValue] == NSKeyValueChangeReplacement)
            {
                [selfObj reloadItemsAtIndexPaths:indexPaths];
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

- (NSInteger)numberOfSections
{
    if (YES == self.isNested) {
        return self.data.count;
    }
    return 1;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
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

- (id<HFBindingViewDelegate>)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self dequeueCellAndBindWithIndexPath:indexPath];
}

- (id<HFBindingViewDelegate>)dequeueCellAndBindWithIndexPath:(NSIndexPath *)indexPath {
    id<HFBindingViewDelegate> cell = [self dequeueReusableCellWithIndexPath:indexPath];
    
    id item = [self itemAtIndexPath:indexPath];
    if (item && [cell conformsToProtocol:@protocol(HFBindingViewDelegate)]) {
        [cell bindModel:item];
    }
    return cell;
}

- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id item = [self itemAtIndexPath:indexPath];
    if (self.selectionBlock && item) {
        self.selectionBlock(item);
    }
}

#pragma mark - protected
- (void)reloadData
{
    NSAssert(NO, @"abstract function");
    //self.collectionView reloadData
}

- (void)insertItemsAtIndexPaths:(NSArray*)indexPaths
{
    NSAssert(NO, @"abstract function");
                // Need performBatchUpdates to avoid
                // Fatal Exception: NSInternalInconsistencyException
                // too many update animations on one view - limit is 31 in flight at a time
//                [selfRef.collectionView performBatchUpdates:^{
//                    [selfRef.collectionView insertItemsAtIndexPaths:indexPaths];
//                } completion:nil];
}

- (void)deleteItemsAtIndexPaths:(NSArray*)indexPaths
{
    NSAssert(NO, @"abstract function");
//                [selfRef.collectionView performBatchUpdates:^{
//                    [selfRef.collectionView deleteItemsAtIndexPaths:indexPaths];
//                } completion:nil];
    
}

- (void)reloadItemsAtIndexPaths:(NSArray*)indexPaths
{
    NSAssert(NO, @"abstract function");
}
            
- (id<HFBindingViewDelegate>)dequeueReusableCellWithIndexPath:(NSIndexPath*)indexPath
{
    NSAssert(NO, @"abstract function");
    return nil;
}
@end