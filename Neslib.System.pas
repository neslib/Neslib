unit Neslib.System;
{< System utilities }

{$INCLUDE 'Neslib.inc'}

interface

type
  { Base class for classes that can implement interfaces without reference
    counting. }
  TNonRefCountedObject = class
  {$REGION 'Internal Declarations'}
  protected
    { Prepare for interface implementations }
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function _AddRef: Integer; virtual; stdcall;
    function _Release: Integer; virtual; stdcall;
  {$ENDREGION 'Internal Declarations'}
  end;

type
  { Represents a value type that can be assigned @bold(null) }
  Nullable<T: record> = record
  {$REGION 'Internal Declarations'}
  private
    FValue: T;
    FHasValue: Boolean;
  private
    function GetValue: T; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates a nullable with a given value.

      Parameters:
        AValue: the value to set the nullable to.

      This will also set HasValue to True }
    constructor Create(const AValue: T);

    { Creates a nullable with value null }
    class function CreateNull: Nullable<T>; inline; static;

    { Sets the value to null }
    procedure SetNull; inline;

    { Explicitly converts from a nullable to its underlying value.
      Raises an EInvalidOperation if HasValue is False. }
    class operator Explicit(const AValue: Nullable<T>): T; inline; static;

    { Implicitly converts from a value to a nullable. This sets the HasValue of
      the nullable to True. }
    class operator Implicit(const AValue: T): Nullable<T>; inline; static;

    { Compares two nullables for equality. }
    class operator Equal(const ALeft, ARight: Nullable<T>): Boolean;

    { Compares two nullables for equality. }
    class operator NotEqual(const ALeft, ARight: Nullable<T>): Boolean;

    { Gets the value, or the default value in case HasValue is False. }
    function GetValueOrDefault: T; inline;

    { The value, if it has been assigned a valid underlying value.
      Raises an EInvalidOperation if HasValue is False. }
    property Value: T read GetValue;

    { A value indicating whether this nullable has a valid value of its
      underlying type.  }
    property HasValue: Boolean read FHasValue;
  end;

type
  { Represents a 2-tuple, or pair }
  TTuple<T1, T2> = record
  public
    { The first item }
    Item1: T1;

    { The second item }
    Item2: T2;
  public
    constructor Create(const AItem1: T1; const AItem2: T2);
  end;

type
  { Represents a 3-tuple, or triple }
  TTuple<T1, T2, T3> = record
  public
    { The first item }
    Item1: T1;

    { The second item }
    Item2: T2;

    { The third item }
    Item3: T3;
  public
    constructor Create(const AItem1: T1; const AItem2: T2; const AItem3: T3);
  end;

type
  { Represents a 4-tuple, or quadruple }
  TTuple<T1, T2, T3, T4> = record
  public
    { The first item }
    Item1: T1;

    { The second item }
    Item2: T2;

    { The third item }
    Item3: T3;

    { The fourth item }
    Item4: T4;
  public
    constructor Create(const AItem1: T1; const AItem2: T2; const AItem3: T3;
      const AItem4: T4);
  end;

resourcestring
  RS_NULLABLE_ERROR = 'Illegal access of nullable value wity value null';

implementation

uses
  System.Classes,
  System.SysUtils;

{ TNonRefCountedObject }

function TNonRefCountedObject.QueryInterface(const IID: TGUID;
  out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TNonRefCountedObject._AddRef: Integer;
begin
  Result := -1;
end;

function TNonRefCountedObject._Release: Integer;
begin
  Result := -1;
end;

{ Nullable<T> }

constructor Nullable<T>.Create(const AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

class function Nullable<T>.CreateNull: Nullable<T>;
begin
  Result.SetNull;
end;

class operator Nullable<T>.Equal(const ALeft,
  ARight: Nullable<T>): Boolean;
begin
  Result := (ALeft.FHasValue = ARight.FHasValue);
  if (Result) and (ALeft.FHasValue) then
    Result := CompareMem(@ALeft.FValue, @ARight.FValue, SizeOf(T));
end;

class operator Nullable<T>.Explicit(const AValue: Nullable<T>): T;
begin
  Result := AValue.Value;
end;

function Nullable<T>.GetValue: T;
begin
  if (not FHasValue) then
    raise EInvalidOperation.CreateRes(@RS_NULLABLE_ERROR);
  Result := FValue;
end;

function Nullable<T>.GetValueOrDefault: T;
begin
  if (FHasValue) then
    Result := FValue
  else
    Result := Default(T);
end;

class operator Nullable<T>.Implicit(const AValue: T): Nullable<T>;
begin
  Result := Nullable<T>.Create(AValue);
end;

class operator Nullable<T>.NotEqual(const ALeft,
  ARight: Nullable<T>): Boolean;
begin
  Result := not (ALeft = ARight);
end;

procedure Nullable<T>.SetNull;
begin
  FValue := Default(T);
  FHasValue := False;
end;

{ TTuple<T1, T2> }

constructor TTuple<T1, T2>.Create(const AItem1: T1; const AItem2: T2);
begin
  Item1 := AItem1;
  Item2 := AItem2;
end;

{ TTuple<T1, T2, T3> }

constructor TTuple<T1, T2, T3>.Create(const AItem1: T1; const AItem2: T2;
  const AItem3: T3);
begin
  Item1 := AItem1;
  Item2 := AItem2;
  Item3 := AItem3;
end;

{ TTuple<T1, T2, T3, T4> }

constructor TTuple<T1, T2, T3, T4>.Create(const AItem1: T1; const AItem2: T2;
  const AItem3: T3; const AItem4: T4);
begin
  Item1 := AItem1;
  Item2 := AItem2;
  Item3 := AItem3;
  Item4 := AItem4;
end;

end.
