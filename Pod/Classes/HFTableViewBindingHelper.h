//
//  HFTableViewBindingHelper.h
//  SpicyGymLog
//
//  Created by Lono on 2015/5/30.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HFMetaBindingHelper.h"

@interface HFTableViewBindingHelper : HFMetaBindingHelper

@property (nonatomic, weak) UITableView* tableView;
+ (instancetype)bindingForTableView:(UITableView *)tableView
                         sourceList:(KVOMutableArray*)source
                  didSelectionBlock:(HFSelectionBlock)block
              templateCellClassName:(NSString *)templateCellClass
                           isNested:(BOOL)isNested;
@end
