//
//  HFTableViewBindingHelper.h
//  SpicyGymLog
//
//  Created by Lono on 2015/5/30.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KVOMutableArray.h>

typedef void (^TableSelectionBlock)(id model);

@interface HFTableViewBindingHelper : NSObject

@property (nonatomic, strong) KVOMutableArray* data;
@property (nonatomic, copy) TableSelectionBlock selectionBlock;
@property (nonatomic, weak) UITableView* tableView;

@end
