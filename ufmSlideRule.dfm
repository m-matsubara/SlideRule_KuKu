object frmSlideRule: TfrmSlideRule
  Left = 134
  Top = 186
  Caption = #20061#20061' '#35336#31639#23610'   Copyright '#169' 2020 '#26494#21407#27491#21644
  ClientHeight = 616
  ClientWidth = 846
  Color = clWindow
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 12
  object Image1: TImage
    Left = 80
    Top = 112
    Width = 105
    Height = 105
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 846
    Height = 41
    Align = alTop
    TabOrder = 0
    object btPrintOut: TButton
      Left = 16
      Top = 8
      Width = 75
      Height = 25
      Caption = #21360#21047'...'
      TabOrder = 0
      OnClick = btPrintOutClick
    end
  end
  object PrinterSetupDialog1: TPrinterSetupDialog
    Left = 32
    Top = 48
  end
end
