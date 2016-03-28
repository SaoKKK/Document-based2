//
//  HandScrollView.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/03/23.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "HandScrollView.h"

@implementation HandScrollView{
    NSTrackingArea *track;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createTrackingArea];
    }
    return self;
}

- (void)updateTrackingAreas {
    [self removeTrackingArea:track];
    track = nil;
    [self createTrackingArea];
}

//トラッキング・エリアを設定
-(void)createTrackingArea{
    NSTrackingAreaOptions trackOption = NSTrackingCursorUpdate;
    trackOption |= NSTrackingMouseEnteredAndExited;
    trackOption |= NSTrackingEnabledDuringMouseDrag;
    trackOption |= NSTrackingActiveInActiveApp;
    track = [[NSTrackingArea alloc] initWithRect:self.bounds options:trackOption owner:self userInfo:nil];
    [self addTrackingArea:track];
}

- (void)cursorUpdate:(NSEvent *)event{
}

- (void)mouseDown:(NSEvent *)theEvent{
     [[NSCursor closedHandCursor] set];
}

- (void)mouseDragged:(NSEvent *)theEvent{
    NSLog(@"drag");
}

- (void)mouseUp:(NSEvent *)theEvent{
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSLog(@"up%f",point.x);
}

- (void)mouseEntered:(NSEvent *)theEvent{
    NSLog(@"enter");
    [self discardCursorRects];
    [[NSCursor openHandCursor]set];
}

- (void)mouseExited:(NSEvent *)theEvent{
    NSLog(@"exit");
    [self discardCursorRects];
    [[NSCursor closedHandCursor] set];
}

@end
