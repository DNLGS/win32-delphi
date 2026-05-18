unit window_internal;

interface

uses
  Winapi.Windows, window_state, window_callback;

function WindowProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
function GetAppState(const Ahwnd : HWND) : TWindowState; inline;
function GET_X_LPARAM(lp: LPARAM): Integer; inline;
function GET_Y_LPARAM(lp: LPARAM): Integer; inline;

const
  WM_DESTROY = $0002;
  WM_PAINT = $000F;
  WM_LBUTTONDOWN = $0201;
  WM_CLOSE = $0010;
  WM_NCCREATE = $0081;
  WM_CREATE = $0001;
  WM_SIZE = $0005;
  WM_ACTIVATE = $0006;
  WM_SETFOCUS = $0007;
  WM_KILLFOCUS = $0008;
  WM_KEYDOWN = $0100;
  WM_KEYUP = $0101;
  WM_MOUSEMOVE = $0200;
  WM_RBUTTONDOWN = $0204;
  WM_RBUTTONUP = $0205;
  WM_MBUTTONDOWN = $0207;
  WM_LBUTTONUP = $0202;
  WM_MBUTTONUP = $0208;
  WM_MOUSEWHEEL = $020A;
  WM_TIMER = $0113;
  WM_QUIT = $0012;

implementation

function WindowProc(hwnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  pwState  : TWindowState;
  cb       : TWindowCallbacks;
  pCreate  : PCreateStruct;
  ps       : TPaintStruct;
  lhdc      : HDC;
  btn      : TButton;
  x, y     : Integer;
begin
  pwState := nil;
  ZeroMemory(@cb, SizeOf(TWindowCallbacks));

  case uMsg of
    WM_NCCREATE:
    begin
      pCreate := PCREATESTRUCT(lParam);
      pwState := TWindowState(pCreate.lpCreateParams);
      SetWindowLongPtr(hwnd, GWLP_USERDATA, LONG_PTR(pwState));
      if (pwState <> nil) and (pwState.Callbacks <> nil) then
        cb := pwState.Callbacks^;
    end;
  else
    pwState := GetAppState(hwnd);
    if (pwState <> nil) and (pwState.Callbacks <> nil) then
      cb := pwState.Callbacks^;
  end;

  case uMsg of
    WM_CREATE:
    begin
      if Assigned(cb.OnCreate) then
        cb.OnCreate(hwnd, PCREATESTRUCT(lParam));
    end;

    WM_DESTROY:
    begin
      if Assigned(cb.OnDestroy) then
        cb.OnDestroy(hwnd);
      if (pwState <> nil) and pwState.MainWindow then
        PostQuitMessage(0);
      if pwState <> nil then
      begin
        SetWindowLongPtr(hwnd, GWLP_USERDATA, 0);
        pwState.Free;
      end;
    end;

    WM_CLOSE:
    begin
      if Assigned(cb.OnClose) then
        cb.OnClose(hwnd);
      DestroyWindow(hwnd);
      Exit(0);
    end;

    WM_SIZE:
    begin
      if Assigned(cb.OnSize) then
      begin
        cb.OnSize(hwnd, wParam, LOWORD(lParam), HIWORD(lParam));
        Exit(0);
      end;
    end;

    WM_ACTIVATE:
    begin
      if Assigned(cb.OnActivate) then
      begin
        cb.OnActivate(hwnd, wParam, lParam);
        Exit(0);
      end;
    end;

    WM_SETFOCUS:
    begin
      if Assigned(cb.OnSetFocus) then
      begin
        cb.OnSetFocus(hwnd);
        Exit(0);
      end;
    end;

    WM_KILLFOCUS:
    begin
      if Assigned(cb.OnKillFocus) then
      begin
        cb.OnKillFocus(hwnd);
        Exit(0);
      end;
    end;

    WM_KEYDOWN:
    begin
      if Assigned(cb.OnKeyDown) then
      begin
        cb.OnKeyDown(hwnd, wParam, lParam);
        Exit(0);
      end;
    end;

    WM_KEYUP:
    begin
      if Assigned(cb.OnKeyUp) then
      begin
        cb.OnKeyUp(hwnd, wParam, lParam);
        Exit(0);
      end;
    end;

    WM_MOUSEMOVE:
    begin
      if Assigned(cb.OnMouseMove) then
      begin
        x := GET_X_LPARAM(lParam);
        y := GET_Y_LPARAM(lParam);
        cb.OnMouseMove(hwnd, x, y, wParam);
        Exit(0);
      end;
    end;

    WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN:
    begin
      if Assigned(cb.OnMouseDown) then
      begin
        x := GET_X_LPARAM(lParam);
        y := GET_Y_LPARAM(lParam);
        case uMsg of
          WM_LBUTTONDOWN: btn := TButton.Left;
          WM_RBUTTONDOWN: btn := TButton.Right;
          else            btn := TButton.Middle;
        end;
        cb.OnMouseDown(hwnd, btn, x, y, wParam);
        Exit(0);
      end;
    end;

    WM_LBUTTONUP, WM_RBUTTONUP, WM_MBUTTONUP:
    begin
      if Assigned(cb.OnMouseUp) then
      begin
        x := GET_X_LPARAM(lParam);
        y := GET_Y_LPARAM(lParam);
        case uMsg of
          WM_LBUTTONUP: btn := TButton.Left;
          WM_RBUTTONUP: btn := TButton.Right;
          else          btn := TButton.Middle;
        end;
        cb.OnMouseUp(hwnd, btn, x, y, wParam);
        Exit(0);
      end;
    end;

    WM_MOUSEWHEEL:
    begin
      if Assigned(cb.OnMouseWheel) then
      begin
        x := GET_X_LPARAM(lParam);
        y := GET_Y_LPARAM(lParam);
        cb.OnMouseWheel(hwnd, SmallInt(HIWORD(wParam)), x, y, LOWORD(wParam));
        Exit(0);
      end;
    end;

    WM_TIMER:
    begin
      if Assigned(cb.OnTimer) then
      begin
        cb.OnTimer(hwnd, wParam);
        Exit(0);
      end;
    end;
    WM_PAINT:
    begin
      lhdc := BeginPaint(hwnd, ps);
      if Assigned(cb.OnPaint) then
        cb.OnPaint(hwnd, lhdc, ps.rcPaint);
      EndPaint(hwnd, ps);
      Exit(0);
    end;
  end;

  Result := DefWindowProc(hwnd, uMsg, wParam, lParam);
end;

function GetAppState(const Ahwnd : HWND) : TWindowState; inline;
begin
  Result := TWindowState(GetWindowLongPtr(Ahwnd, GWLP_USERDATA));
end;

function GET_X_LPARAM(lp: LPARAM): Integer; inline;
begin
  Result := Integer(SmallInt(LOWORD(lp)));
end;

function GET_Y_LPARAM(lp: LPARAM): Integer; inline;
begin
  Result := Integer(SmallInt(HIWORD(lp)));
end;

end.

