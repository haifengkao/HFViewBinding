//
//  HFGroupTableViewController.m
//  HFTableCollectionBindingHelper
//
//  Created by Lono on 2015/6/5.
//  Copyright (c) 2015年 Hai Feng Kao. All rights reserved.
//

#import "HFGroupTableViewController.h"
#import "HFTableViewBindingHelper.h"
#import "Item.h"

@interface HFGroupTableViewController ()
@property (nonatomic, strong) KVOMutableArray* data;
@property (nonatomic, strong) HFTableViewBindingHelper* bindingHelper;
@end

@implementation HFGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.data = [KVOMutableArray new];
    Item *item = [Item new];
    item.name = @"cell 1 1";
    
    KVOMutableArray* row1 = [KVOMutableArray new];
    [row1 addObject:item];
    
    KVOMutableArray* row2 = [KVOMutableArray new];
    Item *item2 = [Item new];
    item2.name = @"cell 2 1";
    [row2 addObject:item2];
    
    [self.data addObject:row1];
    [self.data addObject:row2];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.bindingHelper = [HFTableViewBindingHelper bindingForTableView:self.tableView sourceList:self.data didSelectionBlock:^(id model) {
        
    } templateCellClassName:@"ItemCell"
                                                              isNested:YES];
    
    self.bindingHelper.delegate = self;
    self.bindingHelper.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)add:(id)sender
{
    if (self.data.count == 0)
    {
        // add a new section
        KVOMutableArray* row = [KVOMutableArray new];
        [self.data addObject:row];
    }
    
    NSInteger lastRowItemNum = [(KVOMutableArray*)[self.data.arr lastObject] count];
    Item* item = [Item new];
    
    item.name = [NSString stringWithFormat:@"cell %d %d", self.data.count, lastRowItemNum+1];
    [(KVOMutableArray*)[self.data.arr lastObject] addObject:item];
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
    NSUInteger index = arc4random()%self.data.count;
    
    if (self.data.count > index) {
        KVOMutableArray* row = [KVOMutableArray new];
        self.data[index] = row;
    }
}

- (IBAction)addSection:(id)sender
{
    KVOMutableArray* row = [KVOMutableArray new];
    [self.data addObject:row];
}

- (IBAction)deleteSection:(id)sender
{
    if (self.data.count > 0) {
        [self.data removeLastObject];
    }
}
#pragma mark - Table view data source

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
