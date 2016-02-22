//
//  DocWinC.h
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/20.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "MyPDFView.h"

@interface DocWinC : NSWindowController{
    IBOutlet NSWindow *window;
    IBOutlet NSWindow *progressWin;
    IBOutlet NSProgressIndicator *savingProgBar;
    IBOutlet NSTextField *progCurrentPg;
    IBOutlet NSTextField *progMaxPg;
}

@property (strong) IBOutlet MyPDFView *_pdfView;

@end
