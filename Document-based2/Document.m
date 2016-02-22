//
//  Document.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/19.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "Document.h"
#import "DocWinC.h"

@interface Document ()

@end

@implementation Document

@synthesize strPDFDoc;

- (instancetype)init {
    self = [super init];
    if (self) {
        strPDFDoc = nil;
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

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    //ドキュメントデータを読み込みドキュメントウインドウに表示
    PDFDocument *_pdfDoc = [[PDFDocument alloc]initWithURL:[self fileURL]];
    if (! _pdfDoc) {
        //ファイルの読み込みに失敗した場合
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
        return NO;
    } else {
        if ([self windowControllers].count != 0) {
            //復帰のための読み込みの場合（既存のPDFビューに直接読み込む）
            DocWinC *winCtr = [[self windowControllers]objectAtIndex:0];
            [winCtr._pdfView setDocument:_pdfDoc];
        } else {
            strPDFDoc = _pdfDoc;
        }
    }
    return YES;
}

#pragma mark - Saving document

//ドキュメントを保存
- (void)saveDocument:(id)sender{
    DocWinC *winCtr = [[self windowControllers]objectAtIndex:0];
    [winCtr._pdfView.document writeToURL:self.fileURL];
}

//ドキュメントを別名で保存
- (void)saveDocumentAs:(id)sender{
    //savePanelの設定と表示
    NSSavePanel *savepanel = [NSSavePanel savePanel];
    NSArray *fileTypes = [NSArray arrayWithObjects:@"pdf", nil];
    [savepanel setAllowedFileTypes:fileTypes]; //保存するファイルの種類
    [savepanel setNameFieldStringValue:[self.fileURL.path lastPathComponent]]; //初期ファイル名
    [savepanel setCanSelectHiddenExtension:YES]; //拡張子を隠すチェックボックスの有無
    [savepanel setExtensionHidden:NO]; //拡張子を隠すチェックボックスの初期ステータス
    [savepanel validateVisibleColumns]; //初期表示でディレクトリの内容表示の可否
    DocWinC *winCtr = [[self windowControllers]objectAtIndex:0];
    [savepanel beginSheetModalForWindow:winCtr.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            [winCtr._pdfView.document writeToURL:[savepanel URL]];
        }
    }];
}

@end
