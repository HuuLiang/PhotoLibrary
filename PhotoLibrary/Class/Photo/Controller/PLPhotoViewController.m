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

static NSString *const kPhotoCellReusableIdentifier = @"PhotoCellReusableIdentifier";

@interface PLPhotoViewController () <UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView *_layoutCollectionView;
    UIButton *_floatingButton;
    
    PLPhotoNavigationTitleView *_navTitleView;
}
@property (nonatomic,retain) PLPhotoChannelModel *channelModel;
@property (nonatomic,retain) PLChannelProgramModel *channelProgramModel;
@property (nonatomic,retain) PLPhotoChannelPopupMenuController *popupMenuController;

@property (nonatomic,retain) PLPhotoChannel *currentPhotoChannel;
@end

@implementation PLPhotoViewController
@synthesize currentPhotoChannel = _currentPhotoChannel;

DefineLazyPropertyInitialization(PLPhotoChannelModel, channelModel)
DefineLazyPropertyInitialization(PLChannelProgramModel, channelProgramModel)

- (PLPhotoChannelPopupMenuController *)popupMenuController {
    if (_popupMenuController) {
        return _popupMenuController;
    }
    
    @weakify(self);
    _popupMenuController = [[PLPhotoChannelPopupMenuController alloc] init];
    _popupMenuController.photoChannelSelAction = ^(PLPhotoChannel *selectedChannel, id sender) {
        @strongify(self);
        self.currentPhotoChannel = selectedChannel;
    };
    return _popupMenuController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;

    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[PLPhotoCell class] forCellWithReuseIdentifier:kPhotoCellReusableIdentifier];
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
    _navTitleView.title = self.currentPhotoChannel.name;
    _navTitleView.imageURL = [NSURL URLWithString:self.currentPhotoChannel.columnImg];
    self.navigationItem.titleView = _navTitleView;
}

- (void)loadPhotoChannels {
    @weakify(self);
    [self.channelModel fetchPhotoChannelsWithCompletionHandler:^(BOOL success, NSArray<PLPhotoChannel *> *channels) {
        @strongify(self);
        
        
    }];
}

- (void)loadPhotosInChannel:(NSNumber *)channelId {
    [self.channelProgramModel fetchProgramsWithColumnId:channelId pageNo:1 pageSize:10 completionHandler:^(BOOL success, PLChannelPrograms *programs) {
        
    }];
}

- (void)setCurrentPhotoChannel:(PLPhotoChannel *)currentPhotoChannel {
    _currentPhotoChannel = currentPhotoChannel;
    [currentPhotoChannel writeToPersistence];
    
    _navTitleView.title = currentPhotoChannel.name;
    _navTitleView.imageURL = [NSURL URLWithString:currentPhotoChannel.columnImg];
    
    [self loadPhotosInChannel:currentPhotoChannel.columnId];
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

#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellReusableIdentifier forIndexPath:indexPath];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

@end
