//
//  DocInfoPanel.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/03/16.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "DocInfoPanel.h"

@interface DocInfoPanel (){
    IBOutlet NSSecureTextField *txtPass1;
    IBOutlet NSSecureTextField *txtPass2;
}

@end

@implementation DocInfoPanel

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (IBAction)pshUpdate:(id)sender {
    DocWinC *docWinC = self.window.sheetParent.windowController;
    /*
    CFURLRef url = (__bridge CFURLRef)[docWinC.document fileURL];
    CGPDFDocumentRef doc = CGPDFDocumentCreateWithURL(url);
    */
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: @"owner", kCGPDFContextOwnerPassword, @"user", kCGPDFContextUserPassword, nil];
    [docWinC._pdfView.document writeToFile: @"/Users/kounosaori/Desktop/aaa.pdf" withOptions: options];

}

- (IBAction)pshCancel:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}

@end
