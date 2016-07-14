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
    PLVipCell *_photoCell;
    PLVipCell *_videoCell;
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
    self.layoutTableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    [self.layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    @weakify(self);
    self.layoutTableViewAction = ^(NSIndexPath *indexPath, UITableViewCell *cell) {
        @strongify(self);
        if (cell == self->_bannerCell) {
            
        } else if (cell == self->_photoCell) {
            
        } else if (cell == self->_videoCell) {
            
        } else if (cell == self->_protocolCell) {
            
        }
    };
    
    [self initCells];
    
}

- (void)initCells {
    [self removeAllLayoutCells];
    NSUInteger section = 0;
    
    [self initBannerCell:section++];
    [self initPhotoVipCell:section++];
    [self setHeaderHeight:1 inSection:section];
    [self initVideoVipCell:section++];
    [self setHeaderHeight:2 inSection:section];
    [self initProtocolCell:section];
}

- (void)initBannerCell:(NSUInteger)section {
    _bannerCell = [[UITableViewCell alloc] init];
    _bannerCell.backgroundColor = [UIColor colorWithHexString:@"#666aaa"];
    UIImageView *_imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[PLUtil isAppleStore] ?  @"appstore_banner.jpg" : @"channel_banner.jpg"]];
    _imageView.frame = CGRectMake(0, 0, kScreenWidth, 100.);
    _imageView.contentMode = UIViewContentModeScaleToFill;
//    _imageView.clipsToBounds = YES;
    
    [_bannerCell addSubview:_imageView];
    
    [self setLayoutCell:_bannerCell cellHeight:100 inRow:0 andSection:section];
}

- (void)initPhotoVipCell:(NSUInteger)section {
    _photoCell = [[PLVipCell alloc] init];
    _photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    _photoCell.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    _photoCell.bgImg = @"setting_photo_icon";
    _photoCell.price = 20.;
    [self setLayoutCell:_photoCell cellHeight:80 inRow:0 andSection:section];
}

- (void)initVideoVipCell:(NSUInteger)section {
    _videoCell = [[PLVipCell alloc] init];
    _videoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    _videoCell.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    _videoCell.bgImg = @"setting_video_icon";
    _videoCell.price = 30.;
    [self setLayoutCell:_videoCell cellHeight:80 inRow:0 andSection:section];
}

- (void)initProtocolCell:(NSUInteger)section {
    _protocolCell = [[UITableViewCell alloc] init];
    _protocolCell.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    NSString *agreementUrlString = [PL_BASE_URL stringByAppendingString:PL_AGREEMENT_URL];
    NSURLRequest *agreementRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:agreementUrlString]];
    [self.agreementWebView loadRequest:agreementRequest];
    self.agreementWebView.alpha = 0.9;
    self.agreementWebView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    [_protocolCell.contentView addSubview:self.agreementWebView];
    {
        [_agreementWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_protocolCell.contentView);
        }];
    }
    [self setLayoutCell:_protocolCell cellHeight:kScreenHeight-30-49-64-180-80 inRow:0 andSection:section];
    
}
@end
