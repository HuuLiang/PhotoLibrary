//
//  PLSettingViewController.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLSettingViewController.h"
#import "PLVipCell.h"
#import "PLSystemConfigModel.h"
#import "PLVideo.h"
#import "PLPhotoChannel.h"
#import "PLAccountViewController.h"

@interface PLSettingViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableViewCell *_bannerCell;
    PLVipCell *_photoCell;
    PLVipCell *_videoCell;
    UITableViewCell *_protocolCell;
}
@property (nonatomic,retain) UIWebView *agreementWebView;
@property (nonatomic,retain) PLVideos *video;
@property (nonatomic,retain) PLPhotoChannel *photo;
@end

@implementation PLSettingViewController
DefineLazyPropertyInitialization(UIWebView, agreementWebView)
DefineLazyPropertyInitialization(PLVideos, video)
DefineLazyPropertyInitialization(PLPhotoChannel, photo)

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain handler:^(id sender) {
        [self.sideMenuViewController hideMenuViewController];
    }];
    
    self.layoutTableView.hasRowSeparator = YES;
    self.layoutTableView.hasSectionBorder = NO;
    self.layoutTableView.scrollEnabled = NO;
    self.layoutTableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    [self.layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    @weakify(self);
//    self.layoutTableViewAction = ^(NSIndexPath *indexPath, UITableViewCell *cell) {
//        @strongify(self);
//        if (cell == self->_bannerCell) {
//            
//        } else if (cell == self->_photoCell) {
//            id<PLPayable> payable = self.photo;
//            [self payForPayable:payable appleProductId:PL_APPLEPAY_PICTURE_PRODUCTID payPointType:PLPayPointTypePictureVIP withCompletionHandler:nil];
//            
//        } else if (cell == self->_videoCell) {
//            id<PLPayable> payable = self.video;
//            [self payForPayable:payable appleProductId:PL_APPLEPAY_VIDEO_PRODUCTID payPointType:PLPayPointTypeVideoVIP withCompletionHandler:nil];
//            
//        } else if (cell == self->_protocolCell) {
//            
//        }
//    };
    
    [self initCells];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaidNotification) name:kPaymentNotificationName object:nil];
    
    self.layoutTableViewAction = ^(NSIndexPath *indexPath, UITableViewCell *cell){
        @strongify(self);
        if (indexPath.section == 1) {
            PLAccountViewController *accountVC = [[PLAccountViewController alloc] init];
            accountVC.photo = self.photo;
            [self.navigationController pushViewController:accountVC animated:YES];
            
        }
    };
    
}

//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}


- (void)onPaidNotification {
    [self initCells];
}

- (void)initCells {
    [self removeAllLayoutCells];
    NSUInteger section = 0;
    
    [self initBannerCell:section++];
    //    [self initPhotoVipCell:section++];
    [self initAccountCell:section++];
    [self setHeaderHeight:1 inSection:section];
    //    [self initVideoVipCell:section++];
    [self setHeaderHeight:2 inSection:section];
    [self initProtocolCell:section];
    [self.layoutTableView reloadData];
}

- (void)initBannerCell:(NSUInteger)section {
    _bannerCell = [[UITableViewCell alloc] init];
    _bannerCell.backgroundColor = [UIColor colorWithHexString:@"#666aaa"];
    UIImageView *_imageView = [[UIImageView alloc] init];
    
    if ([PLUtil isAppleStore]) {
        _imageView.image = [UIImage imageNamed:@"appstore_banner.jpg"];
    }else {
        
        [_imageView sd_setImageWithURL:[NSURL URLWithString:[PLSystemConfigModel sharedModel].ChannelBannerImgUrl]];
    }
    
    _imageView.frame = CGRectMake(0, 0, kScreenWidth, 100.);
    _imageView.contentMode = UIViewContentModeScaleToFill;
    //    _imageView.clipsToBounds = YES;
    
    [_bannerCell addSubview:_imageView];
    
    [self setLayoutCell:_bannerCell cellHeight:100 inRow:0 andSection:section];
}

- (void)initAccountCell:(NSInteger)section {
    UITableViewCell *accountCell = [[UITableViewCell alloc] init];
//    accountCell.selectionStyle = UITableViewCellSelectionStyleNone;
    accountCell.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"av_volumeon"]];
//    [accountCell addSubview:imageView];
    accountCell.imageView.image = [UIImage imageNamed:@"popup_menu_marked"];
    accountCell.textLabel.text = @"我的账号";
    accountCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self setLayoutCell:accountCell cellHeight:KWidth(64.) inRow:0 andSection:section];
}


- (void)initPhotoVipCell:(NSUInteger)section {
    _photoCell = [[PLVipCell alloc] init];
    _photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    _photoCell.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    _photoCell.bgImg = @"setting_photo_icon";
    NSInteger price = [PLSystemConfigModel sharedModel].photoPrice/100.;
    _photoCell.price = [PLUtil isPictureVip]? @"" : [NSString stringWithFormat:@"%ld",(long)price];
    id<PLPayable> payable = self.photo;
    @weakify(self);
    _photoCell.payBtnblock = ^(){
        @strongify(self);
        [self payForPayable:payable appleProductId:PL_APPLEPAY_PICTURE_PRODUCTID payPointType:PLPayPointTypePictureVIP withCompletionHandler:nil];
    };
    [self setLayoutCell:_photoCell cellHeight:80 inRow:0 andSection:section];
}

- (void)initVideoVipCell:(NSUInteger)section {
    _videoCell = [[PLVipCell alloc] init];
    _videoCell.selectionStyle = UITableViewCellSelectionStyleNone;
    _videoCell.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    _videoCell.bgImg = @"setting_video_icon";
    NSInteger price = [PLSystemConfigModel sharedModel].videoPrice/100.;
    _videoCell.price = [PLUtil isVideoVip]? @"" : [NSString stringWithFormat:@"%ld",(long)price];
    
    //    PLVideo *video = [[PLVideo alloc] init];
    id<PLPayable> payable = self.video;
    @weakify(self);
    _videoCell.payBtnblock = ^(){
        @strongify(self);
        [self payForPayable:payable appleProductId:PL_APPLEPAY_VIDEO_PRODUCTID payPointType:PLPayPointTypeVideoVIP withCompletionHandler:nil];
    };
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
    [self setLayoutCell:_protocolCell cellHeight:kScreenHeight-30-64-180 inRow:0 andSection:section];
    
}


@end
