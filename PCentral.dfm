object FCentral: TFCentral
  Left = 0
  Top = 0
  Caption = 'w32Process'
  ClientHeight = 340
  ClientWidth = 392
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 386
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 9
      Width = 105
      Height = 25
      Caption = 'listar procesos'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object Panel2: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 50
    Width = 386
    Height = 287
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object TreeView1: TTreeView
      Left = 0
      Top = 0
      Width = 386
      Height = 287
      Align = alClient
      Indent = 19
      TabOrder = 0
    end
  end
end
