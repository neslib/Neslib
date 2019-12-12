unit Neslib.SysUtils;
{< Sytem utilities }

{$INCLUDE 'Neslib.inc'}

interface

uses
  System.SysUtils;

{ Checks two string references for equality.

  Parameters:
    AString1: first string
    AString2: second string

  Returns:
    True if AString1 and AString2 are references to the same string.

  This function is useful with string interning to quickly check two interned
  strings for equality. Instead of comparing the contents of the two strings,
  it just checks their references, which is just a single pointer comparison.

  See Neslib.Collections.TStringInternPool for a class you can use for string
  interning. }
function SameStringRef(const AString1, AString2: String): Boolean; overload; inline;
function SameStringRef(const AString1, AString2: UTF8String): Boolean; overload; inline;

var
  { A TFormatSettings record configured for US number settings.
    It uses a period (.) as a decimal separator and comma (,) as thousands
    separator.
    Can be used to convert strings to floating-point values in cases where the
    strings are always formatted to use periods as decimal separators
    (regardless of locale). }
  USFormatSettings: TFormatSettings;

implementation

function SameStringRef(const AString1, AString2: String): Boolean;
begin
  Result := (Pointer(AString1) = Pointer(AString2));
end;

function SameStringRef(const AString1, AString2: UTF8String): Boolean;
begin
  Result := (Pointer(AString1) = Pointer(AString2));
end;

initialization
  USFormatSettings := TFormatSettings.Create('en-US');
  USFormatSettings.DecimalSeparator := '.';
  USFormatSettings.ThousandSeparator := ',';

end.
