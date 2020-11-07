unit ufmSlideRule;

interface

uses
  Windows, SysUtils, Graphics, Forms,
  StdCtrls, ExtCtrls, Classes, Dialogs, Controls, Printers;

const
  APPLICATION_NAME = '九九 計算じゃく';
  APPLICATION_NAME_RUBY = '|九九|く　く| |計算尺|けいさんじゃく|';
  VERSION = 'Version 0.9.0';
  COPYRIGHT = 'Copyright © 2020 松原正和';
  COPYRIGHT_RUBY = 'Copyright © 2020 |松原正和|まつばら まさかず|';

  FONT_NAME = 'UD デジタル 教科書体 N-R';


  //  カラーユニバーサルデザイン　推奨配色カラー（第三版）より
  //  http://jfly.iam.u-tokyo.ac.jp/colorset/
  //  アクセントカラー
  //  文字・サイン・線など、小さいものを塗りわけるのに使えるような、彩度の高い色です。
  cluRed     = $000028FF; //  赤        ：色弱の人が赤と感じやすいように、オレンジ寄りの赤にしています。
  cluYellow  = $0000F5FF; //  黄色      ：白内障の人が白と区別しやすい、濃い黄色にしています。
  cluGreen   = $006BA135; //  緑        ：色弱の人が黄色や赤と間違えやすい黄色みの強い緑を避け、青みが強い緑を選んでいます。ただし青緑まで行ってしまうと、今度はグレーや紫と混同するので、それよりも緑に近い微妙な位置にしています。
  cluBlue    = $00FF4100; //  青        ：白内障の人が黒と間違えないよう、少し明るめになっています。
  cluSky     = $00FFCC66; //  空色      ：青との明度差を確保するため、少し明るめになっています。
  cluPink    = $00A099FF; //  ピンク    ：青みのピンクだと空色と混同することがあるので、やや黄みに寄せたピンクにしています。
  cluOrange  = $000099FF; //  オレンジ  ：赤がオレンジ寄りになっているのとバランスを取るため、少し黄色寄りのオレンジになっています。
  cluPurple  = $0079009A; //  紫        ：青紫は青と間違えやすいので、赤みの強い紫にしています。
  cluBrown   = $00003366; //  茶        ：明るめの茶色は赤や緑と混同することがあるので、暗めの色にしています。（ただし黒と間違えることがあるので注意が必要です。）


type
  TfrmSlideRule = class(TForm)
    Panel1: TPanel;
    btPrintOut: TButton;
    Image1: TImage;
    PrinterSetupDialog1: TPrinterSetupDialog;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btPrintOutClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  frmSlideRule: TfrmSlideRule;

implementation

uses
  Math;

{$R *.DFM}

{
  簡易的なルビ付き文字列の出力
    "|"で区切ってルビを振らない部分・ルビの対象・ルビを繰り返して指定する。
    例)
      指定文字列: "ルビの付|つ|いた|文字列|もじれつ|"
      出力結果        つ    もじれつ
                ルビの付いた文字列

}
procedure RubyTextOut(Canvas: TCanvas; nX, nY: Integer; sString: String);
var
  nFontHeight: Integer; // フォント高さ
  ssString: TStrings;   // 対象文字列を"|" で分割したもの（ルビを振らない部分/ルビの対象/ルビ…）
  nIdx: Integer;        // ssString の添え字
  nRubyX: Integer;      // ルビ出力のX座標
  nRubyY: Integer;      // ルビ出力のY座標
  nRubyWidth: Integer;  // ルビ出力に使える幅
  nWidth: Integer;
