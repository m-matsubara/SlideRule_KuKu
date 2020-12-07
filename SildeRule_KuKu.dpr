program SildeRule_KuKu;

uses
  Forms,
  ufmSlideRule in 'ufmSlideRule.pas' {frmSlideRule};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmSlideRule, frmSlideRule);
  Application.Run;
end.
