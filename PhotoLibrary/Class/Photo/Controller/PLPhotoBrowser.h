//
//  PLPhotoBrowser.h
//  PhotoLibrary
//
//  Created by Sean Yue on 15/12/5.
//  Copyright © 2015年 iqu8. All rights reserved.
//

#import "PLBaseViewController.h"

@class PLProgram;
@class PLPhotoBrowser;

@protocol PLPhotoBrowserDelegate <NSObject>

@optional
- (void)photoBrowser:(PLPhotoBrowser *)photoBrowser didDisplayAlbum:(PLProgram *)album;
- (void)photoBrowser:(PLPhotoBrowser *)photoBrowser willEndDisplayingAlbum:(PLProgram *)album;

@end



@interface PLPhotoBrowser : PLBaseViewController    //制作照片查看器
/**单个Cell中的图片模型*/
@property (nonatomic,retain) PLProgram *photoAlbum;
@property (nonatomic,strong)  id fetchedData;
@property (nonatomic,assign) id<PLPhotoBrowserDelegate> delegate;

- (instancetype)initWithAlbum:(PLProgram *)album;
/**在哪个视图上显示*/
- (void)showInView:(UIView *)view;
- (void)hide;

@end
