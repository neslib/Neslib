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

type
  { An atomic value. Can be read, written or updated atomically.
    Modeled after std::atomic<>, supporting only relaxed memory ordering.

    Only works with basic types that are 1, 2, 4 or 8 bytes in size (eg.
    all integer types, Boolean, Char, Single, Double, TPoint etc.).
    Uses assertions to check this.

    For better performance, use one of the specialized version (like
    TAtomicInteger) instead of this generic version. }
  TAtomic<T: record> = record
  {$REGION 'Internal Declarations'}
  private
    [volatile] FValue: T;
  {$ENDREGION 'Internal Declarations'}
  public
    { Creates an atomic value }
    constructor Create(const AValue: T);

    { Atomically loads and returns the value.

      On some platforms, this requires that this value is properly aligned (eg.
      a TAtomic<Integer> should be aligned on a 4-byte boundary). When using
      atomic values as fields in a class, Delphi will automatically align them
      properly. }
    function Load: T; inline;

    { Atomically replaces the current value with the given new value.

      On some platforms, this requires that this value is properly aligned (eg.
      a TAtomic<Integer> should be aligned on a 4-byte boundary). When using
      atomic values as fields in a class, Delphi will automatically align them
      properly. }
    procedure Store(const ANewValue: T); inline;

    { Atomically replaces the current value with the given new value, and
      returns the original value. }
    function Exchange(const ANewValue: T): T; inline;

    { Compares this value to AExpected and, only if they are the same, sets
      this value to ANewValue. Always returns the original value.

      If the ASucceeded parameter is given, it will be set to True if the new
      value was set (even if ANewValue is the same as the current value). }
    function CompareExchange(const ANewValue, AExpected: T): T; overload; inline;
    function CompareExchange(const ANewValue, AExpected: T;
      out ASucceeded: Boolean): T; overload; inline;

    { Atomically increments the value (with an optional AIncrement) and returns
      the new value.

      Only meaningful when T is an integral type. Results will be undefined (and
      may lead to crashes) if this is not the case). }
    function Increment: T; overload; inline;
    function Increment(const AIncrement: T): T; overload; inline;

    { Atomically decrements the value (with an optional ADecrement) and returns
      the new value.

      Only meaningful when T is an integral type. Results will be undefined (and
      may lead to crashes) if this is not the case). }
    function Decrement: T; overload; inline;
    function Decrement(const ADecrement: T): T; overload; inline;
  end;

type
  { Specialized version of TAtomic<Integer>, providing better performance.
    (although using the Atomic* intrinsics is still faster). }
  TAtomicInteger = record
  {$REGION 'Internal Declarations'}
  private
    FValue: Integer;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AValue: Integer);

    function Load: Integer; inline;
    procedure Store(const ANewValue: Integer); inline;

    function Exchange(const ANewValue: Integer): Integer; inline;

    function CompareExchange(const ANewValue, AExpected: Integer): Integer; overload; inline;
    function CompareExchange(const ANewValue, AExpected: Integer;
      out ASucceeded: Boolean): Integer; overload; inline;

    function Increment: Integer; overload; inline;
    function Increment(const AIncrement: Integer): Integer; overload; inline;

    function Decrement: Integer; overload; inline;
    function Decrement(const ADecrement: Integer): Integer; overload; inline;
  end;

type
  { Specialized version of TAtomic<Int64>, providing better performance.
    (although using the Atomic* intrinsics is still faster). }
  TAtomicInt64 = record
  {$REGION 'Internal Declarations'}
  private
    FValue: Int64;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AValue: Int64);

    function Load: Int64; inline;
    procedure Store(const ANewValue: Int64); inline;

    function Exchange(const ANewValue: Int64): Int64; inline;

    function CompareExchange(const ANewValue, AExpected: Int64): Int64; overload; inline;
    function CompareExchange(const ANewValue, AExpected: Int64;
      out ASucceeded: Boolean): Int64; overload; inline;

    function Increment: Int64; overload; inline;
    function Increment(const AIncrement: Int64): Int64; overload; inline;

    function Decrement: Int64; overload; inline;
    function Decrement(const ADecrement: Int64): Int64; overload; inline;
  end;

