//
//  HomeChannelViewController.m
//  PhotoLibrary
//
//  Created by ZF on 16/5/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "HomeChannelViewController.h"
#import "PLPhotoCell.h"
#import "PLPhotoChannelModel.h"
#import "PLPhotoViewController.h"
static const CGFloat kPhotoCellInterspace = 5;

static NSString *const kPhotoCellReusableIdentifier = @"PhotoCellReusableIdentifier";
static NSString *const kHeaderReusableIdentifier = @"HeaderReusableIdentifier";
static NSString *const kFooterReusableIdentifier = @"FooterReusableIdentifier";

@interface HomeChannelViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{

    UICollectionView *_layoutCollectionView;
    UIButton *_floatingButton;
    NSUInteger _currentPage;

}

@property (nonatomic,retain) PLPhotoChannelModel *channelModel;
@property (nonatomic,retain) PLPhotoChannel *currentPhotoChannel;

@property (nonatomic,strong) NSMutableArray *channelDataArray;
@end

@implementation HomeChannelViewController

DefineLazyPropertyInitialization(PLPhotoChannelModel, channelModel);
DefineLazyPropertyInitialization(PLPhotoChannel, currentPhotoChannel);
DefineLazyPropertyInitialization(NSMutableArray, channelDataArray);
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setCollectionView];
    
    [self loadPhotoChannels];
}

- (void)setCollectionView{
   
    
    /**设置layout*/
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = kPhotoCellInterspace;
    layout.minimumLineSpacing = kPhotoCellInterspace;
    layout.sectionInset = UIEdgeInsetsMake(kPhotoCellInterspace, kPhotoCellInterspace, kPhotoCellInterspace, kPhotoCellInterspace);

    
    //滚动方向
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    /**设置collectionView*/
    _layoutCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    
    _layoutCollectionView.pagingEnabled = NO;
    _layoutCollectionView.delegate = self;
    _layoutCollectionView.dataSource = self;
    [_layoutCollectionView registerClass:[PLPhotoCell class] forCellWithReuseIdentifier:kPhotoCellReusableIdentifier];
    
    /**设置页眉重用*/
    [_layoutCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReusableIdentifier];
    
    /**设置页脚重用*/
    [_layoutCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterReusableIdentifier];
    
    _layoutCollectionView.backgroundColor = self.view.backgroundColor;
    
    [self.view addSubview:_layoutCollectionView];
    {
        [_layoutCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, self.adBannerHeight, 0));
            
        }];
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.channelDataArray.count;
    
}

//在模型中下载数据，返回的数据已经存入模型中的数组中
- (void)loadPhotoChannels {
    
    @weakify(self);
    [self.channelModel fetchPhotoChannelsWithCompletionHandler:^(BOOL success, NSArray<PLPhotoChannel *> *channels) {

        
        @strongify(self);
        if (!self || !success || channels.count == 0) {
            return ;
        }
        
        if (success) {
            [self.channelDataArray addObjectsFromArray:channels];
            
            [_layoutCollectionView reloadData];
        }
    }];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    const CGFloat cellHeight = CGRectGetHeight(collectionView.bounds) / 2 - kPhotoCellInterspace*1.5;
    const CGFloat cellWidth = CGRectGetWidth(collectionView.bounds) / 2 - kPhotoCellInterspace * 1.5;
    return CGSizeMake(cellWidth, cellHeight);
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    PLPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellReusableIdentifier forIndexPath:indexPath];
    
    if (indexPath.item < self.channelDataArray.count) {
        PLPhotoChannel *program = self.channelDataArray[indexPath.item];
        cell = [cell setChannelCellWithIndexPath:indexPath andCollectionView:collectionView andModel:program hasTitle:YES];
//        cell.imageURL = [NSURL URLWithString:program.columnImg];
    } else {
        cell.imageURL = nil;
    }
    
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.channelDataArray.count) {
        
        
         PLPhotoChannel *channel =self.channelDataArray[indexPath.row];
        if (channel) {
            
             PLPhotoViewController *photoVC = [[PLPhotoViewController alloc] initWithChannel:channel];
            [self.navigationController pushViewController:photoVC animated:YES];
            
        }
        
    }
   
    
   
//    if (channel.payAmount.unsignedIntegerValue==0) {
//        [self.navigationController pushViewController:photoVC animated:YES];
    
//    }else{
//       @weakify(self)
//        [self payForPayable:channel withCompletionHandler:^(BOOL success, id obj) {
//            @strongify(self)
//            if (success) {
//                [self.navigationController pushViewController:photoVC animated:YES];
//            }
//        }];
//    }
    
}

@end
