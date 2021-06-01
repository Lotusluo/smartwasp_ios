//
//  HWValue.h
//  refresh
//
//  Created by Howe on 16/2/23.
//  Copyright © 2016年 Howe. All rights reserved.
//

#ifndef HWValue_h
#define HWValue_h

typedef void (^HWRefreshBlock)(void);

#define HWRefreshViewH    40.0f

#define HWToRefreshView   45.0f

#define HWRefreshViewW    [UIScreen mainScreen].bounds.size.width

#define HWRefreshRefLabelX  ((HWRefreshViewW - 150.0f) * 0.5f + 40.0f)

#define HWRefreshRefLabelY  0.0f

#define HWRefreshRefLabelW  110.0f

#define HWRefreshRefLabelH  40.0f

#define HWRefreshRefActViewX ((HWRefreshViewW - 150.0f) * 0.5f )

#define HWRefreshRefActViewY 0.0f

#define HWRefreshRefActViewW 40.0f

#define HWRefreshRefActViewH 40.0f

#define HWRefreshRefImageViewX ((HWRefreshViewW - 150.0f) * 0.5f )

#define HWRefreshRefImageViewY 0.0f

#define HWLoadActViewX HWRefreshRefActViewX

#define HWLoadActViewY HWRefreshRefActViewY

#define HWLoadActViewW HWRefreshRefActViewW

#define HWLoadActViewH HWRefreshRefActViewH

#endif /* HWValue_h */
