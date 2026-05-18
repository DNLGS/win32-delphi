program Teste;

{$APPTYPE GUI}

{$R *.res}

uses
  System.SysUtils,
  WinAPI.Windows,
  glad_gl in 'dependencies\glad_gl.pas',
  window_internal in 'src\window\window_internal.pas',
  window_callback in 'src\window\window_callback.pas',
  window_state in 'src\window\window_state.pas',
  window_user in 'src\window\window_user.pas';

var
  fm : TWindowUser;
begin
  try
    fm := TWindowUser.Create;
    try
      fm.MainWindow := True;
      fm.Title := 'JANELA';
      fm.ClassName := 'JANELATESTE';
      fm.X := 0;
      fm.Y := 0;
      fm.Width := 800;
      fm.Height := 800;
      fm.Cursor := LoadCursor(0, IDC_ARROW);
      fm.ShowWindowSinc(1);
    finally
      fm.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
