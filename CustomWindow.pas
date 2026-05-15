unit CustomWindow;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  Winapi.d2d1,
//  Winapi.WinGdi,
  System.UITypes, WrapperWIN32, WindowData, glad_gl;

Type
  TCustomWindow = class
  private
    Fwc : WNDCLASS;
    FDC : HDC;
    FContext : HGLRC;
    FHandleWindow  : HWND;
    FMsgWindow : TMsg;
    FCaption : String;
    FClassName : String;
    FWidth : Integer;
    FHeigth : Integer;
    FStateWindow : PTWindowData;
    procedure CreateWindow;
    procedure LeftClick(Sender : TObject);
    procedure Paint(AHandler : HWND);
    procedure PaintGradient(AHandler : HWND);
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
var
  FInst : TWindowData;
  pfd : PIXELFORMATDESCRIPTOR;
  PixelFormat : Integer;
begin
  if FHandleWindow <> 0 then
    Exit;

  ZeroMemory(@Fwc, SizeOf(Fwc));

  FInst := TWindowData.Create;
  FStateWindow := PTWindowData(FInst);

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

  FDC := GetDC(FHandleWindow);

  ZeroMemory(@pfd, SizeOf(pfd));
  pfd.nSize      := SizeOf(pfd);
  pfd.nVersion   := 1;
  pfd.dwFlags    := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  pfd.iPixelType := PFD_TYPE_RGBA;
  pfd.cColorBits := 32;
  pfd.cDepthBits := 24;
  pfd.iLayerType := PFD_MAIN_PLANE;

  PixelFormat := ChoosePixelFormat(FDC, @pfd);
  SetPixelFormat(FDC, PixelFormat, @pfd);

  FContext := wglCreateContext(FDC);
  if not wglMakeCurrent(FDC, FContext) then
    WriteLn('Erro');

  if not gladLoadGL(@loadWGL) then
  begin
    WriteLn('Falha ao inicializar o GLAD!');
    Halt(1);
  end;

//  TWindowData(FStateWindow).OnMouseLeftClick := LeftClick;
//  TWindowData(FStateWindow).OnPaint := Paint;
//  TWindowData(FStateWindow).OnPaint := PaintGradient;
  TWindowData(FStateWindow).Color := RGB(255,255,255);
end;

destructor TCustomWindow.Destroy;
begin

  inherited;
end;

procedure TCustomWindow.LeftClick(Sender: TObject);
begin
  
end;

procedure TCustomWindow.Paint(AHandler: HWND);
var lrect : TRect;
    lAppState : TWindowData;
    lhr : HRESULT;
    lbrush : ID2D1SolidColorBrush;
    lbrushProp : TD2D1BrushProperties;
begin
  GetClientRect(AHandler,lrect);
  lAppState := GetAppState(AHandler);

  lbrushProp := Default(TD2D1BrushProperties);
  lbrushProp.opacity := 1.0;

  lhr := lAppState.RenderTarget.CreateSolidColorBrush(
    D2D1ColorF(1, 0, 0, 1.0),
    @lbrushProp,
  lbrush);

  lAppState.RenderTarget.BeginDraw;
  lAppState.RenderTarget.Clear(D2D1ColorF(1.0, 1.0, 1.0, 1.0));
  lAppState.RenderTarget.DrawRectangle(
    D2D1RectF(
      lrect.left + 100.0,
      lrect.top + 100.0,
      lrect.right - 100.0,
      lrect.bottom - 100.0),
      lbrush,
      1,
      nil);
  lhr := lAppState.RenderTarget.EndDraw;
end;

procedure TCustomWindow.PaintGradient(AHandler: HWND);
var
  lhr : HRESULT;
  lAppState : TWindowData;
  lbrushStop : array [0 ..1 ] of TD2D1GradientStop;
  lGradientStops : ID2D1GradientStopCollection;
  lbrushcollprop : D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES;
  lRect : TRect;
  lbrushProp : TD2D1BrushProperties;
  lbrushgrad : ID2D1LinearGradientBrush;
  lD2DRect: TD2D1RectF;
begin
  lAppState := GetAppState(AHandler);
  GetClientRect(AHandler,lrect);

  lD2DRect := D2D1RectF(lrect.left + 100, lrect.top + 100, lrect.right - 100, lrect.bottom - 100);

  lbrushProp := Default(TD2D1BrushProperties);
  lbrushProp.opacity := 1.0;

  lbrushStop[0].color := D2D1ColorF(1,0,0,1);
  lbrushStop[0].position := 0;
  lbrushStop[1].color := D2D1ColorF(0,0,1,1);
  lbrushStop[1].position := 1;

  // 1. Criar a coleção de stops
  lhr := lAppState.RenderTarget.CreateGradientStopCollection(
    @lbrushStop[0],
    Length(lbrushStop),
    D2D1_GAMMA_1_0,
    D2D1_EXTEND_MODE_CLAMP,
    lGradientStops);

  // 2. Definir os pontos do gradiente
  lbrushcollprop := Default(D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES);
  lbrushcollprop.startPoint := D2D1PointF(lD2DRect.left, lD2DRect.top);
  lbrushcollprop.endPoint   := D2D1PointF(lD2DRect.right, lD2DRect.bottom);

  // 3. Criar o brush com a coleção
  lhr := lAppState.RenderTarget.CreateLinearGradientBrush(
    lbrushcollprop,
    @lbrushProp,
    lGradientStops,
    lbrushgrad);

  // 4. Desenhar
  lAppState.RenderTarget.BeginDraw;
  lAppState.RenderTarget.Clear(D2D1ColorF(1.0, 1.0, 1.0, 1.0));
  lAppState.RenderTarget.FillRectangle(
    lD2DRect,
    lbrushgrad);
  lhr := lAppState.RenderTarget.EndDraw;
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
