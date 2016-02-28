//
//  AppDelegate.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/19.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (){
    IBOutlet NSMenuItem *mmCurrentDocument;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //メニューアイテムのアクションを設定
    [mmCurrentDocument setRepresentedObject:@"CurrentDocument"];
    [mmCurrentDocument setAction:@selector(mnCurrentDocument:)];
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

@end
