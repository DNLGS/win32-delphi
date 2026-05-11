unit CustomWindow;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.UITypes;

const
  WM_DESTROY = $0002;
  WM_PAINT = $000F;
  WM_LBUTTONDOWN = $0201;
  WM_CLOSE = $0010;

function WindowProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

Type
  TCustomWindow = class
  private
    Fwc : WNDCLASS;
    FHandleWindow  : HWND;
    FMsgWindow : TMsg;
    FColorBg : UINT;
    FCaption : String;
    FClassName : String;
    FWidth : Integer;
    FHeigth : Integer;
    procedure PaintBG(const AColor : UInt; const hw : HWND);
    procedure CreateWindow;
  public
    constructor Create(const AClassName : String);
    destructor Destroy;override;
    procedure Show;
    procedure RePaint;
    property Caption: String read FCaption write FCaption;
    property Width: Integer read FWidth write FWidth;
    property Heigth: Integer read FHeigth write FHeigth;
    property Color: UINT read FColorBG write FColorBG;
end;

implementation

{ TCustomWindow }

constructor TCustomWindow.Create(const AClassName: String);
begin
  FClassName := AClassName;
  FHandleWindow := 0;
  FWidth := 600;
  FHeigth := 600;
end;

procedure TCustomWindow.CreateWindow;
begin
  if FHandleWindow <> 0 then
    Exit;

  ZeroMemory(@Fwc, SizeOf(Fwc));

  Fwc.lpfnWndProc   := @WindowProc;
  Fwc.hInstance     := hInstance;
  Fwc.lpszClassName := PWCHAR(FCaption);
  Fwc.hCursor       := LoadCursor(0, IDC_ARROW);     // Cursor padrão

  if RegisterClass(Fwc) = 0 then
  begin
    Writeln('Falha ao registrar classe');
    Exit;
  end;

  FHandleWindow := CreateWindowEx(
    0,
    PWCHAR(FClassName),
    PWCHAR(FCaption),
    WS_OVERLAPPEDWINDOW,
    0, 0, FWidth, FHeigth,
    0,
    0,
    hInstance,
    nil);

  if FHandleWindow = 0 then
  begin
    Writeln('Falha ao criar janela');
    Exit;
  end;
end;

destructor TCustomWindow.Destroy;
begin

  inherited;
end;

procedure TCustomWindow.PaintBG(const AColor: UInt; const hw: HWND);
begin

end;

procedure TCustomWindow.RePaint;
begin
  InvalidateRect(FHandleWindow, nil, True); // Invalida a cor pra mudar
end;

procedure TCustomWindow.Show;
begin
  CreateWindow;
  ShowWindow(FHandleWindow, CmdShow);
  UpdateWindow(FHandleWindow);

  while GetMessage(FMsgWindow, 0, 0, 0) do
  begin
    TranslateMessage(FMsgWindow);  // Traduz teclas de aceleração
    DispatchMessage(FMsgWindow);   // Envia a mensagem para a WindowProc
  end;
end;

function WindowProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT;
begin
  case uMsg of
    WM_CLOSE :
    begin
      if MessageBox(hwnd,'Deseja Sair?', 'Aplicacao', MB_OKCANCEL) = idOK then
        DestroyWindow(hwnd);

      Exit(0);
    end;
    WM_DESTROY :
    begin
      PostQuitMessage(0);
      Exit(0);
    end;
    WM_LBUTTONDOWN :
    begin
      Exit(0);
    end;

    WM_PAINT : // Pinta a janela
    begin
//      PaintBG(FColorBg, hwnd);
      Exit(0);
    end;
  end;

  // Defaul eu acho
  Result := DefWindowProc(hwnd, uMsg, wParam, lParam);
end;

end.
