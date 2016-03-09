//
//  DocWinC.m
//  Document-based2
//
//  Created by 河野 さおり on 2016/02/20.
//  Copyright © 2016年 河野 さおり. All rights reserved.
//

#import "DocWinC.h"
#import "Document.h"
#import "MyPDFView.h"
#import "AppDelegate.h"

#define kMinTocAreaSplit	165.0f
#define APPD (AppDelegate *)[NSApp delegate]

@interface DocWinC ()

@end

@implementation DocWinC{
    PDFSelection *testSel;
}

#pragma mark - Window Controller Method

- (void)windowDidLoad {
    [super windowDidLoad];
    //スクリーンモード保持用変数を初期化
    bFullscreen = NO;
    //ファイルから読み込まれたPDFドキュメントをビューに表示
    docURL = [[self document] fileURL];
    PDFDocument *doc = [[PDFDocument alloc]initWithURL:docURL];
    [_pdfView setDocument:doc];
    //ノーティフィケーションを設定
    [self setUpNotification];
    //デリゲートを設定
    [[_pdfView document] setDelegate: self];
    //オート・スケールをオフにする
    [_pdfView setAutoScales:NO];
    //ページ表示テキストフィールドを更新
    NSUInteger totalPg = _pdfView.document.pageCount;
    [txtTotalPg setStringValue:[NSString stringWithFormat:@"%li",totalPg]];
    [txtPageFormatter setMaximum:[NSNumber numberWithInteger:totalPg]];
    //ページ表示テキストフィールドの値を変更
    [self updateTxtPg];
    //サムネイルビューの選択規則を設定
    [thumbView setAllowsMultipleSelection:YES];
    //アウトラインルートがあるかどうかチェック
    if ([[_pdfView document]outlineRoot]) {
        //アウトラインビューのデータを読み込み
        [_olView reloadData];
        [_olView expandItem:nil expandChildren:YES];
        //目次エリアの初期表示をアウトラインに変更
        [segTabTocSelect setSelected:YES forSegment:1];
        [self segSelContentsView:segTabTocSelect];
    }
    //検索結果保持用配列を初期化
    searchResult = [NSMutableArray array];
}

#pragma mark - document save/open support

- (NSData *)pdfViewDocumentData{
    return [[_pdfView document]dataRepresentation];
}

- (void)revertDocumentToSaved{
    PDFDocument *doc = [[PDFDocument alloc]initWithURL:docURL];
    [_pdfView setDocument:doc];
}

#pragma mark - Setup notification

- (void)setUpNotification{
    //ドキュメント保存開始
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PDFDidBeginDocumentWrite" object:[_pdfView document] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        double pgCnt = [[_pdfView document] pageCount];
        [savingProgBar setMaxValue:pgCnt];
        [savingProgBar setDoubleValue: 0.0];
        //プログレス・パネルをシート表示
        [self.window beginSheet:progressWin completionHandler:^(NSInteger returnCode){}];
    }];
    //ドキュメント保存中
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PDFDidEndDocumentWrite" object:[_pdfView document] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        //プログレス・バーの値を更新
        double currentPg = [[notif.userInfo objectForKey: @"PDFDocumentPageIndex"] floatValue];
        [savingProgBar setDoubleValue:currentPg];
        [savingProgBar displayIfNeeded];
    }];
    //ドキュメント保存完了
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PDFDidEndPageWrite" object:[_pdfView document] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        //プログレス・パネルを終了させる
        [self.window endSheet:progressWin returnCode:0];
    }];
    //メインウインドウ変更
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidBecomeMainNotification object:self.window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        [APPD documentMenuSetEnabled:YES];
        //検索メニューの有効／無効の切り替え
        [APPD findMenuSetEnabled:YES];
        //ページ移動メニューの有効／無効の切り替え
        [self updateGoButtonEnabled];
        //倍率変更メニューの有効／無効の切り替え
        [self updateSizingBtnEnabled];
        //ディスプレイ・モード変更メニューのステータス変更
        [self updateDisplayModeMenuStatus];
        //スクリーンモード変更メニューのタイトルを変更
        [self mnFullScreenSetTitle];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:NSWindowWillCloseNotification object:self.window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        NSDocumentController *docCtr = [NSDocumentController sharedDocumentController];
        if (docCtr.documents.count == 1) {
            [APPD documentMenuSetEnabled:NO];
       }
     }];
    //ページ移動
    [[NSNotificationCenter defaultCenter] addObserverForName:PDFViewPageChangedNotification object:_pdfView queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        //ページ移動ボタンの有効/無効の切り替え
        [self updateGoButtonEnabled];
        //ページ表示テキストフィールドの値を変更
        [self updateTxtPg];
    }];
    //表示倍率変更
    [[NSNotificationCenter defaultCenter]addObserverForName:PDFViewScaleChangedNotification object:_pdfView queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        //倍率変更ボタン／メニューの有効／無効の切り替え
        [self updateSizingBtnEnabled];
    }];
    //ディスプレイモード変更
    [[NSNotificationCenter defaultCenter]addObserverForName:PDFViewDisplayBoxChangedNotification object:_pdfView queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        //ディスプレイ・モード変更メニューのステータス変更
        [self updateDisplayModeMenuStatus];
    }];
    //スクリーンモード変更
    [[NSNotificationCenter defaultCenter]addObserverForName:NSWindowDidEnterFullScreenNotification object:self.window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        bFullscreen = YES;
        [self mnFullScreenSetTitle];
    }];
    [[NSNotificationCenter defaultCenter]addObserverForName:NSWindowDidExitFullScreenNotification object:self.window queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif){
        bFullscreen = NO;
        [self mnFullScreenSetTitle];
    }];
}

