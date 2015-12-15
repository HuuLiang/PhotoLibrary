//
//  PLPhotoViewController.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/1.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoViewController.h"
#import "PLPhotoCell.h"
#import "PLPhotoChannelModel.h"
#import "PLChannelProgramModel.h"
#import "PLPhotoChannelPopupMenuController.h"
#import "PLProgram.h"
#import "PLPhotoNavigationTitleView.h"
#import "PLPhotoBrowser.h"
#import <objc/runtime.h>
#import "PLPaymentViewController.h"

static NSString *const kPhotoCellReusableIdentifier = @"PhotoCellReusableIdentifier";
static NSString *const kHeaderReusableIdentifier = @"HeaderReusableIdentifier";
static NSString *const kFooterReusableIdentifier = @"FooterReusableIdentifier";

//static const CGFloat kSectionBorderWidth = 5;
static const CGFloat kPhotoCellInterspace = 5;
static NSString *const kSectionBackgroundColor = @"#503d3c";

@interface PLPhotoViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PLPhotoBrowserDelegate>
{
    UICollectionView *_layoutCollectionView;
    UIButton *_floatingButton;
    
    PLPhotoNavigationTitleView *_navTitleView;
}
@property (nonatomic,retain) PLPhotoChannelModel *channelModel;
@property (nonatomic,retain) PLChannelProgramModel *channelProgramModel;
@property (nonatomic,retain) PLPhotoChannelPopupMenuController *popupMenuController;

@property (nonatomic,retain) PLPhotoChannel *currentPhotoChannel;
@property (nonatomic,retain) NSMutableArray<PLChannelProgram *> *photoPrograms;

@property (nonatomic,retain) PLPhotoBrowser *photoBrowser;
@property (nonatomic) BOOL statusBarHidden;
@end

@implementation PLPhotoViewController
@synthesize currentPhotoChannel = _currentPhotoChannel;

DefineLazyPropertyInitialization(PLPhotoChannelModel, channelModel)
DefineLazyPropertyInitialization(PLChannelProgramModel, channelProgramModel)
DefineLazyPropertyInitialization(NSMutableArray, photoPrograms)

- (PLPhotoBrowser *)photoBrowser {
    if (_photoBrowser) {
        return _photoBrowser;
    }
    
    _photoBrowser = [[PLPhotoBrowser alloc] init];
    _photoBrowser.delegate = self;
    return _photoBrowser;
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    _statusBarHidden = statusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (PLPhotoChannelPopupMenuController *)popupMenuController {
    if (_popupMenuController) {
        return _popupMenuController;
    }
    
    @weakify(self);
    _popupMenuController = [[PLPhotoChannelPopupMenuController alloc] init];
    _popupMenuController.photoChannelSelAction = ^(PLPhotoChannel *selectedChannel, id sender) {
        @strongify(self);
        
        [self.popupMenuController hide];
        [self payForPayable:selectedChannel withCompletionHandler:^(BOOL success) {
            if (success) {
                self.currentPhotoChannel = selectedChannel;
                [self.popupMenuController hide];
            }
        }];
    };
    return _popupMenuController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kPhotoCellInterspace;
    layout.minimumLineSpacing = kPhotoCellInterspace;
    layout.sectionInset = UIEdgeInsetsMake(kPhotoCellInterspace, kPhotoCellInterspace, kPhotoCellInterspace, kPhotoCellInterspace);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[PLPhotoCell class] forCellWithReuseIdentifier:kPhotoCellReusableIdentifier];
    [_layoutCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReusableIdentifier];
    [_layoutCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterReusableIdentifier];
    _layoutCollectionView.backgroundColor = self.view.backgroundColor;
    _layoutCollectionView.pagingEnabled = YES;
    [self.view addSubview:_layoutCollectionView];
    {
        [_layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, self.adBannerHeight, 0));
        }];
    }
    
    _floatingButton = [[UIButton alloc] init];
    UIImage *flickerImage = [UIImage animatedImageWithImages:@[[UIImage imageNamed:@"photo_floating_icon_normal"],
                                                               [UIImage imageNamed:@"photo_floating_icon_highlight"]] duration:0.5];
    [_floatingButton setImage:flickerImage forState:UIControlStateNormal];
    [self.view addSubview:_floatingButton];
    {
        [_floatingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(87, 88.5));
            make.left.bottom.equalTo(_layoutCollectionView).insets(UIEdgeInsetsMake(0, 15, 15, 0));
        }];
    }
    
    @weakify(self);
    [_floatingButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        
        UIButton *button = sender;
        CGPoint point = [self.view convertPoint:CGPointMake(button.frame.origin.x,
                                                             button.frame.origin.y+button.frame.size.height) toView:self.view.window];
        self.popupMenuController.selectedPhotoChannel = self.currentPhotoChannel;
        [self.popupMenuController showInWindowInPosition:point];
    } forControlEvents:UIControlEventTouchUpInside];
    
    _navTitleView = [[PLPhotoNavigationTitleView alloc] initWithFrame:CGRectMake(0, 0, 140, 50)];
    self.navigationItem.titleView = _navTitleView;
    
    if (self.currentPhotoChannel) {
        [self loadPhotosInChannel:self.currentPhotoChannel withPage:1];
    } else {
        _navTitleView.title = @"图库";
        [self loadPhotoChannels];
    }
}

