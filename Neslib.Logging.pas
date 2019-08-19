unit Neslib.Logging;
{< Logging utilities }

{$INCLUDE 'Neslib.inc'}

interface

type
  { Logging levels in decreasing level of verbosity.
    You can set the level of each log level, but also use the level to limit
    the log output. }
  TLogLevel = (
    { Most verbose level }
    Verbose,

    { Debug messages }
    Debug,

    { Informational messages }
    Info,

    { Warning messages }
    Warning,

    { Error messages }
    Error,

    { Critical error messages }
    Critical);

type
  { Adds functionality to TLogLevel }
  _LogLevelHelper = record helper for TLogLevel
  {$REGION 'Internal Declarations'}
  private const
    TO_STRING: array [TLogLevel] of String = (
      'Verbose', 'Debug', 'Info', 'Warning', 'Error', 'Critical');
    PREFIXES: array [TLogLevel] of String = (
      'VERBOSE: ', 'DEBUG: ', 'INFO: ', 'WARNING: ', 'ERROR: ', 'CRITICAL: ');
  {$ENDREGION 'Internal Declarations'}
  public
    { Converts the log level to a string }
    function ToString: String; inline;

    { Converts the log level to a prefix string to append to log messages.
      For example, TLogLevel.Warning.Prefix returns the prefix string
      'WARNING: ' }
    function Prefix: String; inline;
  end;

type
  { A custom logging procedure that you can set with TLog.LogProc.

    Parameters:
      AMessage: the message to log
      ALevel: the level of the message }
  TLogProc = procedure(const AMessage: String; const ALevel: TLogLevel);

type
  { Cross-platform logging facility. By default, log output goes to:
    * Windows: debug log (Output window in Delphi)
    * macOS: debug (PAServer) terminal
    * iOS: log window, available through attached devices in Xcode
    * Android: LogCat window in Android Debug Monitor
    However, you can redirect log output by setting your own log function
    (see SetLogProc) }
  TLog = class
  {$REGION 'Internal Declarations'}
  private class var
    FLevel: TLogLevel;
    FLogProc: TLogProc;
  public
    class constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    { Log a message with a specific level.

      Parameters:
        ALevel: the level of the message
        AMessage: the message to log
        AArgs: (optional) format arguments }
    class procedure Log(const ALevel: TLogLevel;
      const AMessage: String); overload; static;
    class procedure Log(const ALevel: TLogLevel; const AMessage: String;
      const AArgs: array of const); overload; static;

    { Log a message with a Verbose level.

      Parameters:
        AMessage: the message to log
        AArgs: (optional) format arguments }
    class procedure Verbose(const AMessage: String); overload; inline; static;
    class procedure Verbose(const AMessage: String;
      const AArgs: array of const); overload; static;

    { Log a message with a Debug level.

      Parameters:
        AMessage: the message to log
        AArgs: (optional) format arguments }
    class procedure Debug(const AMessage: String); overload; inline; static;
    class procedure Debug(const AMessage: String;
      const AArgs: array of const); overload; static;

    { Log a message with an Info level.

      Parameters:
        AMessage: the message to log
        AArgs: (optional) format arguments }
    class procedure Info(const AMessage: String); overload; inline; static;
    class procedure Info(const AMessage: String;
      const AArgs: array of const); overload; static;

    { Log a message with a Warning level.

      Parameters:
        AMessage: the message to log
        AArgs: (optional) format arguments }
    class procedure Warning(const AMessage: String); overload; inline; static;
    class procedure Warning(const AMessage: String;
      const AArgs: array of const); overload; static;

    { Log a message with an Error level.

      Parameters:
        AMessage: the message to log
        AArgs: (optional) format arguments }
    class procedure Error(const AMessage: String); overload; inline; static;
    class procedure Error(const AMessage: String;
      const AArgs: array of const); overload; static;

    { Log a message with a Critical level.

      Parameters:
        AMessage: the message to log
        AArgs: (optional) format arguments }
    class procedure Critical(const AMessage: String); overload; inline; static;
    class procedure Critical(const AMessage: String;
      const AArgs: array of const); overload; static;

    { Resets the logging procedure (see LogProc) to the default logging
      procedure for the platform:
      * Windows: output to the debug log (Output window in Delphi)
      * macOS: output to the debug (PAServer) terminal
      * iOS: output to the log window, available through attached devices in
        Xcode
      * Android: output to the LogCat window in Android Debug Monitor }
    class procedure ResetLogProc; static;

    { Gets or sets the log level.
      Only messages with a level greater than or equal to this level will get
      logged. For example, if you set to level to TLogLevel.Warning, then
      only Warning, Error and Critical messages will get logged.

      Defaults to TLogLevel.Debug in DEBUG mode and TLogLevel.Error in
      RELEASE mode. }
    class property Level: TLogLevel read FLevel write FLevel;

    { The log procedure to call for each log message.
      Defaults to a default logging procedure but can be set to a custom logging
      procedure. Use ResetLogProc to reset output to the default logging
      procedure. }
    class property LogProc: TLogProc read FLogProc write FLogProc;
  end;

