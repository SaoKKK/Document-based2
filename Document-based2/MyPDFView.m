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
@synthesize handScrollView,zoomView,startPoint,endPoint,targetPg;

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
    
    //NSLog(@"%f,%f,%f,%f",self.documentView.frame.origin.x,self.documentView.frame.origin.y,self.documentView.frame.size.width,self.documentView.frame.size.height);
    //NSRect rect = [self.currentPage boundsForBox:kPDFDisplayBoxArtBox]; //アートボックス
    NSRect selRect = NSMakeRect(startPoint.x,startPoint.y,endPoint.x-startPoint.x,endPoint.y-startPoint.y);
    NSBezierPath	*path;
    CGFloat lineDash[2];
    lineDash[0]=6;
    lineDash[1]=4;
    path = [NSBezierPath bezierPathWithRect: selRect];
    //[path setLineJoinStyle: NSRoundLineJoinStyle];
    [path setLineDash:lineDash count:2 phase:0.0];
    [path setLineWidth:0.1];
    [[NSColor colorWithDeviceRed: 0.0 green: 1.0 blue: 0.0 alpha: 0.1] set];
    [path fill];
    [[NSColor blackColor] set];
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