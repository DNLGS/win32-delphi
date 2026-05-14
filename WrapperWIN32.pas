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

function WindowProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

implementation

function WindowProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT;
var
  pCreate : PCREATESTRUCT;
  pState : PTWindowData;
  lAppState : TWindowData;
  ps : PAINTSTRUCT;
  lhdc : HDC;
  lbrush : HBRUSH;
  pD2DFactory : ID2D1Factory;
  lrt : ID2D1HwndRenderTarget;
  lhr : HRESULT;
  lrc : TRect;
begin
  case uMsg of
    WM_NCCREATE:
    begin
      pCreate := PCREATESTRUCT(lParam);
      pState := PTWindowData(pCreate.lpCreateParams);
      SetWindowLongPtr(hwnd, GWLP_USERDATA, LONG_PTR(pState));
      Exit(DefWindowProc(hwnd, uMsg, wParam, lParam)); // importante retornar TRUE
    end;

    WM_CREATE:
    begin
      pState := PTWindowData(GetWindowLongPtr(hwnd, GWLP_USERDATA));
      pD2DFactory := nil;
      lhr := D2D1CreateFactory(
        D2D1_FACTORY_TYPE_SINGLE_THREADED,
        ID2D1Factory,
        nil,
        pD2DFactory);
      TWindowData(pState).PD2D1Factory := pD2DFactory;
      GetClientRect(hwnd, lrc);
      lhr := TWindowData(pState).PD2D1Factory.CreateHwndRenderTarget(
        D2D1RenderTargetProperties(),
        D2D1HwndRenderTargetProperties(
          hwnd,
          D2D1SizeU(lrc.right - lrc.left, lrc.bottom - lrc.top)),
        lrt);
      TWindowData(pState).RenderTarget := lrt;
      Exit(0);
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

      if Assigned(TWindowData(pState).RenderTarget) then
        TWindowData(pState).RenderTarget := nil;

      if Assigned(TWindowData(pState).PD2D1Factory) then
        TWindowData(pState).PD2D1Factory := nil;

      if Assigned(pState) then
        Dispose(pState);

      PostQuitMessage(0);
      Exit(DefWindowProc(hwnd, uMsg, wParam, lParam));
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
