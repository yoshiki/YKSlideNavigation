//
//  YKSlideNavigationController.m
//  YKSlideNavigationDemo
//
//  Created by Yoshiki Kurihara on 12/11/19.
//  Copyright (c) 2012年 Yoshiki Kurihara. All rights reserved.
//

#import "YKSlideNavigationController.h"
#import <QuartzCore/QuartzCore.h>

#define kYKSlideNavigationMenuWidth 270.0f
#define kYKSlideNavigationMenuOpenCloseThreshold 0.5f
#define kYKSlideNavigationShadowWidth 10.0f
#define kYKSlideNavigationSlideDuration 0.1f

@interface YKSlideNavigationController ()

@property (nonatomic) CGPoint panGestureOrigin;
@property (nonatomic, strong) UIView *menuMaskView;
@property (nonatomic) YKSlideNavigationOptions options;

@end

@implementation YKSlideNavigationController

// Public property
@synthesize navigationController = _navigationController;
@synthesize menuViewController = _menuViewController;
@synthesize menuOpened = _menuOpened;
@synthesize menuButtonItem = _menuButtonItem;
@synthesize backButtonItem = _backButtonItem;

// Private property
@synthesize panGestureOrigin = _panGestureOrigin;
@synthesize menuMaskView = _menuMaskView;
@synthesize options = _options;

+ (UIImage *)defaultImage {
	static UIImage *defaultImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.0f, 16.0f), NO, 0.0f);
        
        CGFloat lineHeight = 3.0f;
        CGFloat lineWidth = 20.0f;
        
		[[UIColor blackColor] setFill];
		[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 1, lineWidth, lineHeight)
                               byRoundingCorners:UIRectCornerAllCorners
                                     cornerRadii:CGSizeMake(10.0f, 10.0f)] fill];
		[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 7, lineWidth, lineHeight)
                               byRoundingCorners:UIRectCornerAllCorners
                                     cornerRadii:CGSizeMake(10.0f, 10.0f)] fill];
		[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 13, lineWidth, lineHeight)
                               byRoundingCorners:UIRectCornerAllCorners
                                     cornerRadii:CGSizeMake(10.0f, 10.0f)] fill];
        
		[[UIColor whiteColor] setFill];
		[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, lineWidth, lineHeight)
                               byRoundingCorners:UIRectCornerAllCorners
                                     cornerRadii:CGSizeMake(10.0f, 10.0f)] fill];
		[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 6, lineWidth, lineHeight)
                               byRoundingCorners:UIRectCornerAllCorners
                                     cornerRadii:CGSizeMake(10.0f, 10.0f)] fill];
		[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 12, lineWidth, lineHeight)
                               byRoundingCorners:UIRectCornerAllCorners
                                     cornerRadii:CGSizeMake(10.0f, 10.0f)] fill];
        
		defaultImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        
	});
    return defaultImage;
}

+ (id)sharedController {
    static YKSlideNavigationController *_sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedController = [[YKSlideNavigationController alloc] init];
        _sharedController.navigationController = nil;
        _sharedController.menuViewController = nil;
        _sharedController.menuButtonItem = nil;
    });
    return _sharedController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.view.frame = self.view.bounds;
    
    CGRect menuViewFrame = self.view.bounds;
    menuViewFrame.size.width = kYKSlideNavigationMenuWidth;
    self.menuViewController.view.frame = menuViewFrame;
    
    UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                        action:@selector(handleNavigationBarPanGesture:)];
    [self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
    
    UIPanGestureRecognizer *viewPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(handleViewPanGesture:)];
    [self.navigationController.view addGestureRecognizer:viewPanGestureRecognizer];
    
    UITapGestureRecognizer *viewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(handleViewTapGesture:)];
    viewTapGestureRecognizer.delegate = self;
    [self.navigationController.view addGestureRecognizer:viewTapGestureRecognizer];
}

- (void)setupWithNavigationController:(UINavigationController *)navigationController
                   menuViewController:(UIViewController *)menuViewController {
    
    UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithImage:[[self class] defaultImage]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(clickedMenu:)];
    [self setupWithNavigationController:navigationController
                     menuViewController:menuViewController
                         menuButtonItem:menuButtonItem
                         backButtonItem:nil
                                options:0];
}

- (void)setupWithNavigationController:(UINavigationController *)navigationController
                   menuViewController:(UIViewController *)menuViewController
                       menuButtonItem:(UIBarButtonItem *)menuButtonItem
                       backButtonItem:(UIBarButtonItem *)backButtonItem
                              options:(YKSlideNavigationOptions)options {
    
    self.navigationController = navigationController;
    self.menuViewController = menuViewController;
    self.menuOpened = NO;
    self.options = options;
    
    [self.view addSubview:self.navigationController.view];
    [self.navigationController viewWillAppear:YES];
    [self.view insertSubview:self.menuViewController.view belowSubview:self.navigationController.view];
    [self.menuViewController viewWillAppear:YES];
    
    self.menuButtonItem = menuButtonItem;
    self.navigationController.visibleViewController.navigationItem.leftBarButtonItem = self.menuButtonItem;
    
    self.backButtonItem = (backButtonItem == nil)
    ? self.navigationController.navigationItem.backBarButtonItem
    : backButtonItem;

    [self drawShadowPathView:self.navigationController.view];
    
    if ((self.options & YKSlideNavigationOptionMenuMaskEnabled) == YKSlideNavigationOptionMenuMaskEnabled) {
        self.menuMaskView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        self.menuMaskView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
        [self.view insertSubview:self.menuMaskView aboveSubview:self.menuViewController.view];
    }
}

