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
    IBOutlet NSButton *chkForbidCopy;
    IBOutlet NSButton *chkForbidPrint;
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
        txtFName.stringValue = [self stringOrEmpty:winC.docURL.path.lastPathComponent];
        txtFPath.stringValue = [self stringOrEmpty:winC.docURL.path];
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        format.dateStyle = NSDateFormatterLongStyle;
        format.timeStyle = NSDateFormatterMediumStyle;
        txtCDate.stringValue = [self stringOrEmpty:[format stringFromDate:[attr objectForKey:PDFDocumentCreationDateAttribute]]];
        txtMDate.stringValue = [self stringOrEmpty:[format stringFromDate:[attr objectForKey:PDFDocumentModificationDateAttribute]]];
        txtVer.stringValue = [NSString stringWithFormat:@"%d.%d", [doc majorVersion], [doc minorVersion]];
        txtPage.stringValue = [NSString stringWithFormat:@"%li",[doc pageCount]];
        if (doc.isEncrypted){
            txtSecurity.stringValue = NSLocalizedString(@"Encrypted", @"");
        } else {
            txtSecurity.stringValue = NSLocalizedString(@"None", @"");
        }
        if (doc.allowsCopying) {
            txtCopy.stringValue = NSLocalizedString(@"Allow", @"");
            (APPD).isCopyLocked = NO;
        } else {
            txtCopy.stringValue = NSLocalizedString(@"Forbid", @"");
            (APPD).isCopyLocked = YES;
        }
        if (doc.allowsPrinting) {
            txtPrint.stringValue = NSLocalizedString(@"Allow", @"");
            (APPD).isPrintLocked = NO;
        } else {
            txtPrint.stringValue = NSLocalizedString(@"Forbid", @"");
            (APPD).isPrintLocked = YES;
        }
        txtCreator.stringValue = [self stringOrEmpty:[attr objectForKey:PDFDocumentCreatorAttribute]];
        txtProducer.stringValue = [self stringOrEmpty:[attr objectForKey:PDFDocumentProducerAttribute]];
        txtTitle.stringValue = [self stringOrEmpty:[attr objectForKey:PDFDocumentTitleAttribute] ];
        txtAuthor.stringValue = [self stringOrEmpty:[attr objectForKey:PDFDocumentAuthorAttribute]];
        txtSubject.stringValue = [self stringOrEmpty:[attr objectForKey:PDFDocumentSubjectAttribute]];
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
            txtKeyword.stringValue = keyStr;
        }
    }
}

//nil値を空文字に変換
- (NSString*)stringOrEmpty:(NSString*)str{
    return str ? str : @"";
}

- (IBAction)pshLock:(id)sender {
    if ([sender state]){
        if ((APPD).isCopyLocked || (APPD).isPrintLocked) {
            (APPD).parentWin = self.window;
            (APPD).pwMsgTxt.stringValue = NSLocalizedString(@"UnlockEditMsg", @"");
            (APPD).pwInfoTxt.stringValue = NSLocalizedString(@"UnlockEditInfo", @"");
            [self.window beginSheet:(APPD).passWin completionHandler:^(NSInteger returnCode){
                if (returnCode == NSModalResponseCancel) {
                    [sender setState:NO];
                } else {
                    txtCopy.stringValue = NSLocalizedString(@"Allow", @"");
                    txtPrint.stringValue = NSLocalizedString(@"Allow", @"");
                    txtLock.stringValue = NSLocalizedString(@"Lock", @"");
                    (APPD).isCopyLocked = NO;
                    (APPD).isPrintLocked = NO;
                    (APPD).isLocked = YES;
                }
            }];
        } else {
            txtLock.stringValue = NSLocalizedString(@"Lock", @"");
            (APPD).isLocked = YES;
        }
    } else {
        txtLock.stringValue = NSLocalizedString(@"Unlock", @"");
        (APPD).isLocked = NO;
    }
}

- (IBAction)pshUpdate:(id)sender {
    DocWinC *winC = self.window.sheetParent.windowController;
    PDFDocument *doc = winC._pdfView.document;
    //入力値のチェック
    NSString *uPass = txtUPass1.stringValue;
    NSString *oPass = txtOPass1.stringValue;
    if (chkForbidCopy.state || chkForbidPrint.state) {
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
    if ([oPass isNotEqualTo:@""] && [oPass isEqualToString:uPass]) {
        [self showPassAllert:NSLocalizedString(@"passSameMsg",@"") info:NSLocalizedString(@"passInfo",@"")];
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
        if (chkForbidCopy.state) {
            aCopy = kCFBooleanFalse;
        } else {
            aCopy = kCFBooleanTrue;
        }
        if (chkForbidPrint.state) {
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
