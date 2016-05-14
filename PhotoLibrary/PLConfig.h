//
//  PLConfig.h
//  PhotoLibrary
//
//  Created by Sean Yue on 16/4/8.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#ifndef PLConfig_h
#define PLConfig_h

#import "PLConfiguration.h"

#define PL_CHANNEL_NO           [PLConfiguration sharedConfig].channelNo
#define PL_REST_APP_ID          @"QUBA_2002"
#define PL_REST_PV              @200
#define PL_PACKAGE_CERTIFICATE  @"iPhone Distribution: Neijiang Fenghuang Enterprise (Group) Co., Ltd."

#define PL_PAYMENT_RESERVE_DATA [NSString stringWithFormat:@"%@$%@", PL_REST_APP_ID, PL_CHANNEL_NO]
#define PL_PAYMENT_CONFIG_URL           @"http://pay.iqu8.net/paycenter/payConfig.json"
#define PL_STANDBY_PAYMENT_CONFIG_URL   @"http://appcdn.mqu8.com/static/iosvideo/payConfig_%@.json"
#define PL_PAYMENT_COMMIT_URL           @"http://pay.iqu8.net/paycenter/qubaPr.json"

//#define PL_BASE_URL                         @"http://tuku.ihuiyx.com"
#define PL_BASE_URL                         @"http://120.24.252.114:8096"
#define PL_PHOTO_CHANNEL_URL                @"/gallery/column.htm"
#define PL_PHOTO_CHANNEL_PROGRAM_URL        @"/gallery/program.htm"
#define PL_PHOTO_URL_LIST_URL               @"/gallery/programUrl.htm"
#define PL_VIDEO_URL                        @"/gallery/hotVideo.htm"
#define PL_FREE_PHOTO_URL                   @"/gallery/free.htm"
#define PL_APP_SPREADLISTS_URL              @"/gallery/appSpreadList.htm"
#define PL_SYSTEM_CONFIG_URL                @"/gallery/systemConfig.htm"
#define PL_ACTIVATE_URL                     @"/gallery/activat.htm"
#define PL_USER_ACCESS_URL                  @"/gallery/userAccess.htm"
#define PL_AGREEMENT_URL                    @"/gallery/agreement.html"

#define PL_SYSTEM_CONFIG_PAY_AMOUNT            @"PAY_AMOUNT"
#define PL_SYSTEM_CONFIG_PAYMENT_TOP_IMAGE     @"CHANNEL_TOP_IMG"
#define PL_SYSTEM_CONFIG_STARTUP_INSTALL       @"START_INSTALL"
#define PL_SYSTEM_CONFIG_SPREAD_TOP_IMAGE      @"SPREAD_TOP_IMG"
#define PL_SYSTEM_CONFIG_SPREAD_URL            @"SPREAD_URL"

#define PL_BAIDU_AD_APP_ID                     @"d1c5f7d1"
#define PL_BAIDU_BANNER_ID                     @"2367758"
#define PL_UMENG_APP_ID                        @"566e5951e0f55a8e94000436"

#endif /* PLConfig_h */
