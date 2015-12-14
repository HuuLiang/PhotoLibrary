//
//  PLSettingViewController.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLSettingViewController.h"
#import "PLSystemConfigModel.h"
#import "PLSettingChannelLockScrollView.h"
#import "PLPhotoChannelModel.h"
#import "PLVideoModel.h"

typedef NS_ENUM(NSUInteger, PLSettingCell) {
    PLSettingCellTopImage,
    PLSettingCellChannels,
    PLSettingCellAgreement,
    PLSettingCellCount
};

@interface PLSettingViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_layoutTableView;
}
@property (nonatomic,retain) UIImageView *topImageView;
@property (nonatomic,retain) PLSettingChannelLockScrollView *lockScrollView;
@property (nonatomic,retain) UIWebView *agreementWebView;

@property (nonatomic,retain) NSMutableDictionary *cells;
@property (nonatomic,retain) PLPhotoChannelModel *photoChannelModel;
@property (nonatomic,retain) PLVideoModel *videoChannelModel;
@end

@implementation PLSettingViewController

DefineLazyPropertyInitialization(UIImageView, topImageView)
DefineLazyPropertyInitialization(UIWebView, agreementWebView)
DefineLazyPropertyInitialization(PLPhotoChannelModel, photoChannelModel)
DefineLazyPropertyInitialization(PLVideoModel, videoChannelModel)

- (PLSettingChannelLockScrollView *)lockScrollView {
    if (_lockScrollView) {
        return _lockScrollView;
    }
    
    @weakify(self);
    _lockScrollView = [[PLSettingChannelLockScrollView alloc] init];
    _lockScrollView.action = ^(PLChannelCategory channelCategory, NSUInteger index) {
        @strongify(self);
        if (channelCategory == PLPhotoChannelCategory) {
            if (![PLPaymentUtil isPaidForPayable:self.photoChannelModel.fetchedChannels[index]]) {
                [self payForPayable:self.photoChannelModel.fetchedChannels[index] withCompletionHandler:^(BOOL success) {
                    if (success) {
                        [self loadPhotoChannels];
                    }
                }];
            }
        } else {
            if (![PLPaymentUtil isPaidForPayable:self.videoChannelModel.fetchedVideos]) {
                [self payForPayable:self.videoChannelModel.fetchedVideos withCompletionHandler:^(BOOL success) {
                    if (success) {
                        [self loadVideoChannels];
                    }
                }];
            }
            
        }
        
        
    };
    return _lockScrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _layoutTableView = [[UITableView alloc] init];
    _layoutTableView.delegate = self;
    _layoutTableView.dataSource = self;
    _layoutTableView.scrollEnabled = NO;
    _layoutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_layoutTableView];
    {
        [_layoutTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self.agreementWebView bk_whenTouches:1 tapped:5 handler:^{
        [[PLHudManager manager] showHudWithText:[NSString stringWithFormat:@"ChannelNo:%@\nServer Address:%@",
                                                 [PLConfig sharedConfig].channelNo, [PLConfig sharedConfig].baseURL]];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData {
    @weakify(self);
    [[PLSystemConfigModel sharedModel] fetchSystemConfigWithCompletionHandler:^(BOOL success) {
        @strongify(self);
        if (success) {
            NSString *topImage = [PLSystemConfigModel sharedModel].spreadTopImage;
            if (topImage) {
                [self.topImageView sd_setImageWithURL:[NSURL URLWithString:topImage]];
            }
        }
    }];
    
    [self loadPhotoChannels];
    [self loadVideoChannels];
    
    NSString *agreementUrlString = [[PLConfig sharedConfig].baseURL stringByAppendingString:[PLConfig sharedConfig].agreementURLPath];
    NSURLRequest *agreementRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:agreementUrlString]];
    [self.agreementWebView loadRequest:agreementRequest];
}

- (void)loadPhotoChannels {
    @weakify(self);
    [self.photoChannelModel fetchPhotoChannelsWithCompletionHandler:^(BOOL success, NSArray<PLPhotoChannel *> *channels) {
        @strongify(self);
        if (success) {
            self.lockScrollView.photoChannels = channels;
        }
    }];
}

- (void)loadVideoChannels {
    @weakify(self);
    [self.videoChannelModel fetchVideosWithPageNo:0 completionHandler:^(BOOL success, PLVideos *videos) {
        @strongify(self);
        if (success) {
            self.lockScrollView.videoChannels = @[videos];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = self.cells[@(indexPath.row)];
    if (cell) {
        return cell;
    }
    
    cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *subview;
    if (indexPath.row == PLSettingCellTopImage) {
        subview = self.topImageView;
    } else if (indexPath.row == PLSettingCellChannels) {
        subview = self.lockScrollView;
    } else if (indexPath.row == PLSettingCellAgreement) {
        subview = self.agreementWebView;
    }
    
    [cell addSubview:subview];
    [subview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(cell);
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == PLSettingCellTopImage) {
        return CGRectGetWidth(tableView.frame) / 3;
    } else if (indexPath.row == PLSettingCellChannels) {
        return CGRectGetWidth(tableView.frame) / 3.5;
    } else if (indexPath.row == PLSettingCellAgreement) {
        const CGFloat topImageHeight = [self tableView:tableView
                               heightForRowAtIndexPath:[NSIndexPath indexPathForRow:PLSettingCellTopImage
                                                                          inSection:indexPath.section]];
        
        const CGFloat channelsHeight = [self tableView:tableView
                               heightForRowAtIndexPath:[NSIndexPath indexPathForRow:PLSettingCellChannels
                                                                          inSection:indexPath.section]];
        
        return CGRectGetHeight(tableView.frame) - topImageHeight - channelsHeight;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return PLSettingCellCount;
}

@end
