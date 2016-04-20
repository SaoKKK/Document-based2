//
//  DocInfoPanel.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/03/16.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "DocInfoPanel.h"

#define APPD (AppDelegate *)[NSApp delegate]

@interface DocInfoPanel (){
    IBOutlet NSTextField *txtFName;
    IBOutlet NSTextField *txtFPath;
    IBOutlet NSTextField *txtCDate;
    IBOutlet NSTextField *txtMDate;
    IBOutlet NSTextField *txtVer;
    IBOutlet NSTextField *txtPage;
    IBOutlet NSTextField *txtSecurity;
    IBOutlet NSTextField *txtCopy;
    IBOutlet NSTextField *txtPrint;
    IBOutlet NSTextField *txtCreator;
    IBOutlet NSTextField *txtProducer;
    IBOutlet NSTextField *txtTitle;
    IBOutlet NSTextField *txtAuthor;
    IBOutlet NSTextField *txtSubject;
    IBOutlet NSTextField *txtKeyword;
    IBOutlet NSSecureTextField *txtUPass1;
    IBOutlet NSSecureTextField *txtUPass2;
    IBOutlet NSSecureTextField *txtOPass1;
    IBOutlet NSSecureTextField *txtOPass2;
    IBOutlet NSButton *rdForbidCopy;
    IBOutlet NSButton *rdForbidPrint;
    IBOutlet NSTextField *txtLock;
}

@end

@implementation DocInfoPanel

- (void)windowDidLoad {
    [super windowDidLoad];
    NSDocumentController *docC = [NSDocumentController sharedDocumentController];
    DocWinC *winC = [docC.currentDocument.windowControllers objectAtIndex:0];
    if (winC) {
        PDFDocument *doc = winC._pdfView.document;
        NSDictionary *attr = [doc documentAttributes];
        [txtFName setStringValue:winC.docURL.path.lastPathComponent];
        [txtFPath setStringValue:winC.docURL.path];
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        format.dateStyle = NSDateFormatterLongStyle;
        format.timeStyle = NSDateFormatterMediumStyle;
        [txtCDate setStringValue:[format stringFromDate:[attr objectForKey:PDFDocumentCreationDateAttribute]]];
        [txtMDate setStringValue:[format stringFromDate:[attr objectForKey:PDFDocumentModificationDateAttribute]]];
        [txtVer setStringValue:[NSString stringWithFormat:@"%d.%d", [doc majorVersion], [doc minorVersion]]];
        [txtPage setStringValue:[NSString stringWithFormat:@"%li",[doc pageCount]]];
        if (doc.isEncrypted){
            [txtSecurity setStringValue:NSLocalizedString(@"Encrypted", @"")];
        } else {
            [txtSecurity setStringValue:NSLocalizedString(@"None", @"")];
        }
        if (doc.allowsCopying) {
            [txtCopy setStringValue:NSLocalizedString(@"Allow", @"")];
            (APPD).isCopyLocked = NO;
        } else {
            [txtCopy setStringValue:NSLocalizedString(@"Forbid", @"")];
            (APPD).isCopyLocked = YES;
        }
        if (doc.allowsPrinting) {
            [txtPrint setStringValue:NSLocalizedString(@"Allow", @"")];
        } else {
            [txtPrint setStringValue:NSLocalizedString(@"Forbid", @"")];
        }
        if ([attr objectForKey:PDFDocumentCreatorAttribute]) {
            [txtCreator setStringValue:[attr objectForKey:PDFDocumentCreatorAttribute]];
        }
        if ([attr objectForKey:PDFDocumentProducerAttribute]) {
            [txtProducer setStringValue:[attr objectForKey:PDFDocumentProducerAttribute]];
        }
        if ([attr objectForKey:PDFDocumentTitleAttribute]) {
            [txtTitle setStringValue:[attr objectForKey:PDFDocumentTitleAttribute]];
        }
        if ([attr objectForKey:PDFDocumentAuthorAttribute]) {
            [txtAuthor setStringValue:[attr objectForKey:PDFDocumentAuthorAttribute]];
        }
        if ([attr objectForKey:PDFDocumentSubjectAttribute]) {
            [txtSubject setStringValue:[attr objectForKey:PDFDocumentSubjectAttribute]];
        }
        if ([attr objectForKey:PDFDocumentKeywordsAttribute]) {
            NSArray *keywords = [attr objectForKey:PDFDocumentKeywordsAttribute];
            NSString *keyStr = @"";
            if (keywords) {
                for (NSString *keyword in keywords){
                    if ([keyStr isEqualToString:@""]) {
                        keyStr = [NSString stringWithFormat:@"%@",keyword];
                    } else {
                        keyStr = [NSString stringWithFormat:@"%@,%@",keyStr,keyword];
                    }
                }
            }
            [txtKeyword setStringValue:keyStr];
        }
    }
}

