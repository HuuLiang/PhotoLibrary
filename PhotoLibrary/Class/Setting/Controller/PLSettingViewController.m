//
//  PLSettingViewController.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLSettingViewController.h"
#import "PLVipCell.h"


@interface PLSettingViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableViewCell *_bannerCell;
    PLVipCell *_vipCell;
    UITableViewCell *_protocolCell;
}
@property (nonatomic,retain) UIWebView *agreementWebView;
@end

@implementation PLSettingViewController
DefineLazyPropertyInitialization(UIWebView, agreementWebView)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.layoutTableView.hasRowSeparator = YES;
    self.layoutTableView.hasSectionBorder = NO;
    self.layoutTableView.scrollEnabled = NO;
    self.layoutTableView.backgroundColor = [UIColor blackColor];
    [self.layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    @weakify(self);
    self.layoutTableViewAction = ^(NSIndexPath *indexPath, UITableViewCell *cell) {
        @strongify(self);
        if (cell == self->_bannerCell) {
            
        } else if (cell == self->_vipCell) {
            
        } else if (cell == self->_protocolCell) {
            
        }
    };
    
    [self initCells];
    
}

- (void)initCells {
    [self removeAllLayoutCells];
    NSUInteger section = 0;
    
    [self initBannerCell:section++];
    [self initVipCell:section++];
    [self initProtocolCell:section];
}

- (void)initBannerCell:(NSUInteger)section {
    _bannerCell = [[UITableViewCell alloc] init];
    _bannerCell.backgroundColor = [UIColor colorWithHexString:@"#666aaa"];
    UIImageView *_imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    
    [_bannerCell.contentView addSubview:_imageView];
    
    [self setLayoutCell:_bannerCell cellHeight:100 inRow:0 andSection:section];
}

- (void)initVipCell:(NSUInteger)section {
    _vipCell = [[PLVipCell alloc] init];
    _vipCell.backgroundColor = [UIColor colorWithHexString:@"#ec407a"];
    
    [self setLayoutCell:_vipCell cellHeight:80 inRow:0 andSection:section];
}

- (void)initProtocolCell:(NSUInteger)section {
    _protocolCell = [[UITableViewCell alloc] init];
    NSString *agreementUrlString = [PL_BASE_URL stringByAppendingString:PL_AGREEMENT_URL];
    NSURLRequest *agreementRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:agreementUrlString]];
    [self.agreementWebView loadRequest:agreementRequest];
    [_protocolCell.contentView addSubview:self.agreementWebView];
    {
        [_agreementWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_protocolCell.contentView);
        }];
    }
    [self setLayoutCell:_protocolCell cellHeight:kScreenHeight-30-49-64-180 inRow:0 andSection:section];
    
}
@end
