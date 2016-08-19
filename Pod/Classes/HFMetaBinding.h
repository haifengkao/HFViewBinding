//
//  HFMetaBinding.h
//  SpicyGymLog
//
//  Created by Hai Feng Kao on 2015/5/30.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KVOMutableArray;
@protocol HFBindingDelegate;

typedef void (^HFSelectionBlock)(id model);

@interface HFMetaBinding : NSObject

@property (nonatomic, strong) KVOMutableArray* data;
@property (nonatomic, copy) HFSelectionBlock selectionBlock;

- (instancetype)initForSourceList:(KVOMutableArray *)source
                    didSelectionBlock:(HFSelectionBlock)block
                         isNested:(BOOL)isNested NS_DESIGNATED_INITIALIZER;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (id<HFBindingDelegate>)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isNested;
#pragma mark - protected
- (void)reloadData;
- (void)insertItemsAtIndexPaths:(NSArray*)indexPaths;
- (void)deleteItemsAtIndexPaths:(NSArray*)indexPaths;
- (void)reloadItemsAtIndexPaths:(NSArray*)indexPaths;
- (id<HFBindingDelegate>)dequeueReusableCellWithIndexPath:(NSIndexPath*)indexPath;
- (void)insertSections:(NSIndexSet*)indexes;
- (void)deleteSections:(NSIndexSet*)indexes;
- (void)reloadSections:(NSIndexSet*)indexes;
@end
