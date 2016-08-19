//
//  ItemCell.m
//  HFTableCollectionBindingHelper
//
//  Created by Hai Feng Kao on 2015/6/4.
//  Copyright (c) 2015年 Hai Feng Kao. All rights reserved.
//

#import "ItemCell.h"
#import "HFBindingViewDelegate.h"

@interface ItemCell()<HFBindingViewDelegate>

@end
@implementation ItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    // workaround: ios 8 uitableview doesn't load the style settings in storyboard
    ItemCell* cell = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)bindModel:(id)model
{
    Item* item = (Item*)model;
    self.textLabel.text = item.name;
}

@end
