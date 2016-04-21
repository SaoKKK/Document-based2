//
//  AppDelegate.h
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/19.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocTextPanel.h"
#import "DocWinC.h"

@class DocTextPanel;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) DocTextPanel *txtPanel;
@property (weak) IBOutlet NSMenuItem *mnGoToPrevPg;
@property (weak) IBOutlet NSMenuItem *mnGoToNextPg;
@property (weak) IBOutlet NSMenuItem *mnGoToFirstPg;
@property (weak) IBOutlet NSMenuItem *mnGoToLastPg;
@property (weak) IBOutlet NSMenuItem *mnGoBack;
@property (weak) IBOutlet NSMenuItem *mnGoForward;
@property (weak) IBOutlet NSMenuItem *mnZoomIn;
@property (weak) IBOutlet NSMenuItem *mnZoomOut;
@property (weak) IBOutlet NSMenuItem *mnFullScreen;
//pass win outlet
@property (weak) IBOutlet NSWindow *passWin;
@property (weak) IBOutlet NSTextField *pwMsgTxt;
@property (weak) IBOutlet NSTextField *pwInfoTxt;
@property (weak) IBOutlet NSSecureTextField *pwTxtPass;
@property (readwrite) NSWindow *parentWin;
@property (assign) BOOL isImgInPboard;
@property (assign) BOOL isDocWinMain;
@property (assign) BOOL isOLExists;
@property (assign) BOOL isOLSelected;
@property (assign) BOOL isOLSelectedSingle;
@property (assign) BOOL isSelection;
@property (assign) BOOL isTwoPages;
@property (assign) BOOL isLocked;
@property (assign) BOOL isCopyLocked;
@property (assign) BOOL isPrintLocked;
@property (assign) BOOL bRowClicked;
@property (readwrite,nonatomic) NSPoint selPoint;

- (void)setMnPageDisplayState:(NSInteger)tag;
@end