//ページ表示フィールドの値を更新
- (void) updateTxtPg {
    PDFDocument *doc = _pdfView.document;
    NSUInteger index = [doc indexForPage:[_pdfView currentPage]] + 1;
    [txtPg setStringValue:[NSString stringWithFormat:@"%li",index]];
}

//ページ移動ボタン／メニューの有効/無効の切り替え
- (void)updateGoButtonEnabled{
    if (_pdfView.canGoToFirstPage) {
        [btnGoToFirstPg setEnabled:YES];
        [[APPD mnGoToFirstPg]setEnabled:YES];
    } else {
        [btnGoToFirstPg setEnabled:NO];
        [[APPD mnGoToFirstPg]setEnabled:NO];
    }
    if (_pdfView.canGoToPreviousPage) {
        [btnGoToPrevPg setEnabled:YES];
        [[APPD mnGoToPrevPg]setEnabled:YES];
    } else {
        [btnGoToPrevPg setEnabled:NO];
        [[APPD mnGoToPrevPg]setEnabled:NO];
    }
    if (_pdfView.canGoToNextPage){
        [btnGoToNextPg setEnabled:YES];
        [[APPD mnGoToNextPg]setEnabled:YES];
    } else {
        [btnGoToNextPg setEnabled:NO];
        [[APPD mnGoToNextPg]setEnabled:NO];
    }
    if (_pdfView.canGoToLastPage){
        [btnGoToLastPg setEnabled:YES];
        [[APPD mnGoToLastPg]setEnabled:YES];
    } else {
        [btnGoToLastPg setEnabled:NO];
        [[APPD mnGoToLastPg]setEnabled:NO];
    }
    if (_pdfView.canGoBack) {
        [btnGoBack setEnabled:YES];
        [[APPD mnGoBack]setEnabled:YES];
    } else {
        [btnGoBack setEnabled:NO];
        [[APPD mnGoBack]setEnabled:NO];
    }
    if (_pdfView.canGoForward) {
        [btnGoForward setEnabled:YES];
        [[APPD mnGoForward]setEnabled:YES];
    } else {
        [btnGoForward setEnabled:NO];
        [[APPD mnGoForward]setEnabled:NO];
    }
}

//倍率変更ボタン／メニューの有効／無効の切り替え
- (void)updateSizingBtnEnabled{
    if (_pdfView.scaleFactor < 5.0) {
        [segZoom setEnabled:YES forSegment:0];
        [[APPD mnZoomIn]setEnabled:YES];
    } else {
        [segZoom setEnabled:NO forSegment:0];
        [[APPD mnZoomIn]setEnabled:NO];
    }
    if (_pdfView.canZoomOut) {
        [segZoom setEnabled:YES forSegment:1];
        [[APPD mnZoomOut]setEnabled:YES];
    } else {
        [segZoom setEnabled:NO forSegment:1];
        [[APPD mnZoomOut]setEnabled:NO];
    }
}

//ディスプレイ・モード変更ボタン／メニューのステータス変更
- (void)updateDisplayModeMenuStatus{
    [APPD setMnPageDisplayState:[matrixDisplayMode selectedColumn]];
}

//スクリーンモード変更メニューのタイトルを変更
- (void)mnFullScreenSetTitle{
    if (bFullscreen) {
        [[APPD mnFullScreen]setTitle:NSLocalizedString(@"MnTitleExitFullScreen", @"")];
    } else {
        [[APPD mnFullScreen]setTitle:NSLocalizedString(@"MnTitleEnterFullScreen", @"")];
    }
}

#pragma mark - Actions

- (IBAction)txtJumpPage:(id)sender {
    PDFDocument *doc = [_pdfView document];
    PDFPage *page = [doc pageAtIndex:[[sender stringValue]integerValue]-1];
    [_pdfView goToPage:page];
}

