//
//  HFViewController.m
//  HFTableCollectionBindingHelper
//
//  Created by Hai Feng Kao on 06/02/2015.
//  Copyright (c) 2014 Hai Feng Kao. All rights reserved.
//

#import "HFViewController.h"
#import "KVOMutableArray.h"
#import "HFTableViewBindingHelper.h"
#import "ItemCell.h"


@interface HFViewController ()
@property (nonatomic, strong) KVOMutableArray* data;
@property (nonatomic, strong) HFTableViewBindingHelper* bindingHelper;
@end

@implementation HFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = [KVOMutableArray new];
    Item *item = [Item new];
    item.name = @"table view demo";
    item.viewControllerId = @"TableViewSegue";
    [self.data addObject:item];
    
    Item* item2 = [Item new];
    item2.name = @"grouped table view demo";
    item2.viewControllerId = @"GroupTableViewSegue";
    [self.data addObject:item2];
    
    Item* item3 = [Item new];
    item3.name = @"collection view demo";
    item3.viewControllerId = @"CollectionViewSegue";
    [self.data addObject:item3];
    
	// Do any additional setup after loading the view, typically from a nib.
    typeof(self) __weak selfRef = self;
    self.bindingHelper = [HFTableViewBindingHelper bindingForTableView:self.tableView sourceList:self.data didSelectionBlock:^(id model) {
        typeof(self) self = selfRef;
        [self showDetail:model];
        
    } templateCellClassName:@"ItemCell"
                  isNested:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showDetail:(id)model
{
    Item* item = (Item*)model;
    [self performSegueWithIdentifier:item.viewControllerId sender:self];
}

@end
