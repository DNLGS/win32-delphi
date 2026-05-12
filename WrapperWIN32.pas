unit WrapperWIN32;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
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
  ps : PAINTSTRUCT;
  lhdc : HDC;
  lbrush : HBRUSH;
begin
  case uMsg of
    WM_NCCREATE :
    begin
      pCreate := PCREATESTRUCT(lParam) ;
      pState := PTWindowData(pCreate.lpCreateParams);
      SetWindowLongPtr(hwnd, GWLP_USERDATA, LONG_PTR(pState));
    end;
    WM_CLOSE :
    begin
      if MessageBox(hwnd,'Deseja Sair?', 'Aplicacao', MB_OKCANCEL) = idOK then
        DestroyWindow(hwnd);

      Exit(0);
    end;
    WM_LBUTTONDOWN :
    begin
      pState := PTWindowData(GetWindowLongPtr(hwnd, GWLP_USERDATA));
      if Assigned(TWindowData(pState).OnMouseLeftClick) then
        TWindowData(pState).OnMouseLeftClick(TWindowData(pState));

      Exit(0);
    end;
    WM_DESTROY:
    begin
      pState := PTWindowData(GetWindowLongPtr(hwnd, GWLP_USERDATA));
      if Assigned(pState) then
        Dispose(pState);

      PostQuitMessage(0);
      Exit(DefWindowProc(hwnd, uMsg, wParam, lParam));
    end;

    WM_PAINT : // Pinta a janela
    begin
      lhdc := BeginPaint(hwnd, ps);
      pState := PTWindowData(GetWindowLongPtr(hwnd, GWLP_USERDATA));
      lbrush := CreateSolidBrush(TWindowData(pState).Color);
      FillRect(lhdc, ps.rcPaint, lBrush);
      DeleteObject(lbrush);
      EndPaint(hwnd, ps);
      Exit(0);
    end;
  end;

  // Defaul eu acho
  Result := DefWindowProc(hwnd, uMsg, wParam, lParam);
end;

end.
