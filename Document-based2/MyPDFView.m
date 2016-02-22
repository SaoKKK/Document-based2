//
//  MyPDFView.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/21.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "MyPDFView.h"

@implementation MyPDFView

#pragma mark - save document

//ドキュメントを保存
- (void)saveDocument:(id)sender{
    NSLog(@"view-save");
}

//ドキュメントを別名で保存
- (void)saveDocumentAs:(id)sender{
    NSLog(@"view-saveas");
}

@end