type
  { Specialized version of TAtomic<NativeInt>, providing better performance
    (although using the Atomic* intrinsics is still faster). }
  TAtomicNativeInt = record
  {$REGION 'Internal Declarations'}
  private
    FValue: NativeInt;
  {$ENDREGION 'Internal Declarations'}
  public
    constructor Create(const AValue: NativeInt);

    function Load: NativeInt; inline;
    procedure Store(const ANewValue: NativeInt); inline;

    function Exchange(const ANewValue: NativeInt): NativeInt; inline;

    function CompareExchange(const ANewValue, AExpected: NativeInt): NativeInt; overload; inline;
    function CompareExchange(const ANewValue, AExpected: NativeInt;
      out ASucceeded: Boolean): NativeInt; overload; inline;

    function Increment: NativeInt; overload; inline;
    function Increment(const AIncrement: NativeInt): NativeInt; overload; inline;

    function Decrement: NativeInt; overload; inline;
    function Decrement(const ADecrement: NativeInt): NativeInt; overload; inline;
  end;

{ Allocates memory aligned to a certain boundary.

  Parameters:
    APtr: the memory pointer to allocate
    ASize: the number of bytes to allocate
    AAlign: the alignment (eg. use 16 to align on a 16-byte boundary).
      Must be >= 8 and a power of 2.

  Do @bold(not) use FreeMem to free the memory. You @bold(must) use
  FreeMemAligned instead. }
procedure GetMemAligned(out APtr; const ASize, AAlign: NativeInt);

{ Allocates memory aligned to a Level 1 cache line (which is currently assumed
  to be 64 bytes on all platforms).

  Parameters:
    APtr: the memory pointer to allocate
    ASize: the number of bytes to allocate

  Do @bold(not) use FreeMem to free the memory. You @bold(must) use
  FreeMemAligned instead. }
procedure GetMemL1Aligned(out APtr; const ASize: NativeInt); inline;

{ Frees memory previously allocated with GetMemAligned or GetMemL1Aligned.

  Parameters:
    APtr: the memory pointer to deallocate }
procedure FreeMemAligned(const APtr: Pointer);

resourcestring
  RS_NULLABLE_ERROR = 'Illegal access of nullable value wity value null';

implementation

uses
  System.Classes,
  System.SysUtils;

procedure GetMemAligned(out APtr; const ASize, AAlign: NativeInt);
var
  Orig: Pointer;
  Aligned: IntPtr absolute APtr;
  BytesShifted: Integer;
