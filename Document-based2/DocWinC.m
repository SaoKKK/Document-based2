//
//  DocWinC.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/20.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "DocWinC.h"
#import "Document.h"
#import "MyPDFView.h"

@interface DocWinC ()

@end

@implementation DocWinC

#pragma mark - Window Controller Method

- (void)windowDidLoad {
    [super windowDidLoad];
    //ファイルから読み込まれたPDFドキュメントをビューに表示
    docURL = [[self document] fileURL];
    PDFDocument *doc = [[PDFDocument alloc]initWithURL:docURL];
    [_pdfView setDocument:doc];
    //ノーティフィケーションを設定
    [self setUpNotification];
    //デリゲートを設定
    [[_pdfView document] setDelegate: self];
    //オート・スケールをオフにする
    [_pdfView setAutoScales:NO];
    //ページ表示テキストフィールドを更新
    NSUInteger totalPg = _pdfView.document.pageCount;
    [txtTotalPg setStringValue:[NSString stringWithFormat:@"%li",totalPg]];
    [txtPageFormatter setMaximum:[NSNumber numberWithInteger:totalPg]];
    //ページ表示テキストフィールドの値を変更
    [self updateTxtPg];
}

#pragma mark - Setup notification

- (void)setUpNotification{
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PDFDidBeginDocumentWrite" object:[_pdfView document] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        double pgCnt = [[_pdfView document] pageCount];
        [savingProgBar setMaxValue:pgCnt];
        [savingProgBar setDoubleValue: 0.0];
        //プログレス・パネルをシート表示
        [self.window beginSheet:progressWin completionHandler:^(NSInteger returnCode){}];
    }];
    //ドキュメント保存中
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PDFDidEndDocumentWrite" object:[_pdfView document] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        //プログレス・バーの値を更新
        double currentPg = [[notif.userInfo objectForKey: @"PDFDocumentPageIndex"] floatValue];
        [savingProgBar setDoubleValue:currentPg];
        [savingProgBar displayIfNeeded];
    }];
    //ドキュメント保存完了
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PDFDidEndPageWrite" object:[_pdfView document] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        //プログレス・パネルを終了させる
        [self.window endSheet:progressWin returnCode:0];
    }];
    //ページ移動
    [[NSNotificationCenter defaultCenter] addObserverForName:PDFViewPageChangedNotification object:_pdfView queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        //ページ移動ボタンの有効/無効の切り替え
        if (_pdfView.canGoToFirstPage) {
            [btnGoToFirstPg setEnabled:YES];
        } else {
            [btnGoToFirstPg setEnabled:NO];
        }
        if (_pdfView.canGoToPreviousPage) {
            [btnGoToPrevPg setEnabled:YES];
        } else {
            [btnGoToPrevPg setEnabled:NO];
        }
        if (_pdfView.canGoToNextPage){
            [btnGoToNextPg setEnabled:YES];
        } else {
            [btnGoToNextPg setEnabled:NO];
        }
        if (_pdfView.canGoToLastPage){
            [btnGoToLastPg setEnabled:YES];
        } else {
            [btnGoToLastPg setEnabled:NO];
        }
        if (_pdfView.canGoBack) {
            [btnGoBack setEnabled:YES];
        } else {
            [btnGoBack setEnabled:NO];
        }
        if (_pdfView.canGoForward) {
            [btnGoFoward setEnabled:YES];
        } else {
            [btnGoFoward setEnabled:NO];
        }
        //ページ表示テキストフィールドの値を変更
        [self updateTxtPg];
    }];
}

- (void) updateTxtPg {
    PDFDocument *doc = _pdfView.document;
    NSUInteger index = [doc indexForPage:[_pdfView currentPage]] + 1;
    [txtPg setStringValue:[NSString stringWithFormat:@"%li",index]];
}

#pragma mark - Actions

- (IBAction)txtJumpPage:(id)sender {
    PDFDocument *doc = [_pdfView document];
    PDFPage *page = [doc pageAtIndex:[[sender stringValue]integerValue]-1];
    [_pdfView goToPage:page];
}

#pragma mark - Save document

//ドキュメントを保存
- (void)saveDocument:(id)sender{
    [_pdfView.document writeToURL:docURL];
}

//ドキュメントを別名で保存
- (void)saveDocumentAs:(id)sender{
    //savePanelの設定と表示
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    NSArray *fileTypes = [NSArray arrayWithObjects:@"pdf", nil];
    [savePanel setAllowedFileTypes:fileTypes]; //保存するファイルの種類
    [savePanel setNameFieldStringValue:[[docURL path] lastPathComponent]]; //初期ファイル名
    [savePanel setCanSelectHiddenExtension:YES]; //拡張子を隠すチェックボックスの有無
    [savePanel setExtensionHidden:NO]; //拡張子を隠すチェックボックスの初期ステータス
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            docURL = [savePanel URL];
            [savePanel orderOut:self];
            [_pdfView.document writeToURL:docURL];
            Document *doc = [self document];
            //ドキュメントのURLを更新
            [doc setFileURL:docURL];
       }
    }];
}

@end
