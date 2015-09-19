//
//  HFTableViewBindingHelper.m
//  SpicyGymLog
//
//  Created by Lono on 2015/5/30.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import "HFTableViewBindingHelper.h"
#import "HFBindingViewDelegate.h"
#import "WZProtocolInterceptor.h"

@interface HFTableViewBindingHelper ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) UITableViewCell* templateCell;
@property (nonatomic, copy) NSString * cellIdentifier;
@property (nonatomic, strong) WZProtocolInterceptor* delegateInterceptor;
@property (nonatomic, strong) WZProtocolInterceptor* dataSourceInterceptor;
@end

@implementation HFTableViewBindingHelper

+ (instancetype)bindingForTableView:(UITableView *)tableView
                         sourceList:(KVOMutableArray*)source
                  didSelectionBlock:(HFSelectionBlock)block
              templateCellClassName:(NSString *)templateCellClass
                           isNested:(BOOL)isNested
{
    return [[self alloc] initWithTableView:tableView
                                sourceList:source
                         didSelectionBlock:block
                     templateCellClassName:templateCellClass
                                  isNested:isNested];
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

+ (instancetype)bindingForTableView:(UITableView *)tableView
                         sourceList:(KVOMutableArray*)source
                  didSelectionBlock:(HFSelectionBlock)block
                       templateCell:(UINib *)templateCellNib
                           isNested:(BOOL)isNested
{
    // create an instance of the template cell and register with the table view
    UITableViewCell* templateCell = [[templateCellNib instantiateWithOwner:nil options:nil] firstObject];
    [tableView registerNib:templateCellNib forCellReuseIdentifier:templateCell.reuseIdentifier];
    
    tableView.rowHeight = templateCell.bounds.size.height;
    return [[self alloc] initWithTableView:tableView sourceList:source didSelectionBlock:block cellReuseIdentifier:templateCell.reuseIdentifier isNested:isNested];
}

// use the template cell to set the row height

+ (instancetype)bindingForTableView:(UITableView *)tableView
                         sourceList:(KVOMutableArray*)source
                  didSelectionBlock:(HFSelectionBlock)block
                cellReuseIdentifier:(NSString *)reuseIdentifier
                           isNested:(BOOL)isNested
{
    return [[self alloc] initWithTableView:tableView sourceList:source didSelectionBlock:block cellReuseIdentifier:reuseIdentifier isNested:isNested];
}

- (instancetype)initWithTableView:(UITableView *)tableView
                       sourceList:(KVOMutableArray*)source
                didSelectionBlock:(HFSelectionBlock)block
            cellReuseIdentifier:(NSString *)reuseIdentifier
                         isNested:(BOOL)isNested
{
    self = [self initWithTableView:tableView sourceList:source didSelectionBlock:block isNested:isNested];
    if (self) {
        _cellIdentifier = reuseIdentifier;
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
    
    [self setDelegate:tableView.delegate]; // init tableView's dataSource and delegagte
    [self setDataSource:tableView.dataSource];
    
    return self;
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource
{
    _dataSource = dataSource;
    WZProtocolInterceptor* dataSourceInterceptor = [[WZProtocolInterceptor alloc]
                                                 initWithInterceptedProtocol:@protocol(UITableViewDataSource)];
    dataSourceInterceptor.middleMan = self;
    dataSourceInterceptor.receiver = dataSource;
    _dataSourceInterceptor = dataSourceInterceptor;
    _tableView.dataSource = (id<UITableViewDataSource>) dataSourceInterceptor;
}

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    _delegate = delegate;
    WZProtocolInterceptor* delegateInterceptor = [[WZProtocolInterceptor alloc]
                                                 initWithInterceptedProtocol:@protocol(UITableViewDelegate)];
    delegateInterceptor.middleMan = self;
    delegateInterceptor.receiver = delegate;
    _delegateInterceptor = delegateInterceptor;
    
    _tableView.delegate = (id<UITableViewDelegate>)delegateInterceptor;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [super numberOfSections];
}

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

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    KVOMutableArray* fromRow = self.data;
    KVOMutableArray* toRow = self.data;
    
    if (self.isNested) {
        if (fromIndexPath.section >= self.data.count || toIndexPath.section >= self.data.count)
        {
            return;
        }
        
        fromRow = self.data[fromIndexPath.section];
        toRow = self.data[toIndexPath.section];
    }
    
    // do NOT trigger KVO, otherwise the Cells will be moved again
    id fromObj = fromRow[fromIndexPath.row];
    [fromRow.arr removeObjectAtIndex:fromIndexPath.row];
    [toRow.arr insertObject:fromObj atIndex:toIndexPath.row];
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

- (void)insertSections:(NSIndexSet*)indexes
{
    [self.tableView insertSections:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteSections:(NSIndexSet*)indexes
{
    [self.tableView deleteSections:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadSections:(NSIndexSet*)indexes
{
    [self.tableView reloadSections:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end
