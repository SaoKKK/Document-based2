//
//  MyPDFView.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/21.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "MyPDFView.h"

@implementation MyPDFView{
    HandleView *handleView;
    NSView *view;
}

- (void)awakeFromNib{
    handleView = [[HandleView alloc]init];
    [self addSubview:handleView];
}

- (void)drawRect:(NSRect)dirtyRect{
    
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    NSLog (@"ss");
}

- (void)drawPage:(PDFPage *)page{
    [super drawPage: page];
    [handleView setFrame:self.documentView.frame];
    //NSLog(@"%f,%f,%f,%f",self.documentView.frame.origin.x,self.documentView.frame.origin.y,self.documentView.frame.size.width,self.documentView.frame.size.height);
    
    NSRect			bounds;
    NSBezierPath	*path;
    bounds = NSMakeRect(100, 100, 100, 100);
    CGFloat lineDash[2];
    lineDash[0]=6;
    lineDash[1]=4;
    path = [NSBezierPath bezierPathWithRect: bounds];
    //[path setLineJoinStyle: NSRoundLineJoinStyle];
    [path setLineDash:lineDash count:2 phase:0.0];
    [path setLineWidth:0.1];
    [[NSColor colorWithDeviceRed: 1.0 green: 0.0 blue: 0.0 alpha: 0.1] set];
    [path fill];
    [[NSColor blackColor] set];
    [path stroke];
    
}

@end