//コンテンツ・エリアのビューを切り替え
- (IBAction)segSelContentsView:(id)sender {
    if ([sender selectedSegment]==1 && ![[_pdfView document]outlineRoot]) {
        //ドキュメントにアウトラインがない時にアウトライン表示が選択された
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = NSLocalizedString(@"NotExistOutline_msg", @"");
        [alert setInformativeText:NSLocalizedString(@"NotExistOutline_info", @"")];
        [alert addButtonWithTitle:@"OK"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode){
            //セグメントの選択を元に戻す
            if ([tabToc indexOfTabViewItem:[tabToc selectedTabViewItem]] == 0) {
                [segTabTocSelect setSelectedSegment:0];
            } else {
                [segTabTocSelect setSelected:NO forSegment:1];
            }
        }];
    } else {
        [tabToc selectTabViewItemAtIndex:[sender selectedSegment]];
    }
}

//コンテンツ・エリアの表示／非表示を切り替え
- (IBAction)showSideBar:(id)sender {
    CGFloat currentTocWidth = tocView.frame.size.width;
    if (currentTocWidth == 0) {
        //目次エリアを表示
        [tocView setFrame:NSMakeRect(0, 0, oldTocWidth, _splitView.frame.size.height)];
        [searchField setFrame:NSMakeRect(70, 4, oldTocWidth-77, 19)];
    } else {
        //目次エリアを非表示
        oldTocWidth = tocView.frame.size.width; //非表示前の目次エリア幅を保存
        [tocView setFrame:NSMakeRect(0, 0, 0, _splitView.frame.size.height)];
    }
}

//ディスプレイ・モードを切り替え
- (IBAction)matrixDisplayMode:(id)sender {
    switch ([sender selectedColumn]) {
        case 0:
            [_pdfView setDisplayMode:kPDFDisplaySinglePage];
            break;
        case 2:
            [_pdfView setDisplayMode:kPDFDisplayTwoUp];
            break;
        case 3:
            [_pdfView setDisplayMode:kPDFDisplayTwoUpContinuous];
            break;
        default:
            [_pdfView setDisplayMode:kPDFDisplaySinglePageContinuous];
            break;
    }
    [self updateDisplayModeMenuStatus];
}

- (IBAction)segZoom:(id)sender {
    switch ([sender selectedSegment]) {
        case 0:
            [self zoomIn:nil];
            break;
        case 1:
            [self zoomOut:nil];
            break;
        default:
            [self zoomImageToFit:nil];
            break;
    }
}

#pragma mark - menu action

//表示メニュー
- (IBAction)zoomIn:(id)sender{
    [_pdfView zoomIn:nil];
}

- (IBAction)zoomOut:(id)sender{
    [_pdfView zoomOut:nil];
}

- (IBAction)zoomImageToFit:(id)sender{
    [_pdfView setAutoScales:YES];
    [_pdfView setAutoScales:NO];
}

- (IBAction)zoomImageToActualSize:(id)sender{
    [_pdfView setScaleFactor:1];
}

- (IBAction)mnSinglePage:(id)sender{
    [matrixDisplayMode selectCellWithTag:0];
    [self matrixDisplayMode:matrixDisplayMode];
    [self updateDisplayModeMenuStatus];
}

- (IBAction)mnSingleCont:(id)sender{
    [matrixDisplayMode selectCellWithTag:1];
    [self matrixDisplayMode:matrixDisplayMode];
    [self updateDisplayModeMenuStatus];
}

- (IBAction)mnTwoPages:(id)sender{
    [matrixDisplayMode selectCellWithTag:2];
    [self matrixDisplayMode:matrixDisplayMode];
    [self updateDisplayModeMenuStatus];
}

- (IBAction)mnTwoPagesCont:(id)sender{
    [matrixDisplayMode selectCellWithTag:3];
    [self matrixDisplayMode:matrixDisplayMode];
    [self updateDisplayModeMenuStatus];
}

//移動メニュー
- (IBAction)goToPreviousPage:(id)sender{
    [_pdfView goToPreviousPage:nil];
}

- (IBAction)goToNextPage:(id)sender{
    [_pdfView goToNextPage:nil];
}

- (IBAction)goToFirstPage:(id)sender{
    [_pdfView goToFirstPage:nil];
}

- (IBAction)goToLastPage:(id)sender{
    [_pdfView goToLastPage:nil];
}

- (IBAction)goBack:(id)sender{
    [_pdfView goBack:nil];
}

- (IBAction)goForward:(id)sender{
    [_pdfView goForward:nil];
}

- (IBAction)mnGoToPage:(id)sender{
    [self.window makeFirstResponder:txtPg];
}

- (IBAction)mnFindInPDF:(id)sender{
    [self.window makeFirstResponder:searchField];
}