- (void)clickedBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickedMenu:(id)sender {
    if (self.isMenuOpened) {
        [self closeMenu];
    } else {
        [self openMenu];
    }
}

- (void)closeMenu {
    self.menuOpened = NO;
    [self moveControllerViewOffset:0.0f animated:YES duration:kYKSlideNavigationSlideDuration];
    self.navigationController.topViewController.view.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kYKSlideNavigationControllerNotificationMenuClosed object:nil];
}

- (void)openMenu {
    if (self.menuOpened) return;
    self.menuOpened = YES;
    [self moveControllerViewOffset:kYKSlideNavigationMenuWidth animated:YES duration:kYKSlideNavigationSlideDuration];
    self.navigationController.topViewController.view.userInteractionEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kYKSlideNavigationControllerNotificationMenuOpened object:nil];
}

- (void)setChildViewController:(UIViewController *)viewController {
    [self.navigationController setViewControllers:[NSArray arrayWithObject:viewController]];
    [self closeMenu];
}


- (void)moveControllerViewOffset:(CGFloat)offset {
    [self moveControllerViewOffset:offset animated:NO duration:0.0f];
}

- (void)moveControllerViewOffset:(CGFloat)offset animated:(BOOL)animated duration:(NSTimeInterval)duration {
    UIViewController *controller = self.navigationController;
    CGRect frame = controller.view.frame;
    frame.origin = CGPointZero;
    frame.origin.x = offset;
    
    if (offset < 0 || offset > kYKSlideNavigationMenuWidth) return;
    
    if ((self.options & YKSlideNavigationOptionMenuMaskEnabled) == YKSlideNavigationOptionMenuMaskEnabled) {
        self.menuMaskView.alpha = ((kYKSlideNavigationMenuWidth - offset) / kYKSlideNavigationMenuWidth) * 0.7;
    }

    if (animated) {
        [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            controller.view.frame = frame;
        } completion:^(BOOL finished) {
            [self updateLeftBarButtonItem];
        }];
    } else {
        controller.view.frame = frame;
        [self updateLeftBarButtonItem];
    }
}

- (void)drawShadowPathView:(UIView *)view {
    CGRect rect = view.bounds;
    rect.size.width = kYKSlideNavigationShadowWidth;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:rect].CGPath;
    view.layer.shadowOpacity = 0.75f;
    view.layer.shadowRadius = kYKSlideNavigationShadowWidth;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)updateLeftBarButtonItem {
    if (self.menuOpened) {
        self.navigationController.visibleViewController.navigationItem.leftBarButtonItem = self.menuButtonItem;
    } else {
        if ([self.navigationController.viewControllers count] > 1) {
            self.navigationController.visibleViewController.navigationItem.leftBarButtonItem = self.backButtonItem;
        } else {
            self.navigationController.visibleViewController.navigationItem.leftBarButtonItem = self.menuButtonItem;
        }
    }
}

#pragma mark - Gesture recognizer actions

- (void)handleNavigationBarPanGesture:(UIPanGestureRecognizer *)recognizer {
    UIView *view = self.navigationController.view;
    
	if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.panGestureOrigin = view.frame.origin;
	}
    
    CGFloat movedDistance = [recognizer translationInView:view].x;
    movedDistance += self.panGestureOrigin.x;
    [self moveControllerViewOffset:movedDistance];
    
	if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:view];
        CGFloat finalX = movedDistance + (velocity.x * 0.35f);
        
        if (finalX > view.frame.size.width * kYKSlideNavigationMenuOpenCloseThreshold) {
            [self openMenu];
        } else {
            [self closeMenu];
        }
    }
}

- (void)handleViewPanGesture:(UIPanGestureRecognizer *)recognizer {
    if (!self.isMenuOpened) return;
    
    UIView *view = self.navigationController.view;
    
	if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.panGestureOrigin = view.frame.origin;
	}
    
    CGFloat movedDistance = [recognizer translationInView:view].x;
    movedDistance += self.panGestureOrigin.x;
    
    [self moveControllerViewOffset:movedDistance];
    
	if(recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:view];
        CGFloat finalX = movedDistance + (velocity.x * 0.35f);
        
        if (finalX > view.frame.size.width * kYKSlideNavigationMenuOpenCloseThreshold) {
            [self openMenu];
        } else {
            [self closeMenu];
        }
    }
}

- (void)handleViewTapGesture:(UIPanGestureRecognizer *)recognizer {
    if (!self.isMenuOpened) return;
    [self closeMenu];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && !self.isMenuOpened) return NO;
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