- (void)loadPhotoChannels {
    @weakify(self);
    [self.channelModel fetchPhotoChannelsWithCompletionHandler:^(BOOL success, NSArray<PLPhotoChannel *> *channels) {
        @strongify(self);
        if (!self || !success || channels.count == 0) {
            return ;
        }
        
        PLPhotoChannel *channelToShow = [channels bk_match:^BOOL(id obj) {
            if (((PLPhotoChannel *)obj).payAmount.unsignedIntegerValue == 0) {
                return YES;
            }
            return NO;
        }];
        
        if (!channelToShow) {
            channelToShow = [channels bk_match:^BOOL(id obj) {
                if ([PLPaymentUtil isPaidForPayable:((PLPhotoChannel *)obj)]) {
                    return YES;
                }
                return NO;
            }];
        }
        
        if (!channelToShow) {
            [[PLHudManager manager] showHudWithText:@"没有已支付或者免费的图库！"];
        } else {
            self.currentPhotoChannel = channelToShow;
        }
    }];
}

- (void)loadPhotosInChannel:(PLPhotoChannel *)photoChannel withPage:(NSUInteger)page {// shouldReload:(BOOL)shouldReload {
    _navTitleView.title = photoChannel.name ?: @"图库";
    _navTitleView.imageURL = photoChannel.columnImg?[NSURL URLWithString:photoChannel.columnImg]:nil;
    
    if (photoChannel.columnId) {
        @weakify(self);
        [self.channelProgramModel fetchProgramsWithColumnId:photoChannel.columnId
                                                     pageNo:page//shouldReload?1:self.photoPrograms.count/kDefaultPageSize+1
                                                   pageSize:kDefaultPageSize
                                          completionHandler:^(BOOL success, PLChannelPrograms *programs)
         {
             @strongify(self);
             if (!self || !success) {
                 return ;
             }
             
             if (page == 1) {
                 [self.photoPrograms removeAllObjects];
             }
             
             [self.photoPrograms addObjectsFromArray:programs.programList];
             [self->_layoutCollectionView reloadData];
         }];
    }
}

- (void)setCurrentPhotoChannel:(PLPhotoChannel *)currentPhotoChannel {
    _currentPhotoChannel = currentPhotoChannel;
    [currentPhotoChannel writeToPersistence];
    
    [self loadPhotosInChannel:currentPhotoChannel withPage:1];
}

- (PLPhotoChannel *)currentPhotoChannel {
    if (_currentPhotoChannel) {
        return _currentPhotoChannel;
    }
    
    _currentPhotoChannel = [PLPhotoChannel persistentPhotoChannel];
    return _currentPhotoChannel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return (self.photoPrograms.count + 3) / 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellReusableIdentifier forIndexPath:indexPath];
    
    NSUInteger programIndex = indexPath.section*4+indexPath.row;
    if (programIndex < self.photoPrograms.count) {
        PLProgram *program = self.photoPrograms[programIndex];
        cell.imageURL = [NSURL URLWithString:program.coverImg];
    } else {
        cell.imageURL = nil;
    }
    
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat cellHeight = CGRectGetHeight(collectionView.bounds) / 2 - kPhotoCellInterspace*1.5;
    const CGFloat cellWidth = CGRectGetWidth(collectionView.bounds) / 2 - kPhotoCellInterspace * 1.5;
    return CGSizeMake(cellWidth, cellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    NSUInteger indexOfAlbum = indexPath.section * 4 + indexPath.row;
    if (indexOfAlbum < self.photoPrograms.count) {
        [self payForPayable:self.channelProgramModel.fetchedPrograms withCompletionHandler:^(BOOL success) {
            @strongify(self);
            if (success) {
                PLChannelProgram *photoProgram = self.photoPrograms[indexOfAlbum];
                self.photoBrowser.photoAlbum = photoProgram;
                [self.photoBrowser showInView:self.view.window];
            }
        }];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger currentPage = CGRectGetWidth(scrollView.bounds) > 0 ? scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds) + 1 : 1;
    
    PLChannelPrograms *channelPrograms = self.channelProgramModel.fetchedPrograms;
    if (currentPage == (channelPrograms.items.unsignedIntegerValue+3) / 4) {
        return ;
    }
    
    if (![PLPaymentUtil isPaidForPayable:channelPrograms]) {
        return ;
    }
    
    NSUInteger pagesForOneRequest = channelPrograms.pageSize.unsignedIntegerValue / 4;
    NSUInteger loadedPages = channelPrograms.page.unsignedIntegerValue * pagesForOneRequest;
    if (currentPage % pagesForOneRequest == 0 && loadedPages == currentPage) {
        [self loadPhotosInChannel:self.currentPhotoChannel withPage:channelPrograms.page.unsignedIntegerValue+1];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    NSUInteger currentPage = CGRectGetWidth(scrollView.bounds) > 0 ? scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds) + 1 : 1;
    
    PLChannelPrograms *channelPrograms = self.channelProgramModel.fetchedPrograms;
    if (currentPage == kAutoPopupPaymentInScrollingPage) {
        [self payForPayable:channelPrograms withCompletionHandler:nil];
    }
    
    if (currentPage == (channelPrograms.items.unsignedIntegerValue+3) / 4) {
        [[PLHudManager manager] showHudWithText:@"已经翻到最后一页"];
    }
}

#pragma mark - PLPhotoBrowserDelegate

- (void)photoBrowser:(PLPhotoBrowser *)photoBrowser willEndDisplayingAlbum:(PLProgram *)album {
    self.statusBarHidden = NO;
}

- (void)photoBrowser:(PLPhotoBrowser *)photoBrowser didDisplayAlbum:(PLProgram *)album {
    self.statusBarHidden = YES;
    
    [PLStatistics statViewAlbumPhotos:album];
}
@end
