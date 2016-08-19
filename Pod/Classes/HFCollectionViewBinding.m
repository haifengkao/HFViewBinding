//
//  HFCollectionViewBinding.m
//  SpicyGymLog
//
//  Created by Hai Feng Kao on 2015/5/21.
//  Copyright (c) 2015年 CocoaSpice. All rights reserved.
//

#import "HFCollectionViewBinding.h"
#import "KVOMutableArray.h"
#import "HFMetaBinding.h"
#import "HFBindingDelegate.h"
#import "WZProtocolInterceptor.h"

@interface HFCollectionViewBinding()
@property (nonatomic, weak) UICollectionViewCell* templateCell;
@property (nonatomic, copy) NSString * cellIdentifier;
@property (nonatomic, strong) WZProtocolInterceptor* delegateInterceptor;
@property (nonatomic, strong) WZProtocolInterceptor* dataSourceInterceptor;
@end

@implementation HFCollectionViewBinding

+ (instancetype)bindingForCollectionView:(UICollectionView *)collectionView
                         sourceList:(KVOMutableArray*)source
                  didSelectionBlock:(HFSelectionBlock)block
              templateCellClassName:(NSString *)templateCellClass
                           isNested:(BOOL)isNested
{
    return [[self alloc] initWithCollectionView:collectionView
                                sourceList:source
                         didSelectionBlock:block
                     templateCellClassName:templateCellClass
                                  isNested:isNested];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                       sourceList:(KVOMutableArray*)source
                didSelectionBlock:(HFSelectionBlock)block
            templateCellClassName:(NSString *)templateCellClass
                         isNested:(BOOL)isNested
{
    self = [self initWithCollectionView:collectionView sourceList:source didSelectionBlock:block isNested:isNested];
    if (self) {
        _cellIdentifier = templateCellClass;
        [collectionView registerClass:NSClassFromString(templateCellClass) forCellWithReuseIdentifier:templateCellClass];
    }
    return self;
}

+ (instancetype)bindingForCollectionView:(UICollectionView *)collectionView
                              sourceList:(KVOMutableArray*)source
                       didSelectionBlock:(HFSelectionBlock)block
                         cellReuseIdentifier:(NSString *)reuseIdentifier
                                isNested:(BOOL)isNested
{
    return [[self alloc] initWithCollectionView:collectionView
                                     sourceList:source
                              didSelectionBlock:block
                                cellReuseIdentifier:reuseIdentifier
                                       isNested:isNested];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                            sourceList:(KVOMutableArray*)source
                     didSelectionBlock:(HFSelectionBlock)block
                       cellReuseIdentifier:(NSString *)reuseIdentifier
                              isNested:(BOOL)isNested
{
    self = [self initWithCollectionView:collectionView sourceList:source didSelectionBlock:block isNested:isNested];
    if (self) {
        _cellIdentifier = reuseIdentifier;
    }
    return self;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                       sourceList:(KVOMutableArray*)source
                didSelectionBlock:(HFSelectionBlock)block
                         isNested:(BOOL)isNested
{
    NSParameterAssert(collectionView);
    self = [super initForSourceList:source didSelectionBlock:block isNested:isNested];
    if (!self) return nil;
    
    _collectionView = collectionView;
    
    [self setDelegate:collectionView.delegate]; // init collectionView's dataSource and delegagte
    [self setDataSource:collectionView.dataSource];
    
    return self;
}

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource
{
    _dataSource = dataSource;
    WZProtocolInterceptor* dataSourceInterceptor = [[WZProtocolInterceptor alloc]
                                                    initWithInterceptedProtocol:@protocol(UICollectionViewDataSource)];
    dataSourceInterceptor.middleMan = self;
    dataSourceInterceptor.receiver = dataSource;
    _dataSourceInterceptor = dataSourceInterceptor;
    _collectionView.dataSource = (id<UICollectionViewDataSource>) dataSourceInterceptor;
}

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate
{
    _delegate = delegate;
    WZProtocolInterceptor* delegateInterceptor = [[WZProtocolInterceptor alloc]
                                                  initWithInterceptedProtocol:@protocol(UICollectionViewDelegate)];
    delegateInterceptor.middleMan = self;
    delegateInterceptor.receiver = delegate;
    _delegateInterceptor = delegateInterceptor;
    
    _collectionView.delegate = (id<UICollectionViewDelegate>)delegateInterceptor;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [super numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [super numberOfItemsInSection:section];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<HFBindingDelegate> cell = [super cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[UICollectionViewCell class]]) {
        return (UICollectionViewCell*)cell;
    } else {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super didSelectItemAtIndexPath:indexPath];
}

#pragma mark - protected
- (void)reloadData
{
    [self.collectionView reloadData];
}

- (id<HFBindingDelegate>)dequeueReusableCellWithIndexPath:(NSIndexPath*)indexPath
{
    id<HFBindingDelegate> cell = [self.collectionView
                                      dequeueReusableCellWithReuseIdentifier:self.cellIdentifier
                                      forIndexPath:indexPath];
    return cell;
}
@end
