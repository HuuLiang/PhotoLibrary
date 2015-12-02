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
#import "PLPopupMenuController.h"
#import "PLProgram.h"

static NSString *const kPhotoCellReusableIdentifier = @"PhotoCellReusableIdentifier";

@interface PLPhotoViewController () <UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView *_layoutCollectionView;
    UIButton *_floatingButton;
}
@property (nonatomic,retain) PLPhotoChannelModel *channelModel;
@property (nonatomic,retain) PLPopupMenuController *popupMenuController;
@end

@implementation PLPhotoViewController

DefineLazyPropertyInitialization(PLPhotoChannelModel, channelModel)
DefineLazyPropertyInitialization(PLPopupMenuController, popupMenuController)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
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
        
        UIView *containerView = [self.view.window pl_dimView];
        CGPoint point = [self.view convertPoint:CGPointMake(button.frame.origin.x,
                                                             button.frame.origin.y+button.frame.size.height) toView:self.view.window];
        [self.popupMenuController showInView:containerView inPosition:point];
        [self loadPhotoChannels];
    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)loadPhotoChannels {
    @weakify(self);
    [self.channelModel fetchPhotoChannelsWithCompletionHandler:^(BOOL success, NSArray<PLPhotoChannel *> *channels) {
        @strongify(self);
        
        NSMutableArray *menuItems = [NSMutableArray array];
        [channels enumerateObjectsUsingBlock:^(PLPhotoChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.type.unsignedIntegerValue == PLProgramTypePicture) {
                [menuItems addObject:[PLPopupMenuItem menuItemWithTitle:obj.name imageUrlString:obj.columnImg]];
            }
        }];
        [self.popupMenuController setMenuItems:menuItems];
    }];
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
