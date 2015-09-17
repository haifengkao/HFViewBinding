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

#import <Foundation/Foundation.h>
@interface NSObject (NSObject_KVCExtensions)

- (BOOL)canSetValueForKey:(NSString *)key;
- (BOOL)canSetValueForKeyPath:(NSString *)keyPath;

@end

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
        NSArray* new = SAFE_CAST(change[NSKeyValueChangeNewKey], NSArray);
        
        if (indexes == nil || indexes.count <= 0){
            return YES; // Nothing to do
        }
        
        // stop the observation if the seciton is removed
        if ([kind integerValue] == NSKeyValueChangeRemoval){
            [selfObj deleteRowsAtIndexes:indexes tokens:selfObj.secondaryTokens];
            [selfObj deleteSections:indexes];
        } else if ([kind integerValue] == NSKeyValueChangeInsertion) {
            [selfObj insertRowsAtIndexes:indexes tokens:selfObj.secondaryTokens data:new];
            [selfObj insertSections:indexes];
        } else if ([kind integerValue] == NSKeyValueChangeReplacement) {
            [selfObj deleteRowsAtIndexes:indexes tokens:selfObj.secondaryTokens];
            [selfObj insertRowsAtIndexes:indexes tokens:selfObj.secondaryTokens data:new];
            [selfObj reloadSections:indexes];
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
    if (item && cell) {
        if ([cell conformsToProtocol:@protocol(HFBindingViewDelegate)]) {
            [cell bindModel:item];
        } else if ([item isKindOfClass:[NSDictionary class]]){
            [self defaultBindingToCell:cell model:item];
        }
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

- (void)insertSections:(NSIndexSet*)indexes
{
    NSAssert(NO, @"abstract function");
}

- (void)deleteSections:(NSIndexSet*)indexes
{
    NSAssert(NO, @"abstract function");
}

- (void)reloadSections:(NSIndexSet*)indexes
{
    NSAssert(NO, @"abstract function");
}

#pragma mark - private
- (void)insertRowsAtIndexes:(NSIndexSet*)indexes tokens:(NSMutableArray*)tokens data:(NSArray*)new
{
    NSMutableArray* toBeAddedTokens = [NSMutableArray new];
    
    // observe the new rows
    NSUInteger __block itemId = 0;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger sectionId, BOOL *stop) {
        AMBlockToken* token = [self observeRowsInSection:sectionId array:new[itemId]];
        
        [toBeAddedTokens addObject:token];
        ++itemId;
        *stop = NO;
    }];
    
    [tokens insertObjects:toBeAddedTokens atIndexes:indexes];
}

- (void)deleteRowsAtIndexes:(NSIndexSet*)indexes tokens:(NSMutableArray*)tokens
{
    NSArray* beRemovedTokens = [tokens objectsAtIndexes:indexes];
    for (AMBlockToken* token in beRemovedTokens) {
        [token removeObserver];
    }
    [tokens removeObjectsAtIndexes:indexes];
}

#pragma mark - prototye helpers
- (void)defaultBindingToCell:(id)object model:(NSDictionary*)model
{
    [model enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull theKey, id  _Nonnull theObj, BOOL * _Nonnull stop) {
        if ([theKey isKindOfClass:[NSString class]]) {
            NSString* key = theKey;
            id obj = theObj;
            // TODO: check the target object type
            if ([object canSetValueForKeyPath:key]) {
                if ([key containsString:@".image"]) {
                    // check the image path
                    obj = [UIImage imageNamed:theObj];
                }
                [object setValue:obj forKeyPath:key];
            }
        }
    }];
}
@end

#import <objc/runtime.h>

@implementation NSObject (NSObject_KVCExtensions)


// Can set value for key follows the Key Value Settings search pattern as defined
// in the apple documentation
- (BOOL)canSetValueForKey:(NSString *)key {
    // Check if there is a selector based setter
    NSString *capKey = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[key substringToIndex:1] uppercaseString]];
    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@:", capKey]);
    if ([self respondsToSelector:setter]) {
        return YES;
    }
    
    // If you can access the instance variable directly, check if that exists
    // Patterns for instance variable naming:
    //  1. _<key>
    //  2. _is<Key>
    //  3. <key>
    //  4. is<Key>
    if ([[self class] accessInstanceVariablesDirectly]) {
        // Declare all the patters for the key
        const char *pattern1 = [[NSString stringWithFormat:@"_%@",key] UTF8String];
        const char *pattern2 = [[NSString stringWithFormat:@"_is%@",capKey] UTF8String];
        const char *pattern3 = [[NSString stringWithFormat:@"%@",key] UTF8String];
        const char *pattern4 = [[NSString stringWithFormat:@"is%@",capKey] UTF8String];
        
        unsigned int numIvars = 0;
        Ivar *ivarList = class_copyIvarList([self class], &numIvars);
        for (unsigned int i = 0; i < numIvars; i++) {
            const char *name = ivar_getName(*ivarList);
            if (strcmp(name, pattern1) == 0 ||
                strcmp(name, pattern2) == 0 ||
                strcmp(name, pattern3) == 0 ||
                strcmp(name, pattern4) == 0) {
                return YES;
            }
            ivarList++;
        }
    }
    
    return NO;
}

// Traverse the key path finding you can set the values
// Keypath is a set of keys delimited by "."
- (BOOL)canSetValueForKeyPath:(NSString *)keyPath {
    NSRange delimeterRange = [keyPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    
    if (delimeterRange.location == NSNotFound) {
        return [self canSetValueForKey:keyPath];
    }
    
    NSString *first = [keyPath substringToIndex:delimeterRange.location];
    NSString *rest = [keyPath substringFromIndex:(delimeterRange.location + 1)];
    
    if ([self canSetValueForKey:first]) {
        return [[self valueForKey:first] canSetValueForKeyPath:rest];
    }
    
    return NO;
}

@end