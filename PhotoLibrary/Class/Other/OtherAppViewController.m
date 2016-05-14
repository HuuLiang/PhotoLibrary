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
#import "OtherAppFetchModel.h"
static NSString *const kOtherAppTableViewCellResueidentifer = @"kOtherAppTableViewCellResueidentifer";
static const NSUInteger kRowHeight  = 90;
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
   [self.fetchModel fetchOtherAppWithPageNo:0 completionHandler:^(BOOL success, OtherApp *photo) {
           @strongify(self)
       if (success) {
       [self.dataArray  addObjectsFromArray:photo.programList];
           
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
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AppListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kOtherAppTableViewCellResueidentifer];
    if (self.dataArray.count) {
        
        OtherApp *model = self.dataArray[indexPath.row];

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
    
    OtherApp *model = self.dataArray[indexPath.row];
    [[UIApplication sharedApplication] openURL:model];

}


@end
