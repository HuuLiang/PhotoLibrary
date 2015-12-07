//
//  PLPopupMenuController.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPopupMenuController.h"
#import "PLPopupMenuButton.h"
#import <objc/runtime.h>

@implementation PLPopupMenuItem

+ (instancetype)menuItemWithTitle:(NSString *)title imageUrlString:(NSString *)urlString {
    PLPopupMenuItem *item = [[self alloc] init];
    item.title = title;
    item.imageUrlString = urlString;
    return item;
}

@end

static const CGFloat kAnimationDuration = 0.3;
static const CGFloat kWidthRatio = 0.5;
static const CGFloat kMaxHeightRatio = 0.5;

static const CGFloat kSpacingBetweenCells = 5.0;
static const CGFloat kLeftRightPadding = 5.0;
static const CGFloat kTopBottomPadding = 10.0;

static const CGFloat kLoadingWidth = 80;
static const CGFloat kLoadingHeight = 80;

static NSString *const kMenuItemCellReusableIdentifier = @"MenuItemCellReusableIdentifier";
static const void *kMenuButtonAssociatedKey = &kMenuButtonAssociatedKey;

@interface PLPopupMenuController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_layoutTableView;
}
@property (nonatomic,readonly) CGSize frameSize;
@end

@implementation PLPopupMenuController

- (instancetype)initWithMenuItems:(NSArray<PLPopupMenuItem *> *)menuItem {
    self = [super init];
    if (self) {
        _menuItems = menuItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.cornerRadius = 10;
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    _layoutTableView = [[UITableView alloc] init];
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _layoutTableView.rowHeight = [UIScreen mainScreen].bounds.size.height * 0.10;
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kTopBottomPadding, kLeftRightPadding, kTopBottomPadding, kLeftRightPadding));
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showInView:(UIView *)view inPosition:(CGPoint)pos {
    if (self.menuItems.count == 0) {
        [self.view pl_beginLoading];
    }
    self.view.frame = CGRectMake(pos.x, pos.y-self.frameSize.height, self.frameSize.width, self.frameSize.height);
    if ([view.subviews containsObject:self.view]) {
        return ;
    }
    self.view.alpha = 0;
    [view addSubview:self.view];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        self.view.alpha = 1;
    }];
}

- (void)showInWindowInPosition:(CGPoint)pos {
    UIView *maskView = [[UIApplication sharedApplication].keyWindow pl_dimView];
    [self showInView:maskView inPosition:pos];
}

- (void)hide {
    if (!self.view.superview) {
        return ;
    }
    
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if ([keyWindow.pl_maskView.subviews containsObject:self.view]) {
        [keyWindow pl_restoreView];
    }
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (CGSize)frameSize {
    if (self.menuItems.count == 0) {
        return CGSizeMake(kLoadingWidth, kLoadingHeight);
    } else {
        const CGFloat width = [UIScreen mainScreen].bounds.size.width*kWidthRatio;
        const CGFloat height = MIN([UIScreen mainScreen].bounds.size.height*kMaxHeightRatio,
                                   _layoutTableView.rowHeight*self.menuItems.count+kTopBottomPadding*2);
        return CGSizeMake(width, height);
    }
}

- (void)setMenuItems:(NSArray<PLPopupMenuItem *> *)menuItems {
    _menuItems = menuItems;
    
    [self.view pl_endLoading];
    self.view.frame = CGRectMake(self.view.frame.origin.x,
                                 self.view.frame.origin.y+self.view.frame.size.height-self.frameSize.height,
                                 self.frameSize.width,
                                 self.frameSize.height);
    [_layoutTableView reloadData];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLPopupMenuItem *menuItem = self.menuItems[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuItemCellReusableIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMenuItemCellReusableIdentifier];
        
        PLPopupMenuButton *menuButton = [[PLPopupMenuButton alloc] initWithTitle:menuItem.title imageURL:[NSURL URLWithString:menuItem.imageUrlString]];
        menuButton.selected = menuItem.selected;
        menuButton.marked = menuItem.occupied;
        objc_setAssociatedObject(cell, kMenuButtonAssociatedKey, menuButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [cell addSubview:menuButton];
        {
            [menuButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(cell).insets(UIEdgeInsetsMake(kSpacingBetweenCells/2, 0, kSpacingBetweenCells/2, 0));
            }];
        }
        
        @weakify(self);
        [menuButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.selectAction) {
                self.selectAction(indexPath.row, sender);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    } else {
        PLPopupMenuButton *menuButton = objc_getAssociatedObject(cell, kMenuButtonAssociatedKey);
        menuButton.title = menuItem.title;
        menuButton.imageURL = [NSURL URLWithString:menuItem.imageUrlString];
        menuButton.selected = menuItem.selected;
        menuButton.marked = menuItem.occupied;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

@end
