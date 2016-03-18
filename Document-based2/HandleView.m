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
    [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.1] set];
    NSRectFill(self.frame);
    
    [[NSColor clearColor] set];
    NSRectFill(_spot_rect);
}

- (void)mouseDown:(NSEvent *)theEvent{
    NSLog (@"aaa");
    NSPoint current_point, start_point;
    start_point = [self convertPoint:[theEvent locationInWindow]
                            fromView:nil];
    NSEvent *event;
    
    while (1) {
        event = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask|NSLeftMouseUpMask)];
        current_point = [self convertPoint:[event locationInWindow]
                                  fromView:nil];
        
        _spot_rect.size.width = fabs(start_point.x - current_point.x);
        _spot_rect.size.height = fabs(start_point.y - current_point.y);
        _spot_rect.origin.x = fmin(start_point.x, current_point.x);
        _spot_rect.origin.y = fmin(start_point.y, current_point.y);
        [self setNeedsDisplay:YES];
        
        if ([event type] == NSLeftMouseUp) {
            break;
        }
    }
}

@end
