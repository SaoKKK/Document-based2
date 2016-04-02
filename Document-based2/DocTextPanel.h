//
//  DocTextPanel.h
//  Document-based2
//
//  Created by 河野 さおり on 2016/03/16.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "DocWinC.h"
#import "MyPDFView.h"
#import "NSAlert+SynchronousSheet.h"

@interface DocTextPanel : NSWindowController<NSWindowDelegate>
- (void)clearTxt;
@end
