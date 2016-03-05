//
//  OLController.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/03/05.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "OLController.h"
#import "MyPDFView.h"

@implementation OLController{
    IBOutlet NSOutlineView *_olView;
    IBOutlet MyPDFView *_pdfView;
    NSMutableDictionary *_rootItem; //PDFOutlineのルートアイテムを保持
}

- (void)awakeFromNib{
    //ページ移動ノーティフィケーションを設定
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageChanged) name:PDFViewPageChangedNotification object:_pdfView];
}

#pragma mark - outlineView data source

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if (! item) {
        return [[[_pdfView document] outlineRoot]numberOfChildren];
    }
    return [[item objectForKey:@"PDFOutline"] numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    //ルートの場合はPDFOutlineを取得
    if (! item) {
        _rootItem = [NSMutableDictionary dictionary];
        [_rootItem setObject:[[_pdfView document]outlineRoot] forKey:@"PDFOutline"];
        item = _rootItem;
    }
    //子のアウトラインを取得
    NSMutableArray *children;
    children = [item objectForKey:@"children"];
    if (! children) {
        //子の配列が作成されていない場合、すべての子を取得して登録
        children = [NSMutableArray array];
        [item setObject:children forKey:@"children"];
        PDFOutline *outline = [item objectForKey:@"PDFOutline"];
        for (int i=0; i<[outline numberOfChildren]; i++) {
            NSMutableDictionary *child = [NSMutableDictionary dictionary];
            [child setObject:[outline childAtIndex:i] forKey:@"PDFOutline"];
            [children addObject:child];
        }
    }
    return [children objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    return [[item objectForKey:@"PDFOutline"]numberOfChildren] > 0;
}

- (NSView *)outlineView:(NSOutlineView *)olView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    NSString *identifier = tableColumn.identifier;
    NSTableCellView *view = [olView makeViewWithIdentifier:identifier owner:self];
    if ([identifier isEqualToString:@"label"]){
        view.textField.stringValue = [[item objectForKey:@"PDFOutline"] label];
    } else {
        PDFDocument *doc = [_pdfView document];
        PDFPage *page = [[[item objectForKey:@"PDFOutline"] destination] page];
        view.textField.stringValue = [NSString stringWithFormat:@"%li",[doc indexForPage:page]+1];
    }
    return view;
}

#pragma mark - navigate between the destinations

//行選択アクション
- (IBAction)selectRow:(id)sender {
    if ([_olView selectedRowIndexes].count == 1) {
        //選択行が1行の時 - 選択行のページを取得
        NSMutableDictionary *item = [_olView itemAtRow:[_olView selectedRow]];
        PDFOutline *outline = [item objectForKey:@"PDFOutline"];
        PDFDestination *destination = [outline destination];
        //ページを移動
        [_pdfView goToDestination:destination];
    }
}

//ページ移動時
- (void)pageChanged{
    PDFDocument *doc = [_pdfView document];
    //現在のページを取得
    NSInteger pageIndex = [doc indexForPage:[_pdfView currentPage]];
    //行ごとにページをチェック
    NSInteger newRow;
    for (int i=0; i<[_olView numberOfRows]; i++) {
        //PDFアウトラインのページを取得
        PDFOutline *outline = [[_olView itemAtRow:i] objectForKey:@"PDFOutline"];
        NSInteger olIndex = [doc indexForPage:outline.destination.page];
        if (pageIndex == olIndex) {
            newRow = i;
            break;
        }
        if (pageIndex < olIndex) {
            newRow = i-1;
            break;
        }
    }
    //該当行を選択
    if (newRow >= 0){
        [_olView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRow] byExtendingSelection:NO];
    }
}

//コンテナ開閉で選択行を移行
- (void)outlineViewItemDidExpand:(NSNotification *)notification{
    [self pageChanged];
}
- (void)outlineViewItemDidCollapse:(NSNotification *)notification{
    [self pageChanged];
}

@end
