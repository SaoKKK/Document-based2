//
//  DocWinC.h
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/20.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class MyPDFView;

@interface DocWinC : NSWindowController<NSWindowDelegate,NSSplitViewDelegate>{
    IBOutlet NSWindow *window;
    IBOutlet NSWindow *progressWin;
    IBOutlet NSProgressIndicator *savingProgBar;
    IBOutlet MyPDFView *_pdfView;
    IBOutlet PDFThumbnailView *thumbView;
    IBOutlet NSButton *btnGoToFirstPg;
    IBOutlet NSButton *btnGoToPrevPg;
    IBOutlet NSButton *btnGoToNextPg;
    IBOutlet NSButton *btnGoToLastPg;
    IBOutlet NSButton *btnGoBack;
    IBOutlet NSButton *btnGoFoward;
    IBOutlet NSTextField *txtPg;
    IBOutlet NSTextField *txtTotalPg;
    IBOutlet NSNumberFormatter *txtPageFormatter;
    IBOutlet NSSplitView *_splitView;
    IBOutlet NSView *tocView;
    IBOutlet NSTabView *tabToc;
    IBOutlet NSSearchField *searchField;
    NSURL *docURL; //ドキュメントのfileURL保持用
    CGFloat oldTocWidth; //目次エリアの変更前の幅保持用
}
- (void)saveDocument:(id)sender;
@end
