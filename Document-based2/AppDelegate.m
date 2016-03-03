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
