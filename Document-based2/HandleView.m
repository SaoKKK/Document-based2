//
//  HandleView.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/03/17.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "HandleView.h"

@implementation HandleView{
    NSRect _spot_rect;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self setLayer:[CALayer new]];
    [self setWantsLayer:YES];
    [self.layer setBackgroundColor:CGColorCreateGenericRGB(0.5, 0.0, 0.0, 0.2)];
}

- (void)mouseDown:(NSEvent *)theEvent{
    self.startPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    // create and configure shape layer
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.lineWidth = 1.0;
    self.shapeLayer.strokeColor = [[NSColor blackColor] CGColor];
    self.shapeLayer.fillColor = [[NSColor clearColor] CGColor];
    self.shapeLayer.lineDashPattern = @[@10, @5];
    [self.layer addSublayer:self.shapeLayer];
    // create animation for the layer
    
    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
    [dashAnimation setFromValue:@0.0f];
    [dashAnimation setToValue:@15.0f];
    [dashAnimation setDuration:0.75f];
    [dashAnimation setRepeatCount:HUGE_VALF];
    [self.shapeLayer addAnimation:dashAnimation forKey:@"linePhase"];
    [self setNeedsDisplay:YES];

}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    // create path for the shape layer
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.startPoint.x, self.startPoint.y);
    CGPathAddLineToPoint(path, NULL, self.startPoint.x, point.y);
    CGPathAddLineToPoint(path, NULL, point.x, point.y);
    CGPathAddLineToPoint(path, NULL, point.x, self.startPoint.y);
    CGPathCloseSubpath(path);
    
    // set the shape layer's path
    
    self.shapeLayer.path = path;
    
    CGPathRelease(path);
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = nil;
}

@end
