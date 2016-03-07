//
//  AppDelegate.h
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/19.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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

- (void)setMnPageDisplayState:(NSInteger)tag;
- (void)documentMenuSetEnabled:(BOOL)enabled;
- (void)findMenuSetEnabled:(BOOL)enabled;

@end

