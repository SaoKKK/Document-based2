//
//  AppDelegate.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/19.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "AppDelegate.h"

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
}

@end

@implementation AppDelegate
@synthesize txtPanel,isImgInPboard;

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

@end