begin
  nFontHeight := Canvas.Font.Height;
  nRubyY := nY - Abs((nFontHeight + 1) div 2);  // ルビのY座標は、出力文字列のフォント高さの半分上
  ssString := TStringList.Create;
  try
    ssString.StrictDelimiter := True;
    ssString.Delimiter := '|';
    ssString.DelimitedText := sString;

    for nIdx := 0 to ssString.Count - 1do
    begin
      case (nIdx mod 3) of
        0:  // ルビの付かない文字列
          begin
            nWidth := Canvas.TextWidth(ssString[nIdx]);
            Canvas.TextOut(nX, nY, ssString[nIdx]);
            Inc(nX, nWidth);
          end;
        1:  // ルビの振られる対象文字列
          begin
            nRubyX := nX;
            nWidth := Canvas.TextWidth(ssString[nIdx]);
            Canvas.TextOut(nX, nY, ssString[nIdx]);
            Inc(nX, nWidth);
            nRubyWidth := nWidth;
          end;
        2:  // ルビ
          begin
            // フォントサイズを半分にする
            Canvas.Font.Height := nFontHeight div 2;
            nWidth := Canvas.TextWidth(ssString[nIdx]);
            Canvas.TextOut(nRubyX + (nRubyWidth - nWidth) div 2, nRubyY, ssString[nIdx]);
            // フォントサイズを戻す
            Canvas.Font.Height := nFontHeight;
          end;
      end;
    end;
  finally
    FreeAndNil(ssString);
  end;
end;


{
  簡易的なルビ付き文字列の出力幅
}
function RubyTextWidth(Canvas: TCanvas; sString: String): Integer;
var
  ssString: TStrings;   // 対象文字列を"|" で分割したもの（ルビを振らない部分/ルビの対象/ルビ…）
  nIdx: Integer;        // ssString の添え字
  nWidth: Integer;
begin
  Result := 0;
  ssString := TStringList.Create;
  try
    ssString.StrictDelimiter := True;
    ssString.Delimiter := '|';
    ssString.DelimitedText := sString;

    for nIdx := 0 to ssString.Count - 1do
    begin
      case (nIdx mod 3) of
        0:  // ルビの付かない文字列
          begin
            nWidth := Canvas.TextWidth(ssString[nIdx]);
            Inc(Result, nWidth);
          end;
        1:  // ルビの振られる対象文字列
          begin
            nWidth := Canvas.TextWidth(ssString[nIdx]);
            Inc(Result, nWidth);
          end;
        2:  // ルビ
          begin
          end;
      end;
    end;
  finally
    FreeAndNil(ssString);
  end;
end;


// 計算尺を出力する
procedure CreateSlideRule(Canvas: TCanvas; nWidth: Integer; bDebug: Boolean);
var
  nIdx: Integer;
  nX: Integer;
  sStr: String;
  rUnit: Extended;        // 描画に使うサイズの基準値
  nXBase: Integer;        // 目盛りの基準位置
  nCutLineWidth: Integer; // 切り取り線の幅
  xPoints: array[0..2] of TPoint;
begin
  // 描画に使うサイズの基準値
  rUnit := nWidth / 10000;
  // 目盛りの基準位置
  nXBase := Round(1500 * rUnit);
  // 切り取り線の幅
  nCutLineWidth := nWidth div 700;
  if (nCutLineWidth < 3) then
    nCutLineWidth := 3;

  Canvas.Font.Name := FONT_NAME;
  Canvas.Font.Height := round(130 * rUnit);
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := nCutLineWidth;
  Canvas.Brush.Style := bsClear;

