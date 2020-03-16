unit PCentral;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls;

type

  TFCentral = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    TreeView1: TTreeView;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FCentral: TFCentral;

implementation

{$R *.dfm}

uses
   hw32Process;

procedure TFCentral.Button1Click(Sender: TObject);
begin
   EnumAllw32Processes();
   ShowProcess(TreeView1);
end;

end.
