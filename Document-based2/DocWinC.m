//
//  DocWinC.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/20.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "DocWinC.h"
#import "Document.h"

@interface DocWinC ()

@end

@implementation DocWinC

@synthesize _pdfView;

#pragma mark - Window Controller Method

- (void)windowDidLoad {
    [super windowDidLoad];
    Document *doc = [self document];
    //ファイルから読み込まれたPDFドキュメントをビューに表示
    [_pdfView setDocument:doc.strPDFDoc];
}

@end
