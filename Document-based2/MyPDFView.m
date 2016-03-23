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
    HandScrollView *handScrollView;
    ZoomView *zoomView;
}

- (void)awakeFromNib{
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResizeNotification object:self.window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        if (handleView) {
            [handleView setFrame:self.bounds];
        }
    }];
}

- (void)loadHundleView{
    [self removeSubView];
    handleView = [[HandleView alloc]initWithFrame:self.bounds];
    [self addSubview:handleView];
}

- (void)loadHandScrollView{
    [self removeSubView];
    handScrollView = [[HandScrollView alloc]initWithFrame:self.bounds];
    [self addSubview:handScrollView];
}

- (void)loadZoomView{
    [self removeSubView];
    zoomView = [[ZoomView alloc]initWithFrame:self.bounds];
    [self addSubview:zoomView];
}

- (void)removeSubView{
    [handleView removeFromSuperview];
    [handScrollView removeFromSuperview];
    [zoomView removeFromSuperview];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize{
    NSLog(@"ddd");
}

- (void)drawPage:(PDFPage *)page{
    [super drawPage: page];
    
    //NSLog(@"%f,%f,%f,%f",self.documentView.frame.origin.x,self.documentView.frame.origin.y,self.documentView.frame.size.width,self.documentView.frame.size.height);
    NSRect rect = [self.currentPage boundsForBox:kPDFDisplayBoxArtBox];

    NSRect			bounds;
    NSBezierPath	*path;
    bounds = NSMakeRect(0, 0, rect.size.width, rect.size.height);
    CGFloat lineDash[2];
    lineDash[0]=6;
    lineDash[1]=4;
    path = [NSBezierPath bezierPathWithRect: bounds];
    //[path setLineJoinStyle: NSRoundLineJoinStyle];
    [path setLineDash:lineDash count:2 phase:0.0];
    [path setLineWidth:0.1];
    [[NSColor colorWithDeviceRed: 0.0 green: 1.0 blue: 0.0 alpha: 0.1] set];
    [path fill];
    [[NSColor blackColor] set];
    [path stroke];
    
}

@end
