//
//  MyPDFView.h
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/21.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "Document.h"

@interface MyPDFView : PDFView{
}

- (void)saveDocument:(id)sender;
- (void)saveDocumentAs:(id)sender;

@end
