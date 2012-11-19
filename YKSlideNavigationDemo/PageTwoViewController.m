//
//  PageTwoViewController.m
//  YKSlideNavigationDemo
//
//  Created by Yoshiki Kurihara on 12/11/19.
//  Copyright (c) 2012年 Yoshiki Kurihara. All rights reserved.
//

#import "PageTwoViewController.h"
#import "YKSlideNavigationController.h"

@implementation PageTwoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Page 2";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *openMenuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [openMenuButton setTitle:@"Open menu" forState:UIControlStateNormal];
    [openMenuButton addTarget:self action:@selector(pushOpenMenu:) forControlEvents:UIControlEventTouchUpInside];
    [openMenuButton sizeToFit];
    [self.view addSubview:openMenuButton];
    openMenuButton.center = CGPointMake(self.view.center.x, self.view.center.y - 44.0f);
}

- (void)pushOpenMenu:(id)sender {
    [[YKSlideNavigationController sharedController] openMenu];
}

@end