implementation

uses
  {$IF Defined(MSWINDOWS)}
  Winapi.Windows,
  {$ELSEIF Defined(IOS)}
  iOSapi.Foundation,
  {$ELSEIF Defined(MACOS)}
  Macapi.Foundation,
  {$ELSEIF Defined(ANDROID)}
  Androidapi.Log,
  {$ENDIF}
  System.SysUtils;

{$IF Defined(MSWINDOWS)}
procedure DefaultLogProc(const AMessage: String; const ALevel: TLogLevel);
var
  Msg: String;
begin
  Msg := ALevel.Prefix + AMessage;
  if (IsConsole) then
    WriteLn(Msg)
  else
    OutputDebugString(PChar(Msg));
end;
{$ELSEIF Defined(MACOS)}
procedure DefaultLogProc(const AMessage: String; const ALevel: TLogLevel);
var
  Msg: String;
begin
  Msg := ALevel.Prefix + AMessage;
  if (IsConsole) then
    WriteLn(Msg)
  else
    NSLog(TNSString.OCClass.stringWithCharacters(PChar(Msg), Length(Msg)));
end;
{$ELSEIF Defined(ANDROID)}
procedure DefaultLogProc(const AMessage: String; const ALevel: TLogLevel);
const
  LEVELS: array [TLogLevel] of android_LogPriority = (
    ANDROID_LOG_VERBOSE, ANDROID_LOG_DEBUG, ANDROID_LOG_INFO, ANDROID_LOG_WARN,
    ANDROID_LOG_ERROR, ANDROID_LOG_FATAL);
const
  TAGS: array [TLogLevel] of MarshaledAString = (
    'verbose', 'debug', 'info', 'warn', 'error', 'fatal');
begin
  __android_log_write(LEVELS[ALevel], TAGS[ALevel],
    MarshaledAString(UTF8String(AMessage)));
end;
{$ELSE}
procedure DefaultLogProc(const AMessage: String; const ALevel: TLogLevel);
begin
  if (IsConsole) then
    WriteLn(ALevel.Prefix + AMessage);
end;
{$ENDIF}

{ _LogLevelHelper }

function _LogLevelHelper.Prefix: String;
begin
  Result := PREFIXES[Self];
end;

function _LogLevelHelper.ToString: String;
begin
  Result := TO_STRING[Self];
end;

{ TLog }

class constructor TLog.Create;
begin
  {$IFDEF DEBUG}
  FLevel := TLogLevel.Debug;
  {$ELSE}
  FLevel := TLogLevel.Error;
  {$ENDIF}
end;

class procedure TLog.Critical(const AMessage: String);
begin
  Log(TLogLevel.Critical, AMessage);
end;

class procedure TLog.Critical(const AMessage: String;
  const AArgs: array of const);
begin
  Log(TLogLevel.Critical, Format(AMessage, AArgs));
end;

class procedure TLog.Debug(const AMessage: String);
begin
  Log(TLogLevel.Debug, AMessage);
end;

class procedure TLog.Debug(const AMessage: String;
  const AArgs: array of const);
begin
  Log(TLogLevel.Debug, Format(AMessage, AArgs));
end;

class procedure TLog.Error(const AMessage: String);
begin
  Log(TLogLevel.Error, AMessage);
end;

class procedure TLog.Error(const AMessage: String;
  const AArgs: array of const);
begin
  Log(TLogLevel.Error, Format(AMessage, AArgs));
end;

class procedure TLog.Info(const AMessage: String);
begin
  Log(TLogLevel.Info, AMessage);
end;

class procedure TLog.Info(const AMessage: String;
  const AArgs: array of const);
begin
  Log(TLogLevel.Info, Format(AMessage, AArgs));
end;

class procedure TLog.Log(const ALevel: TLogLevel; const AMessage: String;
  const AArgs: array of const);
begin
  Log(ALevel, Format(AMessage, AArgs));
end;

class procedure TLog.Log(const ALevel: TLogLevel; const AMessage: String);
begin
  if (Assigned(FLogProc)) and (ALevel >= FLevel) then
    FLogProc(AMessage, ALevel);
end;

class procedure TLog.ResetLogProc;
begin
  FLogProc := DefaultLogProc;
end;

class procedure TLog.Verbose(const AMessage: String);
begin
  Log(TLogLevel.Verbose, AMessage);
end;

class procedure TLog.Verbose(const AMessage: String;
  const AArgs: array of const);
begin
  Log(TLogLevel.Verbose, Format(AMessage, AArgs));
end;

class procedure TLog.Warning(const AMessage: String);
begin
  Log(TLogLevel.Warning, AMessage);
end;

class procedure TLog.Warning(const AMessage: String;
  const AArgs: array of const);
begin
  Log(TLogLevel.Warning, Format(AMessage, AArgs));
end;

initialization
  TLog.ResetLogProc;

end.