//* 本体の描画 *****************************************************************

  //  のりしろ
  Canvas.MoveTo(round( 600 * rUnit), round(600 * rUnit));
  Canvas.LineTo(round(1000 * rUnit), round(200 * rUnit));   // のりしろ（上）↗
  Canvas.LineTo(round(8900 * rUnit), round(200 * rUnit));   // のりしろ（上）→
  Canvas.LineTo(round(9300 * rUnit), round(600 * rUnit));   // のりしろ（上）↘

  //  外枠
  Canvas.Pen.Width := nCutLineWidth;
  Canvas.MoveTo(round(  600 * rUnit), round( 600 * rUnit));
  Canvas.LineTo(round(  600 * rUnit), round(4440 * rUnit)); // 左縦線
  Canvas.LineTo(round( 9300 * rUnit), round(4440 * rUnit)); // 底横線
  Canvas.LineTo(round( 9300 * rUnit), round(2520 * rUnit)); // 右縦線（下半分）
  Canvas.LineTo(round( 9700 * rUnit), round(2120 * rUnit)); // のりしろ（右）↗
  Canvas.LineTo(round( 9700 * rUnit), round(1000 * rUnit)); // のりしろ（右）↑
  Canvas.LineTo(round( 9300 * rUnit), round( 600 * rUnit)); // のりしろ（右）↖

  //  折り目
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psDash;

  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psDash;
  Canvas.MoveTo(round( 600 * rUnit), round( 600 * rUnit));
  Canvas.LineTo(round(9300 * rUnit), round( 600 * rUnit));  // →
  Canvas.LineTo(round(9300 * rUnit), round(2520 * rUnit));  // ↓
  Canvas.LineTo(round( 600 * rUnit), round(2520 * rUnit));  // ←
  Canvas.Pen.Style := psSolid;

  //  窓
  Canvas.Pen.Width := nCutLineWidth;
  Canvas.Rectangle(round(1300 * rUnit), round(1001 * rUnit), round(5650 * rUnit), round(1649 * rUnit));
  Canvas.Pen.Width := 1;

  // 本体右上計算尺名
  sStr := APPLICATION_NAME_RUBY;
  Canvas.Font.Color := clBlack;
  RubyTextOut(Canvas, round(8500 * rUnit), round(700 * rUnit), sStr);

  Canvas.Font.Color := clBlack;
  RubyTextOut(Canvas, round(800 * rUnit), round(1250 * rUnit), '|答|こた|え');

  // 左上の「▼ かけられるかず」
  nX := nXBase;
  Canvas.Pen.Color := cluRed;
  Canvas.Brush.Color := cluRed;
  Canvas.Brush.Style := bsSolid;
  Canvas.Font.Color := cluRed;
  Canvas.Pen.Width := 1;
  xPoints[0].X := nX;
  xPoints[0].Y := round(1000 * rUnit);
  xPoints[1].X := nX - round(25 * rUnit);
  xPoints[1].Y := round( 900 * rUnit);
  xPoints[2].X := nX + round(25 * rUnit);
  xPoints[2].Y := round( 900 * rUnit);
  Canvas.Polygon(xPoints);
  Canvas.Pen.Color := clBlack;
  Canvas.Brush.Color := clWhite;
  Canvas.Brush.Style := bsClear;
  sStr := 'かけられる|数|かず';
  RubyTextOut(Canvas, nX - round(25 * rUnit), round(760 * rUnit), sStr);

  // かける数
  Canvas.Font.Color := cluBlue;
  RubyTextOut(Canvas, round(800 * rUnit), round(1800 * rUnit), 'かける|数|かず');

  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 1;
  nIdx := 1;
  while (nIdx <= 9) do
  begin
    nX := Round(nXBase + log10(nIdx) * 4000 * rUnit);
    Canvas.MoveTo(nX, round(1650 * rUnit));
    Canvas.LineTo(nX, round(1780 * rUnit));

    sStr := IntToStr(nIdx);
    Canvas.TextOut(nX - Canvas.TextWidth(sStr) div 2, round(1800 * rUnit), sStr);

    Inc(nIdx, 1);
  end;

  // くみ・なまえ
  Canvas.Font.Color := clBlack;
  Canvas.TextOut(round(5850 * rUnit), round(2250 * rUnit), '　　　ねん　　　くみ　なまえ');
  Canvas.Pen.Width := 1;
  Canvas.RoundRect(round(5800 * rUnit), round(1900 * rUnit), round(9200 * rUnit), round(2400 * rUnit), round(100 * rUnit), round(100 * rUnit));
  Canvas.Pen.Width := 1;

//* スライダの描画 *************************************************************

  //  枠
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := nCutLineWidth;
  Canvas.MoveTo(round( 300 * rUnit), round(4600 * rUnit));
  Canvas.LineTo(round( 300 * rUnit), round(6170 * rUnit));
  Canvas.LineTo(round( 600 * rUnit), round(6470 * rUnit));