- (IBAction)test:(id)sender {
    testSel = _pdfView.currentSelection;
}
- (IBAction)test2:(id)sender {
    [testSel setColor:[NSColor yellowColor]];
    [_pdfView setCurrentSelection:testSel];
}

- (IBAction)test3:(id)sender {
    NSArray *pages = testSel.pages;
    [testSel setColor:[NSColor yellowColor]];
    [testSel drawForPage:[pages objectAtIndex:0] active:YES];
    [_pdfView setNeedsDisplay:YES];
}

#pragma mark - search in document

- (IBAction)searchField:(id)sender {
    NSString *searchString = [sender stringValue];
    if ([searchString isEqualToString:@""]) {
        //目次エリアの表示を元に戻す
        [self segSelContentsView:segTabTocSelect];
        return;
    }
    //検索実行
    PDFDocument *doc = [_pdfView document];
    [doc beginFindString:searchString withOptions:NSCaseInsensitiveSearch];
}

- (void)didMatchString:(PDFSelection *)instance{
    //元の選択領域を保持
    PDFSelection *sel = instance.copy;
    //テーブルの結果列の項目作成
    [instance extendSelectionAtStart:10];
    [instance extendSelectionAtEnd:10];
    NSString *labelString = [self stringByRemoveLine:instance.string];
    labelString = [NSString stringWithFormat:@"...%@...",labelString];
    //テーブルのページ列の項目作成
    PDFPage *page = [[instance pages]objectAtIndex:0];
    NSString *pageLabel = page.label;
    
    //検索結果を作成
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:sel,@"selection",labelString,@"result",pageLabel,@"page",nil];
    [searchResult addObject:result];
    //検索結果を表示
    [tabToc selectTabViewItemAtIndex:2];
    [[[_tbView.tableColumns objectAtIndex:1]headerCell] setTitle:[NSString stringWithFormat:@"%@%li",NSLocalizedString(@"RESULT", @""),searchResult.count]];
    [_tbView reloadData];
}

//改行を削除した文字列を返す
- (NSString*)stringByRemoveLine:(NSString*)string{
    NSMutableArray *lines = [NSMutableArray array];
    [string enumerateLinesUsingBlock:^(NSString *line,BOOL *stop){
        [lines addObject:line];
    }];
    NSString *newStr = [lines componentsJoinedByString:@" "];
    return newStr;
}

- (void)documentDidBeginDocumentFind:(NSNotification *)notification{
    [searchResult removeAllObjects];
    [_tbView reloadData];
}

#pragma mark - table view data source and delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return searchResult.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *identifier = tableColumn.identifier;
    NSDictionary *result = [searchResult objectAtIndex:row];
    NSTableCellView *view = [tableView makeViewWithIdentifier:identifier owner:self];
    if ([identifier isEqualToString:@"page"]){
        view.textField.stringValue = [result objectForKey:identifier];
    } else {
        NSMutableAttributedString *labelTxt = [[NSMutableAttributedString alloc]initWithString:[result objectForKey:identifier]];
        NSDictionary *attr = @{NSFontAttributeName:[NSFont systemFontOfSize:11 weight:NSFontWeightBold]};
        NSRange range = [[result objectForKey:identifier] rangeOfString:searchField.stringValue options:NSCaseInsensitiveSearch];
        [labelTxt setAttributes:attr range:range];
        [view.textField setAttributedStringValue:labelTxt];
    }
    return view;
}

//行選択時
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    //選択行を取得
    NSInteger row = [_tbView selectedRow];
    if (row != -1){
        //選択領域を取得
        PDFSelection *sel = [[searchResult objectAtIndex:row] objectForKey:@"selection"];
        //選択領域を表示
        [sel setColor:[NSColor yellowColor]];
        [_pdfView setCurrentSelection:sel];
        [_pdfView scrollSelectionToVisible:self];
    }
}

#pragma mark - split view delegate

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex{
    return proposedMin + kMinTocAreaSplit;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex{
    return proposedMax - kMinTocAreaSplit;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize{
    NSRect newFrame = [splitView frame];    //新しいsplitView全体のサイズを取得
    NSView *leftView = [[splitView subviews]objectAtIndex:0];
    NSRect leftFrame = [leftView frame];
    NSView *rightView = [[splitView subviews]objectAtIndex:1];
    NSRect rightFrame = [rightView frame];
    CGFloat dividerThickness = [splitView dividerThickness];

    leftFrame.size.height = newFrame.size.height;
    rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;
    rightFrame.size.height = newFrame.size.height;
    rightFrame.origin.x = leftFrame.size.width + dividerThickness;
    
    [leftView setFrame:leftFrame];
    [rightView setFrame:rightFrame];
}

@end
