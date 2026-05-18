unit window_user;

interface

uses
  Windows, window_callback, window_state, window_internal, SysUtils;

type
  TWindowUser = class
  private
    FHWND : HWND;
    FMainWindow : Boolean;
    FTitle      : PWideChar;
    FClassName  : PWideChar;
    FX          : Integer;
    FY          : Integer;
    FWidth      : Integer;
    FHeight     : Integer;
    FStyle      : DWORD;
    FExStyle    : DWORD;
    FIcon       : HICON;
    FCursor     : HCURSOR;
    FBackground : HBRUSH;
    FParent      : HWND;
    FCallbacks  : TWindowCallbacks;
    procedure CreateWindow;
  public
    constructor Create;
    destructor Destroy; override;

    property MainWindow : Boolean read FMainWindow write FMainWindow;
    property Title      : PWideChar read FTitle write FTitle;
    property ClassName  : PWideChar read FClassName write FClassName;
    property X          : Integer read FX write FX;
    property Y          : Integer read FY write FY;
    property Width      : Integer read FWidth write FWidth;
    property Height     : Integer read FHeight write FHeight;
    property Style      : DWORD read FStyle write FStyle;
    property ExStyle    : DWORD read FExStyle write FExStyle;
    property Icon       : HICON read FIcon write FIcon;
    property Cursor     : HCURSOR read FCursor write FCursor;
    property Background : HBRUSH read FBackground write FBackground;
    property Parent     : HWND read FParent write FParent;
    property Callbacks  : TWindowCallbacks read FCallbacks write FCallbacks;

    procedure ShowWindowSinc(AMode : Integer);
    function ShowWindowASinc(AMode : Integer) : boolean;
  end;

implementation

{ TWindowUser }

constructor TWindowUser.Create;
begin
  inherited Create;
  FHWND := 0;
  FMainWindow := False;
  FTitle      := 'FORM';
  FClassName  := 'FORM';
  FX          := CW_USEDEFAULT;
  FY          := CW_USEDEFAULT;
  FWidth      := CW_USEDEFAULT;
  FHeight     := CW_USEDEFAULT;
  FStyle      := WS_OVERLAPPEDWINDOW;
  FExStyle    := 0;
  FIcon       := 0;
  FCursor     := 0;
  FBackground := 0;
  FParent     := 0;
  ZeroMemory(@FCallBacks, sizeOf(TWindowCallbacks));
end;

procedure TWindowUser.CreateWindow;
var
  wc        : WNDCLASS;
  lAppState : TWindowState;
begin
  ZeroMemory(@wc, SizeOf(WNDCLASS));

  wc.lpfnWndProc   := @WindowProc;
  wc.hInstance     := hInstance;
  wc.lpszClassName := FClassName;
  wc.hCursor       := FCursor;
  wc.hbrBackground := FBackground;
  wc.hIcon         := FIcon;

  if RegisterClass(wc) = 0 then
    Exit;

  lAppState := TWindowState.Create;
  lAppState.MainWindow := FMainWindow;
  lAppState.Callbacks  := @FCallbacks;

  FHWND := CreateWindowEx(
    FExStyle,
    FClassName,
    FTitle,
    FStyle,
    FX, FY, FWidth, FHeight,
    FParent,
    0,
    hInstance,
    lAppState);

  if FHWND = 0 then
  begin
    lAppState.Free;
    Exit;
  end;
end;

destructor TWindowUser.Destroy;
begin
  inherited Destroy;
end;

function TWindowUser.ShowWindowASinc(AMode: Integer): Boolean;
var
  Msg: TMsg;
begin
  Result := True;
  if FHWND = 0 then
    CreateWindow;

  if FHWND = 0 then
    raise Exception.Create('Erro ao Criar Janela');

  ShowWindow(FHWND, CmdShow);
  UpdateWindow(FHWND);
  while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
  begin
    if Msg.message = WM_QUIT then
      Exit(False);

    TranslateMessage(Msg);
    DispatchMessage(Msg);
    Result := True;
  end;
end;

procedure TWindowUser.ShowWindowSinc(AMode: Integer);
var
  Msg: TMsg;
begin
  if FHWND = 0 then
    CreateWindow;

  if FHWND = 0 then
    raise Exception.Create('Erro ao Criar Janela');

  Windows.ShowWindow(FHWND, AMode);
  Windows.UpdateWindow(FHWND);

  while GetMessage(Msg, 0, 0, 0) do
  begin
    Windows.TranslateMessage(Msg);
    Windows.DispatchMessage(Msg);
  end;
end;

end.
