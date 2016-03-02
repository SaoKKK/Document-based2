//
//  Document.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/19.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "Document.h"
#import "DocWinC.h"

@interface Document ()

@end

@implementation Document


- (instancetype)init {
    self = [super init];
    if (self) {
    
    }
    return self;
}

//オートセーブ機能のON/OFF
+ (BOOL)autosavesInPlace {
    return NO;
}

- (NSString *)windowNibName {
    return @"Document";
}

- (void)makeWindowControllers{
    //ドキュメントウインドウコントローラのインスタンスを作成
    DocWinC *_docWinC = [[DocWinC alloc]initWithWindowNibName:[self windowNibName]];
    [self addWindowController:_docWinC];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError{
    DocWinC *winC = [[self windowControllers]objectAtIndex:0];
    [winC saveDocument:nil];
    return NULL;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    return YES;
}

@end
