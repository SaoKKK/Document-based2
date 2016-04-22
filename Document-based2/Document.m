//
//  Document.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/19.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "Document.h"
#import "DocWinC.h"

#define APPD (AppDelegate *)[NSApp delegate]

@interface Document ()

@end

@implementation Document


- (instancetype)init {
    self = [super init];
    if (self) {
    
    }
    return self;
}

//オートセーブ機能のON/OFF
+ (BOOL)autosavesInPlace {
    return NO;
}

- (NSString *)windowNibName {
    return @"Document";
}

- (void)makeWindowControllers{
    //ドキュメントウインドウコントローラのインスタンスを作成
    DocWinC *_docWinC = [[DocWinC alloc]initWithWindowNibName:[self windowNibName]];
    [self addWindowController:_docWinC];
}

//ドキュメントの保存
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError{
    //PDFビューのドキュメントをNSDataにパッケージして返す
    DocWinC *winC = [[self windowControllers]objectAtIndex:0];
    return [winC pdfViewDocumentData];
}

- (void)saveDocument:(id)sender{
    if ((APPD).isCopyLocked || (APPD).isPrintLocked) {
        DocWinC *winC = [[self windowControllers]objectAtIndex:0];
        (APPD).parentWin = winC.window;
        (APPD).pwTxtPass.stringValue = @"";
        (APPD).pwMsgTxt.stringValue = NSLocalizedString(@"UnlockEditMsg", @"");
        (APPD).pwInfoTxt.stringValue = NSLocalizedString(@"UnlockEditInfo", @"");
        [(APPD).parentWin beginSheet:(APPD).passWin completionHandler:^(NSInteger returnCode){
            if (returnCode == NSModalResponseOK) {
                [super saveDocument:nil];
            }
        }];
    } else {
        [super saveDocument:nil];
    }
}

- (IBAction)saveDocumentAs:(id)sender{
    if ((APPD).isCopyLocked || (APPD).isPrintLocked) {
        DocWinC *winC = [[self windowControllers]objectAtIndex:0];
        (APPD).parentWin = winC.window;
        (APPD).pwTxtPass.stringValue = @"";
        (APPD).pwMsgTxt.stringValue = NSLocalizedString(@"UnlockEditMsg", @"");
        (APPD).pwInfoTxt.stringValue = NSLocalizedString(@"UnlockEditInfo", @"");
        [(APPD).parentWin beginSheet:(APPD).passWin completionHandler:^(NSInteger returnCode){
            if (returnCode == NSModalResponseOK) {
                [super saveDocumentAs:nil];
            }
        }];
    } else {
        [super saveDocumentAs:nil];
    }
}

//データを読み込んでドキュメントを開く
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    if ([self windowControllers].count != 0) {
        //復帰のための読み込みの場合
        DocWinC *winC = [[self windowControllers]objectAtIndex:0];
        [winC revertDocumentToSaved];
    }
    return YES;
}

@end
