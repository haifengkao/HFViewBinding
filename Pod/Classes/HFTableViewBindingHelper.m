//
//  HFTableViewBindingHelper.m
//  SpicyGymLog
//
//  Created by Lono on 2015/5/30.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import "HFTableViewBindingHelper.h"
#import "HFBindingViewDelegate.h"

@interface HFTableViewBindingHelper ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) UITableViewCell* templateCell;
@property (nonatomic, copy) NSString * cellIdentifier;
@end

@implementation HFTableViewBindingHelper

+ (instancetype)bindingForTableView:(UITableView *)tableView
                         sourceList:(KVOMutableArray*)source
                  didSelectionBlock:(HFSelectionBlock)block
              templateCellClassName:(NSString *)templateCellClass
                           isNested:(BOOL)isNested
{
    return [[self alloc] initWithTableView:tableView sourceList:source didSelectionBlock:block templateCellClassName:templateCellClass isNested:isNested];
}

- (instancetype)initWithTableView:(UITableView *)tableView
                       sourceList:(KVOMutableArray*)source
                didSelectionBlock:(HFSelectionBlock)block
            templateCellClassName:(NSString *)templateCellClass
                         isNested:(BOOL)isNested
{
    self = [self initWithTableView:tableView sourceList:source didSelectionBlock:block isNested:isNested];
    if (self) {
        _cellIdentifier = templateCellClass;
        [tableView registerClass:NSClassFromString(templateCellClass) forCellReuseIdentifier:templateCellClass];
    }
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView
                       sourceList:(KVOMutableArray*)source
                didSelectionBlock:(HFSelectionBlock)block
                         isNested:(BOOL)isNested
{
    NSParameterAssert(tableView);
    self = [super initForSourceList:source didSelectionBlock:block isNested:isNested];
    if (!self) return nil;
    
    _tableView = tableView;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    return self;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<HFBindingViewDelegate> cell = [super cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        return (UITableViewCell*)cell;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        KVOMutableArray* data = self.data;
        if (self.isNested) {
            if (self.data.count > indexPath.section) {
                id row = self.data[indexPath.section];
                if ([row isKindOfClass:[KVOMutableArray class]]) {
                    data = row;
                }
            }
        }
        
        if (data.count > indexPath.row) {
            [data removeObjectAtIndex:indexPath.row];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSAssert(NO, @"TODO");
    }
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super didSelectItemAtIndexPath:indexPath];
}

#pragma mark - protected
- (void)reloadData
{
    [self.tableView reloadData];
}
- (void)insertItemsAtIndexPaths:(NSArray*)indexPaths
{
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
}

- (void)deleteItemsAtIndexPaths:(NSArray*)indexPaths
{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
}

- (void)reloadItemsAtIndexPaths:(NSArray*)indexPaths
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (id<HFBindingViewDelegate>)dequeueReusableCellWithIndexPath:(NSIndexPath*)indexPath
{
    id<HFBindingViewDelegate> cell = [self.tableView
                                      dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                           forIndexPath:indexPath];
    return cell;
}

@end
