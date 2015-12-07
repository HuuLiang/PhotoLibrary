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

static NSString *const kPhotoCellReusableIdentifier = @"PhotoCellReusableIdentifier";
static NSString *const kHeaderFooterReusableIdentifier = @"HeaderFooterReusableIdentifier";

@interface PLPhotoViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_layoutCollectionView;
    UIButton *_floatingButton;
    
    PLPhotoNavigationTitleView *_navTitleView;
}
@property (nonatomic,retain) PLPhotoChannelModel *channelModel;
@property (nonatomic,retain) PLChannelProgramModel *channelProgramModel;
@property (nonatomic,retain) PLPhotoChannelPopupMenuController *popupMenuController;

@property (nonatomic,retain) PLPhotoChannel *currentPhotoChannel;
@property (nonatomic,retain) NSMutableArray<PLProgram *> *photoPrograms;

@property (nonatomic,retain) PLPhotoBrowser *photoBrowser;
@end

@implementation PLPhotoViewController
@synthesize currentPhotoChannel = _currentPhotoChannel;

DefineLazyPropertyInitialization(PLPhotoChannelModel, channelModel)
DefineLazyPropertyInitialization(PLChannelProgramModel, channelProgramModel)
DefineLazyPropertyInitialization(NSMutableArray, photoPrograms)
DefineLazyPropertyInitialization(PLPhotoBrowser, photoBrowser)

- (PLPhotoChannelPopupMenuController *)popupMenuController {
    if (_popupMenuController) {
        return _popupMenuController;
    }
    
    @weakify(self);
    _popupMenuController = [[PLPhotoChannelPopupMenuController alloc] init];
    _popupMenuController.photoChannelSelAction = ^(PLPhotoChannel *selectedChannel, id sender) {
        @strongify(self);
        self.currentPhotoChannel = selectedChannel;
        [self.popupMenuController hide];
        
//        if ([PLUtil isPaidForPhotoChannel:selectedChannel.columnId]) {
//            self.currentPhotoChannel = selectedChannel;
//            [self.popupMenuController hide];
//        } else {
//            
//        }
    };
    return _popupMenuController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 10);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[PLPhotoCell class] forCellWithReuseIdentifier:kPhotoCellReusableIdentifier];
    [_layoutCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderFooterReusableIdentifier];
    [_layoutCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kHeaderFooterReusableIdentifier];
    _layoutCollectionView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:_layoutCollectionView];
    {
        [_layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    _floatingButton = [[UIButton alloc] init];
    [_floatingButton setImage:[UIImage imageNamed:@"photo_floating_icon"] forState:UIControlStateNormal];
    [self.view addSubview:_floatingButton];
    {
        [_floatingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(72.5, 79));
            make.left.bottom.equalTo(self.view).insets(UIEdgeInsetsMake(0, 15, 15, 0));
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
        [self loadPhotosInChannel:self.currentPhotoChannel shouldReload:YES];
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
                if ([PLUtil isPaidForPhotoChannel:((PLPhotoChannel *)obj).columnId]) {
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

- (void)loadPhotosInChannel:(PLPhotoChannel *)photoChannel shouldReload:(BOOL)shouldReload {
    _navTitleView.title = photoChannel.name ?: @"图库";
    _navTitleView.imageURL = photoChannel.columnImg?[NSURL URLWithString:photoChannel.columnImg]:nil;
    
    if (photoChannel.columnId) {
        @weakify(self);
        [self.channelProgramModel fetchProgramsWithColumnId:photoChannel.columnId
                                                     pageNo:shouldReload?1:self.photoPrograms.count/kDefaultPageSize+1
                                                   pageSize:kDefaultPageSize
                                          completionHandler:^(BOOL success, PLChannelPrograms *programs)
         {
             @strongify(self);
             if (!self || !success) {
                 return ;
             }
             
             if (shouldReload) {
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
    
    [self loadPhotosInChannel:currentPhotoChannel shouldReload:YES];
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
    cell.layer.borderWidth = 2;
    cell.layer.borderColor = [UIColor colorWithHexString:@"#503d3c"].CGColor;
    
    PLProgram *program = self.photoPrograms[indexPath.section*4+indexPath.row];
    cell.imageURL = [NSURL URLWithString:program.coverImg];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section < self.photoPrograms.count / 4) {
        return 4;
    } else {
        return self.photoPrograms.count % 4;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderFooterReusableIdentifier forIndexPath:indexPath];
    view.backgroundColor = [UIColor colorWithHexString:@"#503d3c"];
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(5, CGRectGetHeight(self.view.bounds));
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(5, CGRectGetHeight(self.view.bounds));
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat cellHeight = CGRectGetHeight(self.view.bounds) / 2;
    return CGSizeMake(cellHeight*0.7, cellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section != [collectionView numberOfSections] - 1) {
        return UIEdgeInsetsMake(0, 0, 0, 10);
    } else {
        return UIEdgeInsetsZero;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PLProgram *photoProgram = self.photoPrograms[indexPath.row];
    self.photoBrowser.photoAlbum = photoProgram;
    [self.photoBrowser showInView:self.view.window];
}
@end
