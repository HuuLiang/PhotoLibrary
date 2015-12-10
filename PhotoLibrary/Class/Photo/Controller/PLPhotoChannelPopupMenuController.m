//
//  PLPhotoChannelPopupMenuController.m
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/2.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLPhotoChannelPopupMenuController.h"
#import "PLPhotoChannelModel.h"
#import "PLProgram.h"

@interface PLPhotoChannelPopupMenuController ()
@property (nonatomic,retain) PLPhotoChannelModel *channelModel;
@end

@implementation PLPhotoChannelPopupMenuController

DefineLazyPropertyInitialization(PLPhotoChannelModel, channelModel)

- (void)showInView:(UIView *)view inPosition:(CGPoint)pos {
    self.menuItems = nil;
    [super showInView:view inPosition:pos];
    [self loadPhotoChannels];
}

- (void)loadPhotoChannels {
    @weakify(self);
    [self.channelModel fetchPhotoChannelsWithCompletionHandler:^(BOOL success, NSArray<PLPhotoChannel *> *channels) {
        @strongify(self);
        
        if (success) {
            NSMutableArray *menuItems = [NSMutableArray array];
            [channels enumerateObjectsUsingBlock:^(PLPhotoChannel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.type.unsignedIntegerValue == PLProgramTypePicture) {
                    PLPopupMenuItem *item = [PLPopupMenuItem menuItemWithTitle:obj.name imageUrlString:obj.columnImg];
                    item.selected = [self.selectedPhotoChannel isSameChannel:obj];
                    item.occupied = obj.isFreeChannel ?: [PLPaymentUtil isPaidForPayable:obj];
                    [menuItems addObject:item];
                }
            }];
            [self setMenuItems:menuItems];
        } else {
            [self performSelector:@selector(hide) withObject:nil afterDelay:1.0];
        }
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @weakify(self);
    self.selectAction = ^(NSUInteger index, id sender) {
        @strongify(self);
        self.selectedPhotoChannel = self.channelModel.fetchedChannels[index];
        
        if (self.photoChannelSelAction) {
            self.photoChannelSelAction(self.selectedPhotoChannel, sender);
        }
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
