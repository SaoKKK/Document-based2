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
}

- (void)awakeFromNib{
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResizeNotification object:self.window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        if (handleView) {
            [handleView setFrame:self.bounds];
        }
    }];
}

- (void)drawHundleView{
    handleView = [[HandleView alloc]initWithFrame:self.bounds];
    [handleView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self addSubview:handleView];
}

- (void)removeHundleView{
    [handleView removeFromSuperview];
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
