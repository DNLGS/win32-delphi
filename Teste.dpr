program Teste;

{$APPTYPE GUI}

{$R *.res}

uses
  System.SysUtils,
  WinAPI.Windows,
  CustomWindow in 'CustomWindow.pas',
  WrapperWIN32 in 'WrapperWIN32.pas',
  WindowData in 'WindowData.pas',
  glad_gl in 'dependencies\glad_gl.pas';

var
  fm : TCustomWindow;
begin
  try
    fm := TCustomWindow.Create('JANELA', 'JANELA');
    try
      fm.Show;
    finally
      fm.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
