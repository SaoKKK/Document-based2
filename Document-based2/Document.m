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
#define WINC (DocWinC *)[[self windowControllers]objectAtIndex:0]

@interface Document ()

@end

@implementation Document

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

#pragma mark - Save Document

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError{
    //PDFビューのドキュメントをNSDataにパッケージして返す
    return [WINC pdfViewDocumentData];
}

- (void)saveDocument:(id)sender{
    if (!(WINC)._pdfView.document.allowsCopying || !(WINC)._pdfView.document.allowsPrinting) {
        (APPD).parentWin = (WINC).window;
        (APPD).pwTxtPass.stringValue = @"";
        (APPD).pwMsgTxt.stringValue = NSLocalizedString(@"UnlockEditMsg", @"");
        (APPD).pwInfoTxt.stringValue = NSLocalizedString(@"UnlockEditInfo", @"");
        [(APPD).parentWin beginSheet:(APPD).passWin completionHandler:^(NSInteger returnCode){
            if (returnCode == NSModalResponseOK) {
                [self performSave];
            }
        }];
    } else {
        [self performSave];
    }
}

- (void)performSave{
    if ((WINC).isEncrypted) {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = NSLocalizedString(@"EncryptedMsg", @"");
        [alert setInformativeText:NSLocalizedString(@"EncryptedInfo", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"Continue", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
        [alert setAlertStyle:NSCriticalAlertStyle];
        if ([alert runModalSheetForWindow:(WINC).window] == NSAlertSecondButtonReturn){
            return;
        }
    }
    [super saveDocument:nil];
    (WINC).isEncrypted = NO;
}

- (IBAction)saveDocumentAs:(id)sender{
    if (!(WINC)._pdfView.document.allowsCopying || !(WINC)._pdfView.document.allowsPrinting) {
        (APPD).parentWin = (WINC).window;
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

#pragma mark - Open Document

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    if ([self windowControllers].count != 0) {
        //復帰のための読み込みの場合
        [WINC revertDocumentToSaved];
    }
    return YES;
}

@end