- (IBAction)pshLock:(id)sender {
    if ([sender state]){
        if ((APPD).isCopyLocked) {
            (APPD).parentWin = self.window;
            [(APPD).pwMsgTxt setStringValue:NSLocalizedString(@"UnlockEditMsg", @"")];
            [(APPD).pwInfoTxt setStringValue:NSLocalizedString(@"UnlockEditInfo", @"")];
            [self.window beginSheet:(APPD).passWin completionHandler:^(NSInteger returnCode){
                if (returnCode == NSModalResponseCancel) {
                    [sender setState:NO];
                } else {
                    [txtCopy setStringValue:NSLocalizedString(@"Allow", @"")];
                    [txtPrint setStringValue:NSLocalizedString(@"Allow", @"")];
                    [txtLock setStringValue:NSLocalizedString(@"Lock", @"")];
                    (APPD).isCopyLocked = NO;
                    (APPD).isLocked = YES;
                }
            }];
        } else {
            [txtLock setStringValue:NSLocalizedString(@"Lock", @"")];
            (APPD).isLocked = YES;
        }
    } else {
        [txtLock setStringValue:NSLocalizedString(@"Unlock", @"")];
        (APPD).isLocked = NO;
    }
}

- (IBAction)pshUpdate:(id)sender {
    DocWinC *winC = self.window.sheetParent.windowController;
    PDFDocument *doc = winC._pdfView.document;
    //入力値のチェック
    NSString *uPass = txtUPass1.stringValue;
    NSString *oPass = txtOPass1.stringValue;
    if (rdForbidCopy.state || rdForbidPrint.state) {
        if ([oPass isEqualToString:@""]) {
            [self showPassAllert:NSLocalizedString(@"oNoneMsg",@"") info:NSLocalizedString(@"oNoneInfo",@"")];
            return;
        }
    }
    if ([oPass isNotEqualTo:txtOPass2.stringValue]) {
        [self showPassAllert:NSLocalizedString(@"oPassMsg",@"") info:NSLocalizedString(@"passInfo",@"")];
        return;
    }
    if ([uPass isNotEqualTo:txtUPass2.stringValue]) {
        [self showPassAllert:NSLocalizedString(@"uPassMsg",@"") info:NSLocalizedString(@"passInfo",@"")];
        return;
    }
    //書類の概説を更新
    NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary:doc.documentAttributes];
    [attr setObject:txtTitle.stringValue forKey:PDFDocumentTitleAttribute];
    [attr setObject:txtAuthor.stringValue forKey:PDFDocumentAuthorAttribute];
    [attr setObject:txtSubject.stringValue forKey:PDFDocumentSubjectAttribute];
    [attr setObject:[txtKeyword.stringValue componentsSeparatedByString:@","] forKey:PDFDocumentKeywordsAttribute];
    [doc setDocumentAttributes:attr];
    //ここで保存しない場合はドキュメント更新履歴を更新する
    //ドキュメントの暗号化
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    NSDictionary *option = [NSDictionary dictionary];
    if (![uPass isEqualToString:@""]) {
        option = [NSDictionary dictionaryWithObjectsAndKeys:uPass,kCGPDFContextUserPassword, nil];
        [options addEntriesFromDictionary:option];
        if ([oPass isEqualToString:@""]) {
            option = [NSDictionary dictionaryWithObjectsAndKeys:oPass,kCGPDFContextOwnerPassword, nil];
            [options addEntriesFromDictionary:option];
        }
    }
    if (![oPass isEqualToString:@""]) {
        option = [NSDictionary dictionaryWithObjectsAndKeys:oPass,kCGPDFContextOwnerPassword, nil];
        [options addEntriesFromDictionary:option];
        CFBooleanRef aCopy,aPrint;
        if (rdForbidCopy.state) {
            aCopy = kCFBooleanFalse;
        } else {
            aCopy = kCFBooleanTrue;
        }
        if (rdForbidPrint.state) {
            aPrint = kCFBooleanFalse;
        } else {
            aPrint = kCFBooleanTrue;
        }
        option = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id _Nonnull)(aCopy),kCGPDFContextAllowsCopying,(__bridge id _Nonnull)(aPrint),kCGPDFContextAllowsPrinting, nil];
        [options addEntriesFromDictionary:option];
    }
    [doc writeToURL: winC.docURL withOptions: options];
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (NSInteger)showPassAllert:(NSString*)msgTxt info:(NSString*)infoTxt{
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = msgTxt;
    [alert setInformativeText:infoTxt];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSCriticalAlertStyle];
    return [alert runModalSheetForWindow:self.window];
}

- (IBAction)pshCancel:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseCancel];
}

@end
