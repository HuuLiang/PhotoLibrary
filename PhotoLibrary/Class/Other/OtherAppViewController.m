//
//  OtherAppViewController.m
//  PhotoLibrary
//
//  Created by ZF on 16/5/13.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "OtherAppViewController.h"
#import "AppListTableViewCell.h"
#import "OtherApp.h"
#import "UIScrollView+Refish.h"
#import "OtherAppFetchModel.h"
static NSString *const kOtherAppTableViewCellResueidentifer = @"kOtherAppTableViewCellResueidentifer";
static const NSUInteger kRowHeight  = 110;
@interface OtherAppViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *otherAppTaleView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) OtherAppFetchModel *fetchModel;
@end

@implementation OtherAppViewController

DefineLazyPropertyInitialization(OtherAppFetchModel, fetchModel)
DefineLazyPropertyInitialization(NSMutableArray, dataArray);

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTableView];
    
    [self loadData];
}

- (void)loadData{
    
    
    @weakify(self)
   [self.fetchModel fetchOtherAppWithCompletionHandler:^(BOOL success, OtherApp *photo) {
           @strongify(self)
       if (success) {
           
       [self.dataArray removeAllObjects];
           
       [self.dataArray  addObjectsFromArray:photo.programList];
        [self.otherAppTaleView PL_endPullToRefresh];
        [self.otherAppTaleView reloadData];
       }
    }];

}
- (void)setTableView{
    
    
    self.otherAppTaleView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.otherAppTaleView.dataSource = self;
    self.otherAppTaleView.delegate = self;
    self.otherAppTaleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.otherAppTaleView.frame = self.view.bounds;
    
    self.otherAppTaleView.tableFooterView = [[UIView alloc] init];
    self.otherAppTaleView.rowHeight = kRowHeight;
    [self.view addSubview:self.otherAppTaleView];
    
    [self.otherAppTaleView registerClass:[AppListTableViewCell class] forCellReuseIdentifier:kOtherAppTableViewCellResueidentifer];
    

    @weakify(self);//下拉刷新
    [self.otherAppTaleView PL_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self loadData];
    }];
    [self.otherAppTaleView PL_triggerPullToRefresh];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AppListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kOtherAppTableViewCellResueidentifer];
    if (self.dataArray.count) {
        
        PLProgram *model = self.dataArray[indexPath.row];

        cell = [cell setCellWithModel:model andIndexPath:indexPath antTableView:tableView];
    }
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return   self.dataArray.count;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PLProgram *model = self.dataArray[indexPath.row];
    [[UIApplication sharedApplication] openURL:[ NSURL URLWithString:model.videoUrl]];

}


@end
