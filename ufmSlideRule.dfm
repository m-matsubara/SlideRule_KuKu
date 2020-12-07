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
      Top = 9
      Width = 75
      Height = 25
      Caption = #21360#21047'...'
      TabOrder = 0
      OnClick = btPrintOutClick
    end
    object btPdf: TButton
      Left = 97
      Top = 9
      Width = 75
      Height = 25
      Caption = 'PDF'#20986#21147'...'
      TabOrder = 1
      OnClick = btPdfClick
    end
  end
  object PrinterSetupDialog1: TPrinterSetupDialog
    Left = 32
    Top = 48
  end
  object FileSaveDialog1: TFileSaveDialog
    DefaultExtension = 'pdf'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'PDF'#12501#12449#12452#12523
        FileMask = '*.pdf'
      end
      item
        DisplayName = #12377#12409#12390#12398#12501#12449#12452#12523
        FileMask = '*'
      end>
    Options = []
    Title = 'PDF'#12501#12449#12452#12523#20986#21147
    Left = 120
    Top = 48
  end
end
