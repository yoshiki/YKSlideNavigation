//
//  MenuViewController.m
//  YKSlideNavigationDemo
//
//  Created by Yoshiki Kurihara on 12/11/19.
//  Copyright (c) 2012年 Yoshiki Kurihara. All rights reserved.
//

#import "MenuViewController.h"
#import "YKSlideNavigationController.h"
#import "PageOneViewController.h"
#import "PageTwoViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Page %d", indexPath.row + 1];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            PageOneViewController *c = [[PageOneViewController alloc] init];
            [[YKSlideNavigationController sharedController] setChildViewController:c];
            break;
        }
        case 1: {
            PageTwoViewController *c = [[PageTwoViewController alloc] init];
            [[YKSlideNavigationController sharedController] setChildViewController:c];
        }
        default:
            break;
    }
}

@end
