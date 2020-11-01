unit ufmSlideRule;

interface

uses
  Windows, SysUtils, Graphics, Forms,
  StdCtrls, ExtCtrls, Classes, Dialogs, Controls, Printers;

const
  APPLICATION_NAME = '九九 計算じゃく';
  VERSION = 'Version 0.9.0';
  COPYRIGHT = 'Copyright © 2020 まつばらまさかず';

  FONT_NAME = 'UD デジタル 教科書体 N-R';

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

procedure CreateSlideRule(Canvas: TCanvas; nWidth: Integer; bDebug: Boolean);
var
  nIdx: Integer;
  nX: Integer;
  sStr: String;
  rUnit: Extended;
  nXBase: Integer;  // 基準位置
begin

  rUnit := nWidth / 10000;

  Canvas.Font.Name := FONT_NAME;
  Canvas.Font.Height := round(130 * rUnit);

  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 3;

  //  のりしろ
  Canvas.MoveTo(round( 600 * rUnit), round(500 * rUnit));
  Canvas.LineTo(round(1000 * rUnit), round(100 * rUnit));
  Canvas.LineTo(round(8900 * rUnit), round(100 * rUnit));
  Canvas.LineTo(round(9300 * rUnit), round(500 * rUnit));
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psDash;
  Canvas.LineTo(round( 600 * rUnit), round(500 * rUnit));
  Canvas.Pen.Style := psSolid;

  //  外枠
  Canvas.Pen.Width := 3;
  Canvas.MoveTo(round(  600 * rUnit), round( 500 * rUnit));
  Canvas.LineTo(round(  600 * rUnit), round(4540 * rUnit)); // 左縦線
  Canvas.LineTo(round( 9300 * rUnit), round(4540 * rUnit)); // 底横線
  Canvas.LineTo(round( 9300 * rUnit), round(2520 * rUnit)); // 右縦線（下半分）
  Canvas.LineTo(round( 9700 * rUnit), round(2120 * rUnit)); // のりしろ（右）↗
  Canvas.LineTo(round( 9700 * rUnit), round( 900 * rUnit)); // のりしろ（右）↑
  Canvas.LineTo(round( 9300 * rUnit), round( 500 * rUnit)); // のりしろ（右）↖

  //  折り目
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psDash;
  Canvas.MoveTo(round(  600 * rUnit), round(2520 * rUnit));
  Canvas.LineTo(round( 9300 * rUnit), round(2520 * rUnit));
  Canvas.LineTo(round( 9300 * rUnit), round( 500 * rUnit));
  Canvas.Pen.Style := psSolid;

  //  窓
  Canvas.Pen.Width := 3;
  Canvas.Rectangle(round(1300 * rUnit), round(1001 * rUnit), round(5650 * rUnit), round(1649 * rUnit));
  Canvas.Pen.Width := 1;

  if (bDebug) then
    Canvas.Rectangle(round(1000 * rUnit), round((4100 + 800) * rUnit), round(9500 * rUnit), round((4100 + 1650) * rUnit));


  // 基準位置
  nXBase := Round(1500 * rUnit);

  sStr := APPLICATION_NAME + ' (' + IntToStr(Canvas.Font.PixelsPerInch) + 'dpi) ' + VERSION + ' ' + COPYRIGHT;
  Canvas.Font.Color := clBlack;
//  Canvas.Font.Style := Canvas.Font.Style + [fsItalic];
  Canvas.TextOut(round(9200 * rUnit) - Canvas.TextWidth(sStr), round(2350 * rUnit), sStr);
//  Canvas.Font.Style := Canvas.Font.Style - [fsItalic];

  Canvas.Font.Color := clBlack;
  Canvas.TextOut(round(800 * rUnit), round(1250 * rUnit), '答え');

  // 左上の「▼ かけられるかず」
  nX := nXBase;
  Canvas.Pen.Color := clRed;
  Canvas.Font.Color := clRed;
  Canvas.Pen.Width := 1;
  for nIdx := (nX - round(25 * rUnit)) to (nX + round(25 * rUnit)) do
  begin
    Canvas.MoveTo(nX, round(1000 * rUnit));
    Canvas.LineTo(nIdx, round(900 * rUnit));
  end;
  sStr := 'かけられる数';
  Canvas.TextOut(nX - round(25 * rUnit), round(760 * rUnit), sStr);

//***************************************************************

  // かける数
  Canvas.Font.Color := clMaroon;
  Canvas.TextOut(round(800 * rUnit), round(1800 * rUnit), 'かける数');
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

  //  内側スライダ（枠）
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 3;
  Canvas.MoveTo(round( 300 * rUnit), round(4600 * rUnit));
  Canvas.LineTo(round( 300 * rUnit), round(6270 * rUnit));
  Canvas.LineTo(round( 600 * rUnit), round(6570 * rUnit));
//  Canvas.LineTo(round( 100 * rUnit), round(6600 * rUnit));
  Canvas.LineTo(round(9300 * rUnit), round(6570 * rUnit));
  Canvas.LineTo(round(9300 * rUnit), round(4600 * rUnit));
  Canvas.LineTo(round( 300 * rUnit), round(4600 * rUnit));

  // スライダ内かけられるかず
  Canvas.Font.Color := clRed;
  Canvas.Pen.Color := clRed;
  Canvas.Pen.Width := 1;
  nIdx := 1;
  while (nIdx <= 9) do
  begin
    nX := Round(nXBase + log10(nIdx) * 4000 * rUnit);
    Canvas.MoveTo(nX, round(4940 * rUnit));
    Canvas.LineTo(nX, round(5300 * rUnit));
    Inc(nIdx, 1);
  end;

  // スライダ内こたえ
  Canvas.Font.Color := clBlack;
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 1;
  nIdx := 1;
  while (nIdx <= 81) do
  begin
    nX := Round(nXBase + log10(nIdx) * 4000 * rUnit);
    Canvas.MoveTo(nX, round(5900 * rUnit));
    if (nIdx mod 5 = 0) then
      Canvas.LineTo(nX, round(5550 * rUnit))
    else
      Canvas.LineTo(nX, round(5650 * rUnit));
    Inc(nIdx, 1);
  end;
  Canvas.Pen.Width := 3;
  nIdx := 10;
  while (nIdx <= 80) do
  begin
    nX := Round(nXBase + log10(nIdx) * 4000 * rUnit);
    Canvas.MoveTo(nX, round(5900 * rUnit));
    Canvas.LineTo(nX, round(5500 * rUnit));
    Inc(nIdx, 10);
  end;

  nIdx := 1;
  while (nIdx <= 9) do
  begin
    nX := Round(nXBase + log10(nIdx) * 4000 * rUnit);
    sStr := IntToStr(nIdx);
    Canvas.TextOut(nX - Canvas.TextWidth(sStr) div 2, round(5350 * rUnit), sStr);
    Inc(nIdx, 1);
  end;
  nIdx := 10;
  while (nIdx <= 80) do
  begin
    nX := Round(nXBase + log10(nIdx) * 4000 * rUnit);
    sStr := IntToStr(nIdx);
    Canvas.TextOut(nX - Canvas.TextWidth(sStr) div 2, round(5350 * rUnit), sStr);
    Inc(nIdx, 10);
  end;
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
