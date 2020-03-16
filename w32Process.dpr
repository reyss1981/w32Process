program w32Process;

uses
  Vcl.Forms,
  PCentral in 'PCentral.pas' {FCentral},
  hw32Process in 'hw32Process.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFCentral, FCentral);
  Application.Run;
end.
