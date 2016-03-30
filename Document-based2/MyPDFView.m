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

static CGFloat HandleWidth = 6.0f;

enum UNDEROBJ_TYPE{
    //選択範囲の外
    OUT_AREA,
    //選択範囲
    INSIDE_AREA,
    //選択範囲のハンドル
    HANDLE_TOP_LEFT, HANDLE_TOP_MIDDLE, HANDLE_TOP_RIGHT,
    HANDLE_MIDDLE_LEFT, HANDLE_MIDDLE_RIGHT,
    HANDLE_BOTTOM_LEFT, HANDLE_BOTTOM_MIDDLE, HANDLE_BOTTOM_RIGHT
};

@implementation MyPDFView{
    NSRect pageRect;
    PDFPage *oldPg;
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
    [self deselectArea];
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
                case 1:{
                }
                    break;
            }
            break;
    }
}

//ビュー領域によるカーソル変更
- (void)resetCursorRects{
    switch ([(WINC).segTool selectedSegment]){
        case 1:{
            NSLog(@"sel");
            NSPoint point = [self convertPoint:[NSEvent mouseLocation] fromView:nil];
            if (targetPg == [self pageForPoint:point nearest:NO]) {
                //マウスが選択範囲のあるページ内にあれば
                NSLog(@"sel,yes");
                [self addCursorRect:[self convertRect:selRect fromPage:targetPg] cursor:[NSCursor arrowCursor]];
            } else {
                NSLog(@"sel,no");
                [self addCursorRect:self.bounds cursor:[NSCursor crosshairCursor]];
            }
        }
            break;
        case 3:{ //ズームツール選択時
            [self addCursorRect:self.bounds cursor:[self updateZoomCursor]];
        }
            break;
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
    if ((WINC).segTool.selectedSegment==1 && page == targetPg) {
        if (selRect.size.width != 0 || selRect.size.height != 0) {
            //アンチエイリアスを切る
            NSGraphicsContext *gc = [NSGraphicsContext currentContext];
            [gc saveGraphicsState];
            [gc setShouldAntialias:NO];
            
            float sf = self.scaleFactor;
            NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(selRect.origin.x+1.5/sf, selRect.origin.y+1.5/sf, selRect.size.width-3/sf, selRect.size.height-3/sf)];
            [[NSColor colorWithDeviceRed: 0.35 green: 0.55 blue: 0.75 alpha: 0.2] set];
            [path fill];
            [path setLineWidth:1.5/sf];
            [[NSColor whiteColor] set];
            [path stroke];
            path = [NSBezierPath bezierPathWithRect: selRect];
            [path setLineWidth:1.0/sf];
            [[NSColor colorWithDeviceRed: 0.47 green: 0.55 blue: 0.78 alpha: 1.0] set];
            [path stroke];
            
            [gc restoreGraphicsState];
            [self drawHandle];
        }
    }
}

- (void)drawHandle{
    [self drawHandleAtPoint:NSMakePoint(NSMinX(selRect), NSMinY(selRect))];
    [self drawHandleAtPoint:NSMakePoint(NSMidX(selRect), NSMinY(selRect))];
    [self drawHandleAtPoint:NSMakePoint(NSMaxX(selRect), NSMinY(selRect))];
    [self drawHandleAtPoint:NSMakePoint(NSMinX(selRect), NSMidY(selRect))];
    [self drawHandleAtPoint:NSMakePoint(NSMaxX(selRect), NSMidY(selRect))];
    [self drawHandleAtPoint:NSMakePoint(NSMinX(selRect), NSMaxY(selRect))];
    [self drawHandleAtPoint:NSMakePoint(NSMidX(selRect), NSMaxY(selRect))];
    [self drawHandleAtPoint:NSMakePoint(NSMaxX(selRect), NSMaxY(selRect))];
}

- (void)drawHandleAtPoint:(NSPoint)point{
    float sf = self.scaleFactor;
    NSRect handleRect = NSMakeRect(point.x-(HandleWidth/sf)/2.0, point.y-(HandleWidth/sf)/2.0, HandleWidth/sf, HandleWidth/sf);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPath:[NSBezierPath bezierPathWithOvalInRect:handleRect]];
    [path setLineWidth:3/sf];
    [[NSColor colorWithDeviceRed: 0.47 green: 0.55 blue: 0.78 alpha: 1.0] set];
    [path stroke];
    [[NSColor colorWithCalibratedRed:0.66 green:0.66 blue:0.9 alpha:1.0] set];
    [path fill];
}

#pragma mark - mouse event

- (void)mouseDown:(NSEvent *)theEvent{
    [self deselectArea];
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    //下にある最も近いページの領域をNSView座標系で取得
    targetPg = [self pageForPoint:point nearest:YES];
    pageRect = [self convertRect:[targetPg boundsForBox:kPDFDisplayBoxArtBox] fromPage:targetPg];
    if ([self pageForPoint:point nearest:NO]) {
        //マウスダウンの座標がページ領域内であればその座標をページ座標系に変換してstartPointに格納
        startPoint = [self convertPoint:point toPage:targetPg];
    } else {
        //マウスダウンの座標がページ領域外だった場合
        startPoint = [self convertPoint:[self areaPointFromOutPoint:point] toPage:targetPg];
    }
    selRect = NSMakeRect(startPoint.x, startPoint.y, 0, 0);
}

- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint endPoint;
    if (NSPointInRect(point, pageRect)) {
        //ドラッグ座標がページ領域内であればその座標をページ座標系に変換して使用
        endPoint = [self convertPoint:point toPage:targetPg];
    } else {
        //ドラッグ座標がページ領域外だった場合
        endPoint = [self convertPoint:[self areaPointFromOutPoint:point] toPage:targetPg];
    }
    selRect.size.width = endPoint.x - startPoint.x;
    selRect.size.height = endPoint.y - startPoint.y;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent{
    //ページ選択履歴を残す
    oldPg = targetPg;
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if (point.x == startPoint.x && point.y == startPoint.y){
        //シングルクリックの場合

    } else {
        
    }
}

//マウス座標がページ領域外だった場合の選択領域作成のための座標を返す
- (NSPoint)areaPointFromOutPoint:(NSPoint)point{
    NSPoint areaPoint;
    if (point.x < pageRect.origin.x) {
        //x座標がページの左側の場合
        areaPoint.x = pageRect.origin.x;
    } else if (point.x > pageRect.origin.x + pageRect.size.width){
        //x座標がページの右側の場合
        areaPoint.x = pageRect.origin.x + pageRect.size.width;
    } else {
        //x座標がページの領域内の場合
        areaPoint.x = point.x;
    }
    if (point.y < pageRect.origin.y){
        //y座標がページの下側の場合
        areaPoint.y = pageRect.origin.y;
    } else if (point.y > pageRect.origin.y + pageRect.size.height){
        //y座標がページの上側の場合
        areaPoint.y = pageRect.origin.y + pageRect.size.height;
    } else {
        //y座標がページの領域内の場合
        areaPoint.y = point.y;
    }
    return areaPoint;
}

//選択領域の解除
- (void)deselectArea{
    selRect = NSZeroRect;
    [self setNeedsDisplay:YES];
}

@end