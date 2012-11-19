//
//  YKSlideNavigationController.h
//  YKSlideNavigationDemo
//
//  Created by Yoshiki Kurihara on 12/11/19.
//  Copyright (c) 2012年 Yoshiki Kurihara. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kYKSlideNavigationControllerNotificationMenuOpened @"kSlideNavigationControllerNotificationMenuOpened"
#define kYKSlideNavigationControllerNotificationMenuClosed @"kSlideNavigationControllerNotificationMenuClosed"

typedef enum {
    YKSlideNavigationOptionMenuMaskEnabled = 1 << 0,
    YKSlideNavigationOptionShadowEnabled   = 1 << 1,
} YKSlideNavigationOptions;

@interface YKSlideNavigationController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIViewController *menuViewController;
@property (nonatomic, getter = isMenuOpened) BOOL menuOpened;
@property (strong, nonatomic) UIBarButtonItem *menuButtonItem;
@property (strong, nonatomic) UIBarButtonItem *backButtonItem;

+ (id)sharedController;

- (void)setupWithNavigationController:(UINavigationController *)navigationController
                   menuViewController:(UIViewController *)menuViewController;
- (void)setupWithNavigationController:(UINavigationController *)navigationController
                   menuViewController:(UIViewController *)menuViewController
                       menuButtonItem:(UIBarButtonItem *)menuButtonItem
                       backButtonItem:(UIBarButtonItem *)backButtonItem
                              options:(YKSlideNavigationOptions)options;
- (void)clickedMenu:(id)sender;
- (void)clickedBack:(id)sender;
- (void)closeMenu;
- (void)openMenu;
- (void)setChildViewController:(UIViewController *)viewController;
- (void)updateLeftBarButtonItem;

@end
