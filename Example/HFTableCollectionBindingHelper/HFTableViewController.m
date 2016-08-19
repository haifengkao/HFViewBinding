//
//  HFTableViewController.m
//  HFViewBinding
//
//  Created by Hai Feng Kao on 2015/6/4.
//  Copyright (c) 2015年 Hai Feng Kao. All rights reserved.
//

#import "HFTableViewController.h"
#import "KVOMutableArray.h"
#import "HFTableViewBinding.h"
#import "ItemCell.h"

@interface HFTableViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) KVOMutableArray* data;
@property (nonatomic, strong) HFTableViewBinding* bindingHelper;
@property (nonatomic, assign) NSInteger count; // track the dummy cell number
@end

@implementation HFTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.data = [KVOMutableArray new];
    Item *item = [Item new];
    item.name = @"cell 1";
    [self.data addObject:item];
    
    self.count = 2;
    
    // Do any additional setup after loading the view, typically from a nib.
    self.bindingHelper = [HFTableViewBinding bindingForTableView:self.tableView sourceList:self.data didSelectionBlock:^(id model) {
        
    } templateCellClassName:@"ItemCell"
    isNested:NO];
    
    self.bindingHelper.delegate = self;
    self.bindingHelper.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)add:(id)sender
{
    
    Item* item = [Item new];
    item.name = [NSString stringWithFormat:@"cell %ld", (long)self.count];
    
    [self.data addObject:item];
    ++self.count;
}

- (IBAction)edit:(id)sender
{
    if (self.editing) {
        [self setEditing:NO animated:YES];
    }else {
        [self setEditing:YES animated:YES];
    }
}

- (IBAction)replace:(id)sender
{
    NSUInteger index = NSNotFound;
    for (NSUInteger i = 0; i < self.data.count; ++i) {
        Item* item = self.data[i];
        if (item.name.length > 0 && [item.name characterAtIndex:0] != 'r') {
            index = i;
            break;
            
        }
    }
    
    if (index != NSNotFound) {
        Item* item = self.data[index];
        NSString* name = [item.name stringByReplacingOccurrencesOfString:@"cell" withString:@"replaced"];
        Item* newItem = [Item new];
        newItem.name = name;
        self.data[index] = newItem;
    }
    
}

- (IBAction)mess:(id)sender
{
    NSInteger type = arc4random() % 3;
    
    if (type == 0) {
        // messy add
        NSInteger num = MIN(arc4random() % 200, 50);
        NSMutableArray* items = [NSMutableArray new];;
        for (NSInteger i = 0; i < num; ++i) {
            Item* item = [Item new];
            item.name = [NSString stringWithFormat:@"cell %ld", (long)self.count];
            ++self.count;
            [items addObject:item];
        }
        [self.data addObjectsFromArray:items];
    } else if (type == 1) {
        // messy delete
        NSMutableIndexSet* set = [NSMutableIndexSet new];
        NSInteger num = MIN(arc4random() % self.data.count + 1, self.data.count);
        
        for (NSInteger i = 0; i < num; ++i) {
            [set addIndex:arc4random()%self.data.count];
        }
        [self.data removeObjectsAtIndexes:set];
    } else if(type == 2){
        // messy replace
        NSInteger num = arc4random() % self.data.count;
        NSMutableIndexSet* set = [NSMutableIndexSet new];
        for (NSInteger i = 0; i < num; ++i) {
            [set addIndex:arc4random()%self.data.count];
        }
        
        NSMutableArray* array = [NSMutableArray new];
        [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            Item* item = self.data[idx];
            Item* newItem = [Item new];
            newItem.name = [item.name stringByReplacingOccurrencesOfString:@"cell" withString:@"replaced"];
            [array addObject:newItem];
        }];
        
        [self.data replaceObjectsAtIndexes:set withObjects:array];
    }
}

#pragma mark - UITableViewDataSource

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
