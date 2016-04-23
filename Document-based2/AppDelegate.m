//
//  AppDelegate.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/19.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "AppDelegate.h"

#define WINC (DocWinC *)[[NSDocumentController sharedDocumentController].currentDocument.windowControllers objectAtIndex:0]

#pragma mark - WindowController

@interface NSWindowController(ConvenienceWC)
- (BOOL)isWindowShown;
- (void)showOrHideWindow;
@end

@implementation NSWindowController(ConvenienceWC)

- (BOOL)isWindowShown{
    return [[self window]isVisible];
}

- (void)showOrHideWindow{
    NSWindow *window = [self window];
    if ([window isVisible]) {
        [window orderOut:self];
    } else {
        [self showWindow:self];
    }
}

@end

@interface AppDelegate (){
    IBOutlet NSMenuItem *mnSinglePage;
    IBOutlet NSMenuItem *mnSingleCont;
    IBOutlet NSMenuItem *mnTwoPages;
    IBOutlet NSMenuItem *mnTwoPageCont;
    NSArray *mnPageDisplay; //表示モード変更メニューグループ
    NSTimer *timer; //ペーストボード監視用タイマー
    NSMutableArray *indexes; //アウトラインのページインデクスバックアップ用
    int cntIndex;
}

@end

@implementation AppDelegate
@synthesize txtPanel,isImgInPboard,parentWin,passWin,pwTxtPass,isLocked;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //メニューグループを作成
    mnPageDisplay = [NSArray arrayWithObjects:mnSinglePage,mnSingleCont,mnTwoPages,mnTwoPageCont,nil];
    //ペーストボード監視用タイマー開始
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(observePboard) userInfo:nil repeats:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL) applicationShouldOpenUntitledFile: (NSApplication *) application{
    //アプリケーション起動時に空のドキュメントを開くかの可否
    return NO;
}

//ペーストボードを監視
- (void)observePboard{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSArray *classes = [NSArray arrayWithObject:[NSImage class]];
    if ([pboard canReadObjectForClasses:classes options:nil]) {
        isImgInPboard = YES;
    } else {
        isImgInPboard = NO;
    }
}

#pragma mark - menu action

- (IBAction)newDocFromPboard:(id)sender{
    //クリップボードから画像オブジェクトを取得
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSArray *classes = [NSArray arrayWithObject:[NSImage class]];
    NSImage *img = [[pboard readObjectsForClasses:classes options:nil] objectAtIndex:0];
    //画像からPDFを作成
    PDFPage *page = [[PDFPage alloc]initWithImage:img];
    [page setValue:@"1" forKey:@"label"];
    PDFDocument *doc = [[PDFDocument alloc]init];
    [doc insertPage:page atIndex:0];
    //新規ドキュメント作成
    NSDocumentController *docC = [NSDocumentController sharedDocumentController];
    [docC openUntitledDocumentAndDisplay:YES error:nil];
    DocWinC *newWC= [docC.currentDocument.windowControllers objectAtIndex:0];
    [newWC makeNewDocWithPDF:doc];
}

- (IBAction)showOrHideTextPanel:(id)sender{
    if (! txtPanel){
        txtPanel = [[DocTextPanel alloc]initWithWindowNibName:@"DocTextPanel"];
    }
    
    [txtPanel clearTxt];
    [txtPanel showOrHideWindow];
}

- (void)mnCurrentDocument:(id)sender{
    NSDocumentController *docCtr = [NSDocumentController sharedDocumentController];
    //アクティブウインドウのドキュメントへの参照
    NSDocument *currentDoc = [docCtr currentDocument];
    NSLog(@"%@",currentDoc.fileURL);
    
    //開かれているドキュメントへの参照
    NSArray *docs = [docCtr documents];
    NSLog(@"%lu",docs.count);
    
}

#pragma mark - menu control

//メニュータイトルの変更
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    SEL action = menuItem.action;
    if (action==@selector(showOrHideTextPanel:)) {
        [menuItem setTitle:([txtPanel isWindowShown] ? NSLocalizedString(@"HideTP", @""):NSLocalizedString(@"ShowTP", @""))];
    }
    return YES;
}

//ディスプレイモード変更メニューのステータス変更
- (void)setMnPageDisplayState:(NSInteger)tag{
    for (int i=0; i < mnPageDisplay.count; i++) {
        if (i == tag) {
            [[mnPageDisplay objectAtIndex:i]setState:YES];
        } else {
            [[mnPageDisplay objectAtIndex:i]setState:NO];
        }
    }
}
#pragma mark - pass win

- (IBAction)pwUnlock:(id)sender {
    //現在のアウトラインのページインデクスをバックアップ
    indexes = [NSMutableArray array];
    cntIndex = 0;
    PDFOutline *root = (WINC)._pdfView.document.outlineRoot;
    [self getIndex:root];

    //ドキュメントをアンロック
    [(WINC)._pdfView.document unlockWithPassword:pwTxtPass.stringValue];
    if ((WINC)._pdfView.document.allowsCopying && (WINC)._pdfView.document.allowsPrinting) {
        //アンロック後のアウトラインにバックアップしておいたページインデクスをセット
        [self setIndex:root];
        isLocked = NO;
        [parentWin endSheet:passWin returnCode:NSModalResponseOK];
    }
}

- (void)getIndex:(PDFOutline*)parent{
    for (int i = 0; i < parent.numberOfChildren; i++) {
        PDFOutline *ol = [parent childAtIndex:i];
        PDFPage *page = ol.destination.page;
        NSInteger pgIndex = [(WINC)._pdfView.document indexForPage:page];
        if (pgIndex == NSNotFound) {
            pgIndex = 0;
        }
        [indexes addObject:[NSNumber numberWithInteger:pgIndex]];
        if (ol.numberOfChildren > 0) {
            [self getIndex:ol];
        }
    }
}

- (void)setIndex:(PDFOutline*)parent{
    PDFDocument *doc = (WINC)._pdfView.document;
    for (int i = 0; i < parent.numberOfChildren; i++) {
        PDFOutline *ol = [parent childAtIndex:i];
        PDFPage *page = [doc pageAtIndex:[[indexes objectAtIndex:cntIndex] integerValue]];
        PDFDestination *dest = ol.destination;
        [dest setValue:page forKey:@"page"];
        cntIndex ++;
        if (ol.numberOfChildren > 0) {
            [self setIndex:ol];
        }
    }
}

- (IBAction)pwCancel:(id)sender {
    [parentWin endSheet:passWin returnCode:NSModalResponseCancel];
}

@end
