//
//  HFCollectionViewController.m
//  HFTableCollectionBindingHelper
//
//  Created by Lono on 2015/8/6.
//  Copyright (c) 2015年 Hai Feng Kao. All rights reserved.
//

#import "HFCollectionViewController.h"
#import "HFcollectionViewBindingHelper.h"

@interface HFCollectionViewCell : UICollectionViewCell<HFBindingViewDelegate>

@end

@implementation HFCollectionViewCell
- (void)bindModel:(id)model
{
    self.backgroundColor = model;
}
@end

@interface HFCollectionViewController ()
@property HFCollectionViewBindingHelper* bindingHelper;
@property KVOMutableArray* data;
@end

@implementation HFCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.data = [KVOMutableArray new];
    [self.data addObject:[UIColor redColor]];
    [self.data addObject:[UIColor blackColor]];
    [self.data addObject:[UIColor blueColor]];
    [self.data addObject:[UIColor purpleColor]];
    [self.data addObject:[UIColor greenColor]];
    [self.data addObject:[UIColor yellowColor]];
    [self.data addObject:[UIColor cyanColor]];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.bindingHelper = [HFCollectionViewBindingHelper
                          bindingForCollectionView:self.collectionView
                          sourceList:self.data
                          didSelectionBlock:^(id model) {
        
                              NSLog(@"select %@", model);
                            }
                          cellReuseIdentifier:reuseIdentifier
                                                 isNested:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//#pragma mark <UICollectionViewDataSource>
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//#warning Incomplete method implementation -- Return the number of sections
//    return 0;
//}
//
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//#warning Incomplete method implementation -- Return the number of items in the section
//    return 0;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell
//    
//    return cell;
//}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
