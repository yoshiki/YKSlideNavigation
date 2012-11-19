//
//  PageOneViewController.m
//  YKSlideNavigationDemo
//
//  Created by Yoshiki Kurihara on 12/11/19.
//  Copyright (c) 2012年 Yoshiki Kurihara. All rights reserved.
//

#import "PageOneViewController.h"

@implementation PageOneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Page 1";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [nextButton setTitle:@"Next page" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(pushNextPage:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton sizeToFit];
    [self.view addSubview:nextButton];
    nextButton.center = CGPointMake(self.view.center.x, self.view.center.y - 44.0f);
}

- (void)pushNextPage:(id)sender {
    UIViewController *c = [[UIViewController alloc] init];
    c.view.backgroundColor = [UIColor whiteColor];
    c.title = @"Page 1-2";
    [self.navigationController pushViewController:c animated:YES];
}

@end
