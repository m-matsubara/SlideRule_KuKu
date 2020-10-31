program slide_rule;

uses
  Forms,
  ufmSlideRule in 'ufmSlideRule.pas' {frmSlideRule};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmSlideRule, frmSlideRule);
  Application.Run;
end.
