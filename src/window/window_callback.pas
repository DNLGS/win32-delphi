unit window_callback;

interface


uses
  Winapi.Windows;

type
  TButton = (Left, Right, Middle);

  TWindowOnMouseUp = procedure(hwnd: HWND; btn :TButton; x ,y :Integer; wParam: WPARAM); stdcall;
  TWindowOnMouseDown = procedure(hwnd: HWND; btn :TButton; x ,y :Integer; wParam: WPARAM); stdcall;
  TWindowCreateCallback = procedure(hwnd: HWND; cs: PCreateStruct); stdcall;
  TWindowDestroyCallback = procedure(hwnd: HWND); stdcall;
  TWindowCloseCallback = procedure(hwnd: HWND); stdcall;
  TWindowSizeCallback = procedure(hwnd: HWND; wParam: WPARAM; width, heigth : Integer); stdcall;
  TWindowActivateCallback = procedure(hwnd: HWND; wParam: WPARAM; lParam: LPARAM); stdcall;
  TWindowSetFocusCallback = procedure(hwnd: HWND); stdcall;
  TWindowKillFocusCallback = procedure(hwnd: HWND); stdcall;
  TWindowKeyDownCallback = procedure(hwnd: HWND; vkCode: WPARAM; flags: LPARAM); stdcall;
  TWindowKeyUpCallback = procedure(hwnd: HWND; vkCode: WPARAM; flags: LPARAM); stdcall;
  TWindowMouseMoveCallback = procedure(hwnd: HWND; x, y : Integer; keyFlags: WPARAM); stdcall;
  TWindowMouseWheelCallback = procedure(hwnd: HWND; delta, x, y : Integer; keyFlags: WPARAM); stdcall;
  TWindowTimerCallback = procedure(hwnd: HWND; timerId: UINT_PTR); stdcall;
  TWindowPaintCallback = procedure(hwnd: HWND; hdc : HDC ; rect : TRect); stdcall;
  TWindowEraseBackgroundCallback = procedure(hwnd: HWND; id: WPARAM); stdcall;

  TWindowCallbacks = record
    OnCreate: TWindowCreateCallback;
    OnDestroy: TWindowDestroyCallback;
    OnClose: TWindowCloseCallback;
    OnSize: TWindowSizeCallback;
    OnActivate: TWindowActivateCallback;
    OnSetFocus: TWindowSetFocusCallback;
    OnKillFocus: TWindowKillFocusCallback;
    OnKeyDown: TWindowKeyDownCallback;
    OnKeyUp: TWindowKeyUpCallback;
    OnMouseMove: TWindowMouseMoveCallback;
    OnMouseWheel: TWindowMouseWheelCallback;
    OnTimer: TWindowTimerCallback;
    OnPaint: TWindowPaintCallback;
    OnEraseBackground: TWindowEraseBackgroundCallback;
    OnMouseUp: TWindowOnMouseUp;
    OnMouseDown: TWindowOnMouseDown;
  end;
  PWindowCallbacks = ^TWindowCallbacks;

implementation

end.