begin
  Assert(AAlign >= 8);
  Assert((AAlign and (AAlign - 1)) = 0);

  { Allocate AAlign extra bytes of memory. These extra bytes are used to move
    the pointer to an aligned address, AND to store the number of bytes shifted,
    so we can retrieve the original pointer later when freeing it. }
  GetMem(Orig, ASize + AAlign);

  { Move pointer to next multiple of AAlign. If pointer is already aligned, then
    it is moved AAlign bytes ahead (so we always have some extra room before the
    pointer. }
  Aligned := (IntPtr(Orig) and not (AAlign - 1)) + AAlign;

  { Store shift value before the pointer }
  BytesShifted := Aligned - IntPtr(Orig);
  PInteger(Aligned - 4)^ := BytesShifted;
end;

procedure GetMemL1Aligned(out APtr; const ASize: NativeInt);
begin
  GetMemAligned(APtr, ASize, 64);
end;

procedure FreeMemAligned(const APtr: Pointer);
var
  BytesShifted: Integer;
  Orig: Pointer;
begin
  if (APtr = nil) then
    Exit;

  { Retrieve shift value }
  BytesShifted := PInteger(IntPtr(APtr) - 4)^;

  { Get original pointer }
  Orig := Pointer(IntPtr(APtr) - BytesShifted);

  { Free original pointer }
  FreeMem(Orig);
end;

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

{ TAtomic<T> }

function TAtomic<T>.CompareExchange(const ANewValue, AExpected: T): T;
{ Note that the "if" statements are evaluated at compile time, so they do not
  affect runtime performance }
var
  V8: Byte absolute ANewValue;
  V16: Word absolute ANewValue;
  V32: Cardinal absolute ANewValue;
  V64: UInt64 absolute ANewValue;
  E8: Byte absolute AExpected;
  E16: Word absolute AExpected;
  E32: Cardinal absolute AExpected;
  E64: UInt64 absolute AExpected;
  R8: Byte absolute Result;
  R16: Word absolute Result;
  R32: Cardinal absolute Result;
  R64: UInt64 absolute Result;
begin
  if (SizeOf(T) = 1) then
    R8 := AtomicCmpExchange(PByte(@FValue)^, V8, E8)
  else if (SizeOf(T) = 2) then
    R16 := AtomicCmpExchange(PWord(@FValue)^, V16, E16)
  else if (SizeOf(T) = 4) then
    R32 := AtomicCmpExchange(PCardinal(@FValue)^, V32, E32)
  else if (SizeOf(T) = 8) then
    R64 := AtomicCmpExchange(PUInt64(@FValue)^, V64, E64)
  else
    Assert(False);
end;

function TAtomic<T>.CompareExchange(const ANewValue, AExpected: T;
  out ASucceeded: Boolean): T;
{ Note that the "if" statements are evaluated at compile time, so they do not
  affect runtime performance }
var
  V8: Byte absolute ANewValue;
  V16: Word absolute ANewValue;
  V32: Cardinal absolute ANewValue;
  V64: UInt64 absolute ANewValue;
  E8: Byte absolute AExpected;
  E16: Word absolute AExpected;
  E32: Cardinal absolute AExpected;
  E64: UInt64 absolute AExpected;
  R8: Byte absolute Result;
  R16: Word absolute Result;
  R32: Cardinal absolute Result;
  R64: UInt64 absolute Result;
begin
  if (SizeOf(T) = 1) then
    R8 := AtomicCmpExchange(PByte(@FValue)^, V8, E8, ASucceeded)
  else if (SizeOf(T) = 2) then
    R16 := AtomicCmpExchange(PWord(@FValue)^, V16, E16, ASucceeded)
  else if (SizeOf(T) = 4) then
    R32 := AtomicCmpExchange(PCardinal(@FValue)^, V32, E32, ASucceeded)
  else if (SizeOf(T) = 8) then
    R64 := AtomicCmpExchange(PUInt64(@FValue)^, V64, E64, ASucceeded)
  else
    Assert(False);
end;

constructor TAtomic<T>.Create(const AValue: T);
begin
  FValue := AValue;
end;

function TAtomic<T>.Decrement(const ADecrement: T): T;
{ Note that the "if" statements are evaluated at compile time, so they do not
  affect runtime performance }
var
  V8: Byte absolute ADecrement;
  V16: Word absolute ADecrement;
  V32: Cardinal absolute ADecrement;
  V64: UInt64 absolute ADecrement;
  R8: Byte absolute Result;
  R16: Word absolute Result;
  R32: Cardinal absolute Result;
  R64: UInt64 absolute Result;
begin
  if (SizeOf(T) = 1) then
    R8 := AtomicDecrement(PByte(@FValue)^, V8)
  else if (SizeOf(T) = 2) then
    R16 := AtomicDecrement(PWord(@FValue)^, V16)
  else if (SizeOf(T) = 4) then
    R32 := AtomicDecrement(PCardinal(@FValue)^, V32)
  else if (SizeOf(T) = 8) then
    R64 := AtomicDecrement(PUInt64(@FValue)^, V64)
  else
    Assert(False);
end;

function TAtomic<T>.Decrement: T;
{ Note that the "if" statements are evaluated at compile time, so they do not
  affect runtime performance }
var
  R8: Byte absolute Result;
  R16: Word absolute Result;
  R32: Cardinal absolute Result;
  R64: UInt64 absolute Result;
begin
  if (SizeOf(T) = 1) then
    R8 := AtomicDecrement(PByte(@FValue)^)
  else if (SizeOf(T) = 2) then
    R16 := AtomicDecrement(PWord(@FValue)^)
  else if (SizeOf(T) = 4) then
    R32 := AtomicDecrement(PCardinal(@FValue)^)
  else if (SizeOf(T) = 8) then
    R64 := AtomicDecrement(PUInt64(@FValue)^)
  else
    Assert(False);
end;

function TAtomic<T>.Exchange(const ANewValue: T): T;
{ Note that the "if" statements are evaluated at compile time, so they do not
  affect runtime performance }
var
  V8: Byte absolute ANewValue;
  V16: Word absolute ANewValue;
  V32: Cardinal absolute ANewValue;
  V64: UInt64 absolute ANewValue;
  R8: Byte absolute Result;
  R16: Word absolute Result;
  R32: Cardinal absolute Result;
  R64: UInt64 absolute Result;
begin
  if (SizeOf(T) = 1) then
    R8 := AtomicExchange(PByte(@FValue)^, V8)
  else if (SizeOf(T) = 2) then
    R16 := AtomicExchange(PWord(@FValue)^, V16)
  else if (SizeOf(T) = 4) then
    R32 := AtomicExchange(PCardinal(@FValue)^, V32)
  else if (SizeOf(T) = 8) then
    R64 := AtomicExchange(PUInt64(@FValue)^, V64)
  else
    Assert(False);
end;

function TAtomic<T>.Increment(const AIncrement: T): T;
{ Note that the "if" statements are evaluated at compile time, so they do not
  affect runtime performance }
var
  V8: Byte absolute AIncrement;
  V16: Word absolute AIncrement;
  V32: Cardinal absolute AIncrement;
  V64: UInt64 absolute AIncrement;
  R8: Byte absolute Result;
  R16: Word absolute Result;
  R32: Cardinal absolute Result;
  R64: UInt64 absolute Result;
begin
  if (SizeOf(T) = 1) then
    R8 := AtomicIncrement(PByte(@FValue)^, V8)
  else if (SizeOf(T) = 2) then
    R16 := AtomicIncrement(PWord(@FValue)^, V16)
  else if (SizeOf(T) = 4) then
    R32 := AtomicIncrement(PCardinal(@FValue)^, V32)
  else if (SizeOf(T) = 8) then
    R64 := AtomicIncrement(PUInt64(@FValue)^, V64)
  else
    Assert(False);
end;

function TAtomic<T>.Increment: T;
{ Note that the "if" statements are evaluated at compile time, so they do not
  affect runtime performance }
var
  R8: Byte absolute Result;
  R16: Word absolute Result;
  R32: Cardinal absolute Result;
  R64: UInt64 absolute Result;
begin
  if (SizeOf(T) = 1) then
    R8 := AtomicIncrement(PByte(@FValue)^)
  else if (SizeOf(T) = 2) then
    R16 := AtomicIncrement(PWord(@FValue)^)
  else if (SizeOf(T) = 4) then
    R32 := AtomicIncrement(PCardinal(@FValue)^)
  else if (SizeOf(T) = 8) then
    R64 := AtomicIncrement(PUInt64(@FValue)^)
  else
    Assert(False);
end;

function TAtomic<T>.Load: T;
{ On Intel platforms, CPU loads are guaranteed to be atomic if the value
  is properly aligned.
  Note that the "if" statements are evaluated at compile time, so they do not
  affect runtime performance }
var
  R8: Byte absolute Result;
  R16: Word absolute Result;
  R32: Cardinal absolute Result;
  R64: UInt64 absolute Result;
begin
  {$IF Defined(CPUX86)}
  if (SizeOf(T) = 1) then
    R8 := PByte(@FValue)^
  else if (SizeOf(T) = 2) then
  begin
    Assert((UIntPtr(@FValue) and 1) = 0);
    R16 := PWord(@FValue)^;
  end
  else if (SizeOf(T) = 4) then
  begin
    Assert((UIntPtr(@FValue) and 3) = 0);
    R32 := PCardinal(@FValue)^;
  end
  else if (SizeOf(T) = 8) then
    R64 := AtomicCmpExchange(PUInt64(@FValue)^, 0, 0)
  else
    Assert(False);
  {$ELSEIF Defined(CPUX64)}
  if (SizeOf(T) = 1) then
    R8 := PByte(@FValue)^
  else if (SizeOf(T) = 2) then
  begin
    Assert((UIntPtr(@FValue) and 1) = 0);
    R16 := PWord(@FValue)^;
  end
  else if (SizeOf(T) = 4) then
  begin
    Assert((UIntPtr(@FValue) and 3) = 0);
    R32 := PCardinal(@FValue)^;
  end
  else if (SizeOf(T) = 8) then
  begin
    Assert((UIntPtr(@FValue) and 7) = 0);
    R64 := PUInt64(@FValue)^;
  end
  else
    Assert(False);
  {$ELSE}
  if (SizeOf(T) = 1) then
    R8 := AtomicCmpExchange(PByte(@FValue)^, 0, 0)
  else if (SizeOf(T) = 2) then
    R16 := AtomicCmpExchange(PWord(@FValue)^, 0, 0)
  else if (SizeOf(T) = 4) then
    R32 := AtomicCmpExchange(PCardinal(@FValue)^, 0, 0)
  else if (SizeOf(T) = 8) then
    R64 := AtomicCmpExchange(PUInt64(@FValue)^, 0, 0)
  else
    Assert(False);
  {$ENDIF}
end;

procedure TAtomic<T>.Store(const ANewValue: T);
{ On Intel platforms, CPU stored are guaranteed to be atomic if the value
  is properly aligned.
  Note that the "if" statements are evaluated at compile time, so they do not
  affect runtime performance }
var
  V8: Byte absolute ANewValue;
  V16: Word absolute ANewValue;
  V32: Cardinal absolute ANewValue;
  V64: UInt64 absolute ANewValue;
begin
  {$IF Defined(CPUX86)}
  if (SizeOf(T) = 1) then
    PByte(@FValue)^ := V8
  else if (SizeOf(T) = 2) then
  begin
    Assert((UIntPtr(@FValue) and 1) = 0);
    PWord(@FValue)^ := V16;
  end
  else if (SizeOf(T) = 4) then
  begin
    Assert((UIntPtr(@FValue) and 3) = 0);
    PCardinal(@FValue)^ := V32;
  end
  else if (SizeOf(T) = 8) then
    AtomicExchange(PUInt64(@FValue)^, V64)
  else
    Assert(False);
  {$ELSEIF Defined(CPUX64)}
  if (SizeOf(T) = 1) then
    PByte(@FValue)^ := V8
  else if (SizeOf(T) = 2) then
  begin
    Assert((UIntPtr(@FValue) and 1) = 0);
    PWord(@FValue)^ := V16;
  end
  else if (SizeOf(T) = 4) then
  begin
    Assert((UIntPtr(@FValue) and 3) = 0);
    PCardinal(@FValue)^ := V32;
  end
  else if (SizeOf(T) = 8) then
  begin
    Assert((UIntPtr(@FValue) and 7) = 0);
    PUInt64(@FValue)^ := V64;
  end
  else
    Assert(False);
  {$ELSE}
  if (SizeOf(T) = 1) then
    AtomicExchange(PByte(@FValue)^, V8)
  else if (SizeOf(T) = 2) then
    AtomicExchange(PWord(@FValue)^, V16)
  else if (SizeOf(T) = 4) then
    AtomicExchange(PCardinal(@FValue)^, V32)
  else if (SizeOf(T) = 8) then
    AtomicExchange(PUInt64(@FValue)^, V64)
  else
    Assert(False);
  {$ENDIF}
end;

{ TAtomicInteger }

function TAtomicInteger.CompareExchange(const ANewValue,
  AExpected: Integer): Integer;
begin
  Result := AtomicCmpExchange(FValue, ANewValue, AExpected);
end;

function TAtomicInteger.CompareExchange(const ANewValue, AExpected: Integer;
  out ASucceeded: Boolean): Integer;
begin
  Result := AtomicCmpExchange(FValue, ANewValue, AExpected, ASucceeded);
end;

constructor TAtomicInteger.Create(const AValue: Integer);
begin
  FValue := AValue;
end;

function TAtomicInteger.Decrement(const ADecrement: Integer): Integer;
begin
  Result := AtomicDecrement(FValue, ADecrement);
end;

function TAtomicInteger.Decrement: Integer;
begin
  Result := AtomicDecrement(FValue);
end;

function TAtomicInteger.Exchange(const ANewValue: Integer): Integer;
begin
  Result := AtomicExchange(FValue, ANewValue);
end;

function TAtomicInteger.Increment(const AIncrement: Integer): Integer;
begin
  Result := AtomicIncrement(FValue, AIncrement);
end;

function TAtomicInteger.Increment: Integer;
begin
  Result := AtomicIncrement(FValue);
end;

function TAtomicInteger.Load: Integer;
{ On Intel platforms, CPU loads are guaranteed to be atomic if the value
  is properly aligned. }
begin
  {$IF Defined(CPUX86) or Defined(CPUX64)}
  Result := FValue;
  {$ELSE}
  Result := AtomicCmpExchange(FValue, 0, 0);
  {$ENDIF}
end;

procedure TAtomicInteger.Store(const ANewValue: Integer);
{ On Intel platforms, CPU stored are guaranteed to be atomic if the value
  is properly aligned. }
begin
  {$IF Defined(CPUX86) or Defined(CPUX64)}
  FValue := ANewValue;
  {$ELSE}
  AtomicExchange(FValue, ANewValue);
  {$ENDIF}
end;

{ TAtomicInt64 }

function TAtomicInt64.CompareExchange(const ANewValue,
  AExpected: Int64): Int64;
begin
  Result := AtomicCmpExchange(FValue, ANewValue, AExpected);
end;

function TAtomicInt64.CompareExchange(const ANewValue, AExpected: Int64;
  out ASucceeded: Boolean): Int64;
begin
  Result := AtomicCmpExchange(FValue, ANewValue, AExpected, ASucceeded);
end;

constructor TAtomicInt64.Create(const AValue: Int64);
begin
  FValue := AValue;
end;

function TAtomicInt64.Decrement(const ADecrement: Int64): Int64;
begin
  Result := AtomicDecrement(FValue, ADecrement);
end;

function TAtomicInt64.Decrement: Int64;
begin
  Result := AtomicDecrement(FValue);
end;

function TAtomicInt64.Exchange(const ANewValue: Int64): Int64;
begin
  Result := AtomicExchange(FValue, ANewValue);
end;

function TAtomicInt64.Increment(const AIncrement: Int64): Int64;
begin
  Result := AtomicIncrement(FValue, AIncrement);
end;

function TAtomicInt64.Increment: Int64;
begin
  Result := AtomicIncrement(FValue);
end;

function TAtomicInt64.Load: Int64;
{ On Intel platforms, CPU loads are guaranteed to be atomic if the value
  is properly aligned. }
begin
  {$IF Defined(CPUX64)}
  Result := FValue;
  {$ELSE}
  Result := AtomicCmpExchange(FValue, 0, 0);
  {$ENDIF}
end;

procedure TAtomicInt64.Store(const ANewValue: Int64);
{ On Intel platforms, CPU stored are guaranteed to be atomic if the value
  is properly aligned. }
begin
  {$IF Defined(CPUX64)}
  FValue := ANewValue;
  {$ELSE}
  AtomicExchange(FValue, ANewValue);
  {$ENDIF}
end;

{ TAtomicNativeInt }

function TAtomicNativeInt.CompareExchange(const ANewValue,
  AExpected: NativeInt): NativeInt;
begin
  Result := AtomicCmpExchange(FValue, ANewValue, AExpected);
end;

function TAtomicNativeInt.CompareExchange(const ANewValue,
  AExpected: NativeInt; out ASucceeded: Boolean): NativeInt;
begin
  Result := AtomicCmpExchange(FValue, ANewValue, AExpected, ASucceeded);
end;

constructor TAtomicNativeInt.Create(const AValue: NativeInt);
begin
  FValue := AValue;
end;

function TAtomicNativeInt.Decrement(const ADecrement: NativeInt): NativeInt;
begin
  Result := AtomicDecrement(FValue, ADecrement);
end;

function TAtomicNativeInt.Decrement: NativeInt;
begin
  Result := AtomicDecrement(FValue);
end;

function TAtomicNativeInt.Exchange(const ANewValue: NativeInt): NativeInt;
begin
  Result := AtomicExchange(FValue, ANewValue);
end;

function TAtomicNativeInt.Increment(const AIncrement: NativeInt): NativeInt;
begin
  Result := AtomicIncrement(FValue, AIncrement);
end;

function TAtomicNativeInt.Increment: NativeInt;
begin
  Result := AtomicIncrement(FValue);
end;

function TAtomicNativeInt.Load: NativeInt;
{ On Intel platforms, CPU loads are guaranteed to be atomic if the value
  is properly aligned. }
begin
  {$IF Defined(CPUX86) or Defined(CPUX64)}
  Result := FValue;
  {$ELSE}
  Result := AtomicCmpExchange(FValue, 0, 0);
  {$ENDIF}
end;

procedure TAtomicNativeInt.Store(const ANewValue: NativeInt);
begin
  {$IF Defined(CPUX86) or Defined(CPUX64)}
  FValue := ANewValue;
  {$ELSE}
  AtomicExchange(FValue, ANewValue);
  {$ENDIF}
end;

end.
