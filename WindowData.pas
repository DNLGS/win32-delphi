unit WindowData;

interface

uses
  Winapi.Windows,
  Winapi.d2d1;

type
  TOnMouseLeftClick = procedure(Sender: TObject) of object;
  TOnPaint = procedure(Handler : HWND) of object;
  TOnCreate = procedure(Handler : HWND) of object;
  TOnSize = procedure(Handler : HWND; width, heigth : Integer) of object;

  TWindowData = class
    private
      FWidth : Integer;
      FHeigth : Integer;
      FColor : UINT;
      FTitle : String;
      FPD2D1Factory : ID2D1Factory;
      FPRenderTarget : ID2D1HwndRenderTarget;
      FOnMouseLeftClick : TOnMouseLeftClick;
      FOnPaint : TOnPaint;
      FOnCreate : TOnCreate;
      FOnSize : TOnSize;
    public
      property Width: Integer read FWidth write FWidth;
      property Heigth: Integer read FHeigth write FHeigth;
      property Color: UINT read FColor write FColor;
      property Title: String read FTitle write FTitle;
      property PD2D1Factory: ID2D1Factory read FPD2D1Factory write FPD2D1Factory;
      property RenderTarget: ID2D1HwndRenderTarget read FPRenderTarget write FPRenderTarget;
      property OnMouseLeftClick: TOnMouseLeftClick read FOnMouseLeftClick write FOnMouseLeftClick;
      property OnPaint: TOnPaint read FOnPaint write FOnPaint;
      property OnCreate: TOnCreate read FOnCreate write FOnCreate;
      property OnSize: TOnSize read FOnSize write FOnSize;
      constructor Create;
  end;

  PTWindowData = ^TWindowData;
  function GetAppState(const Ahwnd : HWND) : TWindowData;

implementation

{ TWindowData }

constructor TWindowData.Create;
begin
  inherited Create;
  FWidth := 0;
  FHeigth := 0;
  FColor := 0;
  FTitle := '';
  FPD2D1Factory := Nil;
  FOnMouseLeftClick := nil;
  FPRenderTarget := nil;
end;

function GetAppState(const Ahwnd : HWND) : TWindowData;
var
  lAppState : PTWindowData;
begin
  lAppState := PTWindowData(GetWindowLongPtr(Ahwnd, GWLP_USERDATA));
  Result := TWindowData(lAppState);
end;

end.
