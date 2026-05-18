unit WrapperWIN32;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  Winapi.d2d1,
  System.UITypes, WindowData;

const
  WM_DESTROY = $0002;
  WM_PAINT = $000F;
  WM_LBUTTONDOWN = $0201;
  WM_CLOSE = $0010;
  WM_NCCREATE = $0081;
  WM_CREATE = $0001;
  WM_SIZE = $0005;
  WM_QUIT = $0012;

function WindowProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function LoadWGL(ANameFunc : PAnsiChar) : Pointer;

implementation

function LoadWGL(ANameFunc : PAnsiChar) : Pointer;
var
  ModuloOpenGL: HMODULE;
begin
  Result := GetProcAddress(ModuloOpenGL, ANameFunc);

  if Result = nil then
  begin
    ModuloOpenGL := GetModuleHandle('opengl32.dll');
    if ModuloOpenGL <> 0 then
      Result := GetProcAddress(ModuloOpenGL, ANameFunc);
  end;
end;

function CreateRenderTarget(const AHandler: HWND; const AAppState : TWindowData) : ID2D1HwndRenderTarget;
var
  lhr : HRESULT;
  lrc : TRect;
  lrt : ID2D1HwndRenderTarget;
begin
  Result := nil;
  GetClientRect(AHandler, lrc);

  lhr := AAppState.PD2D1Factory.CreateHwndRenderTarget(
    D2D1RenderTargetProperties(),
    D2D1HwndRenderTargetProperties(
      AHandler,
      D2D1SizeU(lrc.right - lrc.left, lrc.bottom - lrc.top)),
    lrt);
  Result := lrt;
end;

function CreateD2DFactory : ID2D1Factory;
var
  lhr : HRESULT;
begin
  Result := nil;
  lhr := D2D1CreateFactory(
    D2D1_FACTORY_TYPE_SINGLE_THREADED,
    ID2D1Factory,
    nil,
    Result);
end;

function WindowProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
var
  pCreate : PCREATESTRUCT;
  pState : PTWindowData;
  lAppState : TWindowData;
  ps : PAINTSTRUCT;
begin
  case uMsg of
    WM_NCCREATE:
    begin
      pCreate := PCREATESTRUCT(lParam);
      pState := PTWindowData(pCreate.lpCreateParams);
      SetWindowLongPtr(hwnd, GWLP_USERDATA, LONG_PTR(pState));
      Exit(DefWindowProc(hwnd, uMsg, wParam, lParam));
    end;

    WM_CREATE:
    begin
      lAppState := GetAppState(hwnd);
      lAppState.PD2D1Factory := CreateD2DFactory;
//      lAppState.RenderTarget := CreateRenderTarget(hwnd, lAppState);

      if Assigned(lAppState.OnCreate) then
        lAppState.OnCreate(hwnd);

      Exit(0);
    end;
    WM_SIZE:
    begin
      lAppState := GetAppState(hwnd);
      if Assigned(lAppState.OnSize) then
        lAppState.OnSize(hwnd,LOWORD(lParam), HiWord(lParam));

    end;
    WM_CLOSE :
    begin
      if MessageBox(hwnd,'Deseja Sair?', 'Aplicacao', MB_OKCANCEL) = idOK then
        DestroyWindow(hwnd);

      Exit(0);
    end;
    WM_LBUTTONDOWN :
    begin
      lAppState := GetAppState(hwnd);
      if Assigned(lAppState.OnMouseLeftClick) then
        lAppState.OnMouseLeftClick(lAppState);

      Exit(0);
    end;
    WM_DESTROY:
    begin
      pState := PTWindowData(GetWindowLongPtr(hwnd, GWLP_USERDATA));
      if Assigned(pState) then
      begin
        TWindowData(pState).RenderTarget := nil;
        TWindowData(pState).PD2D1Factory := nil;
        Dispose(pState);
      end;
      PostQuitMessage(0);
      Exit(0);
    end;

    WM_PAINT:
    begin
      BeginPaint(hwnd, ps);
      try
        lAppState := GetAppState(hwnd);
        if Assigned(lAppState.OnPaint) then
          lAppState.OnPaint(hwnd)
      finally
        EndPaint(hwnd, ps);
      end;
      Exit(0);
    end;
  end;

  // Defaul eu acho
  Result := DefWindowProc(hwnd, uMsg, wParam, lParam);
end;

end.