//  Canvas.LineTo(round( 100 * rUnit), round(6600 * rUnit));
  Canvas.LineTo(round(9300 * rUnit), round(6470 * rUnit));
  Canvas.LineTo(round(9300 * rUnit), round(4600 * rUnit));
  Canvas.LineTo(round( 300 * rUnit), round(4600 * rUnit));

  // スライダ内かけられる数の線（赤）
  Canvas.Font.Color := cluRed;
  Canvas.Pen.Color := cluRed;
  Canvas.Pen.Width := 1;
  nIdx := 1;
  while (nIdx <= 9) do
  begin
    nX := Round(nXBase + log10(nIdx) * 4000 * rUnit);
    Canvas.MoveTo(nX, round(4840 * rUnit));
    Canvas.LineTo(nX, round(5200 * rUnit));
    Inc(nIdx, 1);
  end;

  // スライダ内答え
  Canvas.Font.Color := clBlack;
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 1;
  nIdx := 1;
  while (nIdx <= 81) do
  begin
    nX := Round(nXBase + log10(nIdx) * 4000 * rUnit);
    Canvas.MoveTo(nX, round(5800 * rUnit));
    if (nIdx mod 5 = 0) then
      Canvas.LineTo(nX, round(5450 * rUnit))
    else
      Canvas.LineTo(nX, round(5550 * rUnit));
    Inc(nIdx, 1);
  end;
  Canvas.Pen.Width := 3;
  nIdx := 10;
  while (nIdx <= 80) do
  begin
    nX := Round(nXBase + log10(nIdx) * 4000 * rUnit);
    Canvas.MoveTo(nX, round(5800 * rUnit));
    Canvas.LineTo(nX, round(5400 * rUnit));
    Inc(nIdx, 10);
  end;
  nIdx := 1;
  while (nIdx <= 9) do
  begin
    nX := Round(nXBase + log10(nIdx) * 4000 * rUnit);
    sStr := IntToStr(nIdx);
    Canvas.TextOut(nX - Canvas.TextWidth(sStr) div 2, round(5250 * rUnit), sStr);
    Inc(nIdx, 1);
  end;
  nIdx := 10;
  while (nIdx <= 80) do
  begin
    nX := Round(nXBase + log10(nIdx) * 4000 * rUnit);
    sStr := IntToStr(nIdx);
    Canvas.TextOut(nX - Canvas.TextWidth(sStr) div 2, round(5250 * rUnit), sStr);
    Inc(nIdx, 10);
  end;

  // スライダ右下計算尺名・DPI・バージョン・著作権表示
  sStr := APPLICATION_NAME_RUBY + ' (' + IntToStr(Canvas.Font.PixelsPerInch) + 'dpi) ' + VERSION + ' ' + COPYRIGHT_RUBY;
  Canvas.Font.Color := clBlack;
  RubyTextOut(Canvas, round(9200 * rUnit) - RubyTextWidth(Canvas, sStr), round(6270 * rUnit), sStr);
  if (bDebug) then
    Canvas.Rectangle(round(1300 * rUnit), round((4100 + 1000) * rUnit), round(5650 * rUnit), round((4100 + 1650) * rUnit));

end;



procedure TfrmSlideRule.FormPaint(Sender: TObject);
begin

//  CreateSlideRule(Image1.Canvas, Image1.Width, True);
//  exit;
end;

procedure TfrmSlideRule.FormCreate(Sender: TObject);
begin
  Self.Caption := APPLICATION_NAME + ' (' + IntToStr(Canvas.Font.PixelsPerInch) + 'dpi) ' + VERSION + ' ' + COPYRIGHT;

  Image1.Align := alClient;
  FormResize(Sender);
end;

procedure TfrmSlideRule.btPrintOutClick(Sender: TObject);
begin
  Printer.Orientation := poLandscape;
  if (PrinterSetupDialog1.execute) then
  begin
    Printer.BeginDoc;
    CreateSlideRule(Printer.Canvas, Printer.PageWidth, False);
    Printer.EndDoc;
  end;
end;

procedure TfrmSlideRule.FormResize(Sender: TObject);
var
  Rect: TRect;
begin
  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := Image1.Width + 1;
  Rect.Bottom := Image1.Height + 1;
  Image1.Picture.Bitmap.Width := Image1.Width;
  Image1.Picture.Bitmap.Height := Image1.Height;

  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.FillRect(Rect);
  CreateSlideRule(Image1.Canvas, Image1.Width, False);
//  Repaint;
end;

end.
