//
//  HFTableViewBindingHelper.m
//  SpicyGymLog
//
//  Created by Lono on 2015/5/30.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import "HFTableViewBindingHelper.h"
#import "HFBindViewDelegate.h"

#if !defined(SAFE_CAST)
#define SAFE_CAST(Object, Type) (Type *)safe_cast_helper(Object, [Type class])
static inline id safe_cast_helper(id x, Class c) {
    return [x isKindOfClass:c] ? x : nil;
}
#endif

@interface HFTableViewBindingHelper ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) UITableViewCell* templateCell;

@property (nonatomic, copy) NSString * cellIdentifier;
@property (nonatomic, strong) AMBlockToken* primaryToken;
@property (nonatomic, strong) NSMutableArray* secondaryTokens;
@property (nonatomic, assign) BOOL isNested;
@end

@implementation HFTableViewBindingHelper

+ (instancetype)bindingForTableView:(UITableView *)tableView sourceList:(KVOMutableArray*)source didSelectionBlock:(TableSelectionBlock)block templateCellClassName:(NSString *)templateCellClass {
    return [[self alloc] initWithTableView:tableView sourceList:source didSelectionBlock:block templateCellClassName:templateCellClass];
}

- (instancetype)initWithTableView:(UITableView *)tableView sourceList:(KVOMutableArray*)source didSelectionBlock:(TableSelectionBlock)block {
    NSParameterAssert(tableView);
    NSParameterAssert(source);
    self = [super init];
    if (self) {
        _tableView = tableView;
        _data = source;
        _selectionBlock = [block copy];
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView sourceList:(KVOMutableArray*)source didSelectionBlock:(TableSelectionBlock)block templateCellClassName:(NSString *)templateCellClass {
    self = [self initWithTableView:tableView sourceList:source didSelectionBlock:block];
    if (self) {
        self.cellIdentifier = templateCellClass;
        [tableView registerClass:NSClassFromString(templateCellClass) forCellReuseIdentifier:templateCellClass];
        
    }
    return self;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self dequeueCellAndBindInTable:tableView indexPath:indexPath];
}

- (UITableViewCell *)dequeueCellAndBindInTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSString* reuseIdentifier = _templateCell.reuseIdentifier ?: self.cellIdentifier;
    UITableViewCell<HFBindViewDelegate>* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    [cell bindModel:_data[indexPath.row]];
    return (UITableViewCell *)cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemAtIndexPath:indexPath];
    if (self.selectionBlock && item) {
        self.selectionBlock(item);
    }
}


#pragma mark - private
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
@end
