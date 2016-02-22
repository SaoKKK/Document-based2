//
//  MyPDFView.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/21.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "MyPDFView.h"
#import "Document.h"

@implementation MyPDFView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(void)saveDocumentAs:(id)sender{
    NSLog(@"saveas");
}

@end
