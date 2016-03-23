//
//  AppDelegate.h
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/19.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocInfoPanel.h"
#import "DocTextPanel.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSMenuItem *mnGoToPrevPg;
@property (weak) IBOutlet NSMenuItem *mnGoToNextPg;
@property (weak) IBOutlet NSMenuItem *mnGoToFirstPg;
@property (weak) IBOutlet NSMenuItem *mnGoToLastPg;
@property (weak) IBOutlet NSMenuItem *mnGoBack;
@property (weak) IBOutlet NSMenuItem *mnGoForward;
@property (weak) IBOutlet NSMenuItem *mnZoomIn;
@property (weak) IBOutlet NSMenuItem *mnZoomOut;
@property (weak) IBOutlet NSMenuItem *mnFullScreen;
@property (assign) BOOL isDocWinMain;
@property (assign) BOOL isOLExists;
@property (assign) BOOL isOLSelected;
@property (assign) BOOL isOLSelectedSingle;
@property (assign) BOOL bRowClicked;
@property (readwrite,nonatomic) NSPoint selPoint;

- (void)setMnPageDisplayState:(NSInteger)tag;

@end

