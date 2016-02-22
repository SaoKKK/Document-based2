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
    PDFDocument *doc = [[PDFDocument alloc]initWithURL:[[self document] fileURL]];
    [_pdfView setDocument:doc];
    //ドキュメントの保存過程にノーティフィケーションを設定
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(documentBeginWrite:) name: @"PDFDidBeginDocumentWrite" object: [_pdfView document]];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(documentEndWrite:) name: @"PDFDidEndDocumentWrite" object: [_pdfView document]];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(documentEndPageWrite:) name: @"PDFDidEndPageWrite" object: [_pdfView document]];
    //デリゲートを設定
    [[_pdfView document] setDelegate: self];
}

#pragma mark - saving progress

- (void) documentBeginWrite: (NSNotification *) notification{
    double pgCnt = [[_pdfView document] pageCount];
    [savingProgBar setMaxValue:pgCnt];
    [savingProgBar setDoubleValue: 0.0];
    [progCurrentPg setStringValue:[NSString stringWithFormat: @"%f",pgCnt]];
    //プログレス・パネルをシート表示
    [self.window beginSheet:progressWin completionHandler:^(NSInteger returnCode){}];
    NSLog(@"max-%f",pgCnt);
}

- (void) documentEndWrite: (NSNotification *) notification{
    //プログレス・パネルを終了させる
    [self.window endSheet:progressWin returnCode:0];
}

- (void) documentEndPageWrite: (NSNotification *) notification{
    double currentPg = [[[notification userInfo] objectForKey: @"PDFDocumentPageIndex"] floatValue];
    [savingProgBar setDoubleValue:currentPg];
    [savingProgBar displayIfNeeded];
    [progCurrentPg setStringValue:[NSString stringWithFormat:@"%f/",currentPg]];
    NSLog(@"%f",currentPg);
}

- (IBAction)pshtest:(id)sender {
    NSLog(@"%s",__func__);
    [self.window beginSheet:progressWin completionHandler:^(NSInteger returnCode){}];
}

@end
