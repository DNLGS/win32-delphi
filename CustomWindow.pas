unit CustomWindow;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.UITypes, WrapperWIN32, WindowData;

Type
  TCustomWindow = class
  private
    Fwc : WNDCLASS;
    FHandleWindow  : HWND;
    FMsgWindow : TMsg;
    FCaption : String;
    FClassName : String;
    FWidth : Integer;
    FHeigth : Integer;
    FStateWindow : PTWindowData;
    procedure CreateWindow;
    procedure LeftClick(Sender : TObject);
  public
    constructor Create(const AClassName, AWindowName : String);
    destructor Destroy;override;
    procedure Show;
    procedure RePaint;
    procedure SetColor(AColor : UINT);
end;

implementation

{ TCustomWindow }

constructor TCustomWindow.Create(const AClassName, AWindowName: String);
begin
  FClassName := AClassName;
  FCaption := AWindowName;
  FHandleWindow := 0;
  FWidth := 600;
  FHeigth := 600;
end;

procedure TCustomWindow.CreateWindow;
begin
  if FHandleWindow <> 0 then
    Exit;

  ZeroMemory(@Fwc, SizeOf(Fwc));

  FStateWindow := New(PTWindowData);

  if FStateWindow = nil then
    Exit;

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
    FStateWindow);

  if FHandleWindow = 0 then
  begin
    Writeln('Falha ao criar janela');
    Exit;
  end;

  TWindowData(FStateWindow).OnMouseLeftClick := LeftClick;
end;

destructor TCustomWindow.Destroy;
begin

  inherited;
end;

procedure TCustomWindow.LeftClick(Sender: TObject);
begin
  SetColor(RGB(Random(256),Random(256),Random(256)));
  RePaint;
end;

procedure TCustomWindow.RePaint;
begin
  InvalidateRect(FHandleWindow, nil, True); // Invalida a cor pra mudar
end;

procedure TCustomWindow.SetColor(AColor: UINT);
begin
  TWindowData(FStateWindow).Color := AColor;
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



end.
