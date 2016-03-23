//
//  ZoomView.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/03/23.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "ZoomView.h"

#define APPD (AppDelegate *)[NSApp delegate]
#define WINC (DocWinC *)self.window.windowController

@implementation ZoomView{
    NSPoint downPoint;
    CAShapeLayer *shapeLayer;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self setLayer:[CALayer new]];
    [self setWantsLayer:YES];
    [self.layer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.5, 0.2)];
}

- (void)mouseDown:(NSEvent *)theEvent{
    downPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    (APPD).selPoint = downPoint;
    
    // create and configure shape layer
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.strokeColor = [[NSColor blackColor] CGColor];
    shapeLayer.fillColor = [[NSColor clearColor] CGColor];
    shapeLayer.lineDashPattern = @[@10, @5];
    [self.layer addSublayer:shapeLayer];
    // create animation for the layer
    
    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
    [dashAnimation setFromValue:@0.0f];
    [dashAnimation setToValue:@15.0f];
    [dashAnimation setDuration:0.75f];
    [dashAnimation setRepeatCount:HUGE_VALF];
    [shapeLayer addAnimation:dashAnimation forKey:@"linePhase"];
    [self setNeedsDisplay:YES];
    
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    // create path for the shape layer
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, downPoint.x, downPoint.y);
    CGPathAddLineToPoint(path, NULL, downPoint.x, point.y);
    CGPathAddLineToPoint(path, NULL, point.x, point.y);
    CGPathAddLineToPoint(path, NULL, point.x, downPoint.y);
    CGPathCloseSubpath(path);
    
    // set the shape layer's path
    
    shapeLayer.path = path;
    
    CGPathRelease(path);
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent{
    NSPoint upPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    //シングルクリックの場合
    if (upPoint.x == downPoint.x && upPoint.y == downPoint.y){
        if ([NSEvent modifierFlags] & NSAlternateKeyMask){
            [WINC zoomOut:nil];
        } else {
            if ((WINC)._pdfView.scaleFactor <5) {
                [WINC zoomIn:nil];
            }
        }
    }
    [shapeLayer removeFromSuperlayer];
    shapeLayer = nil;
}

@end
