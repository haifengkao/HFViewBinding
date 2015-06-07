//
//  HFMetaBindingHelper.h
//  SpicyGymLog
//
//  Created by Lono on 2015/5/30.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KVOMutableArray.h"
#import "HFBindingViewDelegate.h"

typedef void (^HFSelectionBlock)(id model);

@interface HFMetaBindingHelper : NSObject

@property (nonatomic, strong) KVOMutableArray* data;
@property (nonatomic, copy) HFSelectionBlock selectionBlock;

- (instancetype)initForSourceList:(KVOMutableArray *)source
                    didSelectionBlock:(HFSelectionBlock)block
                         isNested:(BOOL)isNested NS_DESIGNATED_INITIALIZER;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (id<HFBindingViewDelegate>)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isNested;
#pragma mark - protected
- (void)reloadData;
- (void)insertItemsAtIndexPaths:(NSArray*)indexPaths;
- (void)deleteItemsAtIndexPaths:(NSArray*)indexPaths;
- (void)reloadItemsAtIndexPaths:(NSArray*)indexPaths;
- (id<HFBindingViewDelegate>)dequeueReusableCellWithIndexPath:(NSIndexPath*)indexPath;
- (void)insertSections:(NSIndexSet*)indexes;
- (void)deleteSections:(NSIndexSet*)indexes;
- (void)reloadSections:(NSIndexSet*)indexes;
@end