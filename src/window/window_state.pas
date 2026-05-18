unit window_state;

interface

uses window_callback, windows;

type
  TWindowState = class
  private
    FCallbacks: PWindowCallbacks;
    FMainWindow : Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    property Callbacks: PWindowCallbacks read FCallbacks write FCallbacks;
    property MainWindow: Boolean read FMainWindow write FMainWindow;
  end;

  PWindowState = ^TWindowState;

implementation

constructor TWindowState.Create;
begin
  inherited Create;
end;

destructor TWindowState.Destroy;
begin
  inherited Destroy;
end;

end.
