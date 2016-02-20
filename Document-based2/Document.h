//
//  Document.h
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/19.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface Document : NSDocument

@property (readwrite,nonatomic)PDFDocument *strPDFDoc; //ファイルから読み込んだPDFドキュメントを保持

@end

