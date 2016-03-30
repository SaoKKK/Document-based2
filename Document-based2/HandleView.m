//
//  HandleView.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/03/17.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "HandleView.h"

#define APPD (AppDelegate *)[NSApp delegate]
#define WINC (DocWinC *)self.window.windowController
#define PVIEW (WINC)._pdfView

//static CGFloat HandleWidth = 8.0f;

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

@implementation HandleView{
    NSPoint dragPoint;
    CAShapeLayer *shapeLayer;
    NSRect pageRect;
}
@synthesize page;

- (void)drawRect:(NSRect)dirtyRect {
    [self setLayer:[CALayer new]];
    [self setWantsLayer:YES];
}

- (void)mouseDown:(NSEvent *)theEvent{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    //下にある最も近いページの領域をNSView座標系で取得
    page = [PVIEW pageForPoint:point nearest:YES];
    pageRect = [PVIEW convertRect:[page boundsForBox:kPDFDisplayBoxArtBox] fromPage:page];
    if ([PVIEW pageForPoint:point nearest:NO]) {
        //マウスダウンの座標がページ領域内であればその座標をstartPointに格納
        (PVIEW).startPoint = [PVIEW convertPoint:point toPage:page];
    } else {
        (PVIEW).startPoint = [PVIEW convertPoint:[self areaPointFromOutPoint:point] toPage:page];
    }
    //shape layerを作成
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.strokeColor = [[NSColor blackColor] CGColor];
    shapeLayer.fillColor = CGColorCreateGenericRGB(0.35, 0.55, 0.75, 0.2);
    shapeLayer.lineDashPattern = @[@6, @4];
    [shapeLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
    [self.layer addSublayer:shapeLayer];
    //アニメーションを作成
    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
    [dashAnimation setFromValue:@0.0f];
    [dashAnimation setToValue:@15.0f];
    [dashAnimation setDuration:0.75f];
    [dashAnimation setRepeatCount:HUGE_VALF];
    [shapeLayer addAnimation:dashAnimation forKey:@"linePhase"];
    [self setNeedsDisplay:YES];
    [PVIEW setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if (NSPointInRect(point, pageRect)) {
        //ドラッグ座標がページ領域内であればその座標をdragPointに格納
        (PVIEW).endPoint = [PVIEW convertPoint:point toPage:page];
    } else {
        //ドラッグ座標がページ領域外だった場合
        point = [self areaPointFromOutPoint:point];
        (PVIEW).endPoint = [PVIEW convertPoint:[self areaPointFromOutPoint:point] toPage:page];
    }
    //shape layerのパスを作成
    [self createShapePath];
    [PVIEW setNeedsDisplay:YES];
    
}

- (void)createShapePath{
    //shape layerのパスを作成
    CGPoint viewSPoint = [PVIEW convertPoint:(PVIEW).startPoint fromPage:page];
    //viewSPoint = [self.superview convertPoint:viewSPoint toView:self];
    NSRect oframe = [PVIEW convertRect:NSZeroRect fromView: self];
    NSLog(@"%f,%f,%f,%f",oframe.origin.x,oframe.origin.y,oframe.size.width,oframe.size.height);
    NSPoint viewEPoint = [PVIEW convertPoint:(PVIEW).endPoint fromPage:page];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, viewSPoint.x, viewSPoint.y);
    CGPathAddLineToPoint(path, NULL, viewSPoint.x, viewEPoint.y);
    CGPathAddLineToPoint(path, NULL, viewEPoint.x, viewEPoint.y);
    CGPathAddLineToPoint(path, NULL, viewEPoint.x, viewSPoint.y);
    CGPathCloseSubpath(path);
    shapeLayer.path = path;
    [shapeLayer displayIfNeeded];
    CGPathRelease(path);
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if (point.x == (PVIEW).startPoint.x && point.y == (PVIEW).startPoint.y){
        //シングルクリックの場合=選択範囲の領域外であれば選択を解除
        [shapeLayer removeFromSuperlayer];
        shapeLayer = nil;
    } else {
        NSPoint endPoint;
        if (NSPointInRect(point, pageRect)) {
            //マウスアップの座標がページ領域内であればその座標をendPointに格納
            endPoint = point;
        } else {
            endPoint = [self areaPointFromOutPoint:point];
        }
        //拡大エリアが作成された場合
        NSRect expArea = NSMakeRect(MIN((PVIEW).startPoint.x,endPoint.x), MIN((PVIEW).startPoint.y,endPoint.y), fabs((PVIEW).startPoint.x-endPoint.x), fabs((PVIEW).startPoint.y-endPoint.y));
        //拡大率を決定(縦横で倍率を出して小さい方を採用)
        float enlargementFactorFromWidth = (PVIEW).bounds.size.width/expArea.size.width;
        float enlargementFactorFromHeight = (PVIEW).bounds.size.height/expArea.size.height;
        float enlargementFactor = MIN(enlargementFactorFromWidth,enlargementFactorFromHeight);
        if (enlargementFactor > 5.0) {
            enlargementFactor = 5.0;
        }
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

@end