//
//  AppDelegate.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/19.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (){
    IBOutlet NSMenuItem *mnSinglePage;
    IBOutlet NSMenuItem *mnSingleCont;
    IBOutlet NSMenuItem *mnTwoPages;
    IBOutlet NSMenuItem *mnTwoPageCont;
    IBOutlet NSMenu *mnView;
    IBOutlet NSMenuItem *mnItemView;
    IBOutlet NSMenu *mnGo;
    IBOutlet NSMenuItem *mnItemGo;
    IBOutlet NSMenuItem *mnItemFindInPDF;
    NSArray *mnPageDisplay; //表示モード変更メニューグループ
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //メニューグループを作成
    mnPageDisplay = [NSArray arrayWithObjects:mnSinglePage,mnSingleCont,mnTwoPages,mnTwoPageCont,nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL) applicationShouldOpenUntitledFile: (NSApplication *) application{
    //アプリケーション起動時に空のドキュメントを開くかの可否
    return NO;
}

#pragma mark - menu action

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

//検索メニューの有効／無効を切り替え
- (void)findMenuSetEnabled:(BOOL)enabled{
    [mnItemFindInPDF setEnabled:enabled];
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

//ドキュメントメニューの有効／無効を切り替え
- (void)documentMenuSetEnabled:(BOOL)enabled{
    [mnItemGo setEnabled:enabled];
    [mnItemView setEnabled:enabled];
    for (NSMenuItem *item in [mnGo itemArray]) {
        [item setEnabled:enabled];
    }
    for (NSMenuItem *item in [mnView itemArray]){
        [item setEnabled:enabled];
    }
}

@end
