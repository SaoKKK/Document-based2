//
//  DocWinC.h
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/20.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "MyOLView.h"

@class MyPDFView;
@class MyOLView;

@interface DocWinC : NSWindowController<NSWindowDelegate,NSSplitViewDelegate,NSTableViewDataSource,NSTableViewDelegate>{
    IBOutlet NSWindow *window;
    IBOutlet NSWindow *progressWin;
    IBOutlet NSProgressIndicator *savingProgBar;
    IBOutlet PDFThumbnailView *thumbView;
    IBOutlet NSButton *btnGoToFirstPg;
    IBOutlet NSButton *btnGoToPrevPg;
    IBOutlet NSButton *btnGoToNextPg;
    IBOutlet NSButton *btnGoToLastPg;
    IBOutlet NSButton *btnGoBack;
    IBOutlet NSButton *btnGoForward;
    IBOutlet NSTextField *txtPg;
    IBOutlet NSTextField *txtTotalPg;
    IBOutlet NSNumberFormatter *txtPageFormatter;
    IBOutlet NSSegmentedControl *segZoom;
    IBOutlet NSMatrix *matrixDisplayMode;
    IBOutlet NSSplitView *_splitView;
    IBOutlet NSView *tocView;
    IBOutlet NSTabView *tabToc;
    IBOutlet NSSegmentedControl *segTabTocSelect;
    IBOutlet NSSearchField *searchField;
    IBOutlet NSTableView *_tbView;
    IBOutlet MyOLView *_olView;
    IBOutlet NSSegmentedControl *segOLViewMode;
    NSURL *docURL; //ドキュメントのfileURL保持用
    CGFloat oldTocWidth; //目次エリアの変更前の幅保持用
    BOOL bFullscreen; //スクリーンモード保持用
    NSMutableArray *searchResult; //検索結果保持用
    NSString *selectedLabel; //選択中の領域に含まれる文字列を保持
    PDFDestination *selectedDest; //選択中の領域のPDFDestinationを保持
    NSUInteger selectedViewMode; //指定ビューモード保持用
}
@property (strong) IBOutlet NSSegmentedControl *segTool;
@property (strong) IBOutlet MyPDFView *_pdfView;

- (void)makeNewDocWithPDF:(PDFDocument*)pdf;
- (IBAction)outlineViewRowClicked:(id)sender;
- (NSData *)pdfViewDocumentData;
- (void)revertDocumentToSaved;
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (NSRect)ConvertRectToPage:(NSRect)rect;
- (NSRect)ConvertSuperViewRect;
@end
