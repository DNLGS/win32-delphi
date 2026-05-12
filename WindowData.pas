unit WindowData;

interface

uses
  Winapi.Windows;

type
  TOnMouseLeftClick = procedure(Sender: TObject) of object;

  TWindowData = class
    private
      FWidth : Integer;
      FHeigth : Integer;
      FColor : UINT;
      FTitle : String;
      FOnMouseLeftClick : TOnMouseLeftClick;
    public
      property Width: Integer read FWidth write FWidth;
      property Heigth: Integer read FHeigth write FHeigth;
      property Color: UINT read FColor write FColor;
      property Title: String read FTitle write FTitle;
      property OnMouseLeftClick: TOnMouseLeftClick read FOnMouseLeftClick write FOnMouseLeftClick;
  end;

  PTWindowData = ^TWindowData;

implementation

end.
