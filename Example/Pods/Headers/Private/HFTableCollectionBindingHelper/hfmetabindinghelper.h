//
//  HFMetaBindingHelper.h
//  SpicyGymLog
//
//  Created by Lono on 2015/5/30.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KVOMutableArray.h"

typedef void (^HFSelectionBlock)(id model);

@interface HFMetaBindingHelper : NSObject

@property (nonatomic, strong) KVOMutableArray* data;
@property (nonatomic, copy) HFSelectionBlock selectionBlock;

- (instancetype)initForSourceList:(KVOMutableArray *)source
                    didSelectionBlock:(HFSelectionBlock)block
                         isNested:(BOOL)isNested NS_DESIGNATED_INITIALIZER;
@end