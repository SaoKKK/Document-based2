//
//  MyPDFView.h
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/21.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>
#import "HandleView.h"
#import "ZoomView.h"
#import "HandScrollView.h"
#import "DocWinC.h"

@class HandleView;
@class HandScrollView;
@class ZoomView;

@interface MyPDFView : PDFView

@property (strong)HandleView *handleView;
@property (strong)HandScrollView *handScrollView;
@property (strong)ZoomView *zoomView;
@property (assign)NSPoint startPoint;
@property (readwrite)NSPoint endPoint;
@property (readonly,nonatomic) PDFPage *targetPg;

- (void)loadHundleView;
- (void)loadHandScrollView;
- (void)loadZoomView;
- (void)removeSubView;

@end
