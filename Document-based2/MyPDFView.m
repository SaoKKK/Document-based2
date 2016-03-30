//
//  MyPDFView.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/21.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "MyPDFView.h"

#define APPD (AppDelegate *)[NSApp delegate]
#define WINC (DocWinC *)self.window.windowController

@implementation MyPDFView{
    BOOL isZoomCursorSet;
}
@synthesize handScrollView,zoomView,startPoint,selRect,targetPg;

- (void)awakeFromNib{
    isZoomCursorSet = NO;
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResizeNotification object:self.window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        //ウインドウのリサイズ時→サブビューをリサイズする
        [handScrollView setFrame:self.bounds];
        [zoomView setFrame:self.bounds];
    }];
}

#pragma mark - sub view control

- (void)loadHandScrollView{
    [self removeSubView];
    handScrollView = [[HandScrollView alloc]initWithFrame:self.bounds];
    [self addSubview:handScrollView];
}

- (void)loadZoomView{
    [self removeSubView];
    zoomView = [[ZoomView alloc]initWithFrame:self.bounds];
    [self addSubview:zoomView];
    isZoomCursorSet = YES;
}

- (void)removeSubView{
    [handScrollView removeFromSuperview];
    [zoomView removeFromSuperview];
    isZoomCursorSet = NO;
}

#pragma mark - cursor control

//ページ領域によるカーソル変更
- (void)setCursorForAreaOfInterest:(PDFAreaOfInterest)area{
    [self.window makeFirstResponder:self];
    switch ([(WINC).segTool selectedSegment]){
        case 0: //テキスト選択ツール選択時
            [super setCursorForAreaOfInterest:area];
            break;
        case 1: //エリア選択ツール選択時
            switch (area) {
                case 0:
                    [super setCursorForAreaOfInterest:area];
                    break;
                case 1:
                    [[NSCursor crosshairCursor] set];
                    break;
            }
            break;
    }
}

//ビュー領域によるカーソル変更
- (void)resetCursorRects{
    //ズームツール選択時はカーソル形状を変更
    if (isZoomCursorSet){
        [self addCursorRect:self.bounds cursor:[self updateZoomCursor]];
    }
}

//ズームカーソルになっている時にoptionキーが押されたら縮小カーソルに変更
- (void)flagsChanged:(NSEvent *)theEvent{
    if (isZoomCursorSet){
        [[self updateZoomCursor] set];
    } else {
        [super flagsChanged:theEvent];
    }
}

//ズームカーソル更新
- (NSCursor*)updateZoomCursor{
    [self discardCursorRects];
    NSCursor *cursor;
    if ([NSEvent modifierFlags] & NSAlternateKeyMask) {
        if (self.canZoomOut) {
            cursor = [[NSCursor alloc]initWithImage:[NSImage imageNamed:@"cZoomOut"] hotSpot:NSMakePoint(7, 7)];
        } else {
            cursor = [[NSCursor alloc]initWithImage:[NSImage imageNamed:@"cZoom"] hotSpot:NSMakePoint(7, 7)];
        }
    } else {
        if (self.scaleFactor < 5) {
            cursor = [[NSCursor alloc]initWithImage:[NSImage imageNamed:@"cZoomIn"] hotSpot:NSMakePoint(7, 7)];
        } else {
            cursor = [[NSCursor alloc]initWithImage:[NSImage imageNamed:@"cZoom"] hotSpot:NSMakePoint(7, 7)];
        }
    }
    return cursor;
}

#pragma mark - draw page

- (void)drawPage:(PDFPage *)page{
    [super drawPage: page];
    
    //選択範囲を描画
    NSBezierPath *path = [NSBezierPath bezierPathWithRect: selRect];
    [[NSColor colorWithDeviceRed: 0.35 green: 0.55 blue: 0.75 alpha: 0.2] set];
    [path fill];
    [path setLineWidth:0.5];
    [[NSColor colorWithDeviceRed: 0.47 green: 0.55 blue: 0.78 alpha: 1.0] set];
    [path stroke];
    path = [NSBezierPath bezierPathWithRect:NSMakeRect(selRect.origin.x+0.75, selRect.origin.y+0.75, selRect.size.width-1.5, selRect.size.height-1.5)];
    [path setLineWidth:1.0];
    [[NSColor whiteColor] set];
    [path stroke];
}

#pragma mark - mouse event

- (void)mouseDown:(NSEvent *)theEvent{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    //処理対象ページを限定
    targetPg = [self pageForPoint:point nearest:YES];
    NSLog(@"%@",targetPg);

}

@end