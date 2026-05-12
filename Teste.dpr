program Teste;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  WinAPI.Windows,
  CustomWindow in 'CustomWindow.pas',
  WrapperWIN32 in 'WrapperWIN32.pas',
  WindowData in 'WindowData.pas';

var
  fm : TCustomWindow;
begin
  try
    fm := TCustomWindow.Create('JANELA', 'JANELA');
    try
//      fm.Caption := 'JANELA';
//      fm.Color := RGB(0,0,0);
      fm.Show;
    finally
      fm.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
