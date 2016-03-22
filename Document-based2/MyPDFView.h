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
#import "Document.h"
#import "HandleView.h"

@interface MyPDFView : PDFView{
}
- (void)drawHundleView;
- (void)removeHundleView;

@end
