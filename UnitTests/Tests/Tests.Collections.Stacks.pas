unit Tests.Collections.Stacks;

interface

uses
  DUnitX.TestFramework,
  Tests.Collections.Base,
  Neslib.Collections;

type
  TTestStack<T> = class(TTestCollectionBase<T>)
  private
    FCUT: TStack<T>;
    FValues: TArray<T>;
    procedure FillStack;
    procedure CheckItems(const AExpected: TArray<T>);
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestPush;
    [Test] procedure TestPop;
    [Test] procedure TestPeek;
    [Test] procedure TestClear;
    [Test] procedure TestToArray;
    [Test] procedure TestGetEnumerator;
    [Test] procedure TestGetCapacityAndCount;
    [Test] procedure TestTrimExcess;
  end;

type
  TTestTgrObjectStack = class(TTestCollectionBase<TFoo>)
  private
    FCUT: TObjectStack<TFoo>;
    procedure FillStack;
    procedure CheckItems(const AExpected: array of Integer);
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestPush;
    [Test] procedure TestPop;
    [Test] procedure TestExtract;
    [Test] procedure TestPeek;
    [Test] procedure TestClear;
    [Test] procedure TestToArray;
    [Test] procedure TestGetEnumerator;
  end;

implementation

uses
  System.SysUtils;

{ TTestStack<T> }

procedure TTestStack<T>.CheckItems(const AExpected: TArray<T>);
var
  Actual: TArray<T>;
  I: Integer;
begin
  Assert.AreEqual(Length(AExpected), FCUT.Count);
  Actual := FCUT.ToArray;
  Assert.AreEqual(Length(AExpected), Length(Actual));
  for I := 0 to Length(AExpected) - 1 do
    TestEquals(AExpected[I], Actual[I]);
end;

procedure TTestStack<T>.FillStack;
var
  Value: T;
begin
  FValues := CreateValues(3);
  for Value in FValues do
    FCUT.Push(Value);
end;

procedure TTestStack<T>.SetUp;
begin
  inherited;
  FCUT := TStack<T>.Create;
end;

procedure TTestStack<T>.TearDown;
begin
  FCUT.Free;
  inherited;
end;

procedure TTestStack<T>.TestClear;
begin
  FillStack;
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Clear;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestStack<T>.TestGetCapacityAndCount;
var
  Value: T;
begin
  Value := CreateValue(1);

  Assert.AreEqual(0, FCUT.Count);
  Assert.AreEqual(0, FCUT.Capacity);

  FCUT.Push(Value);
  Assert.AreEqual(1, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Push(Value);
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Push(Value);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Push(Value);
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Push(Value);
  Assert.AreEqual(5, FCUT.Count);
  Assert.AreEqual(8, FCUT.Capacity);
end;

procedure TTestStack<T>.TestGetEnumerator;
var
  Value: T;
  I: Integer;
begin
  FillStack;
  I := 0;
  for Value in FCUT do
  begin
    TestEquals(FValues[I], Value);
    Inc(I);
  end;
end;

procedure TTestStack<T>.TestPeek;
var
  Value: T;
begin
  FillStack;
  Assert.AreEqual(3, FCUT.Count);

  Value := FCUT.Peek;
  Assert.AreEqual(3, FCUT.Count);
  TestEquals(FValues[2], Value);
  Value := FCUT.Pop;
  TestEquals(FValues[2], Value);

  Value := FCUT.Peek;
  Assert.AreEqual(2, FCUT.Count);
  TestEquals(FValues[1], Value);
  Value := FCUT.Pop;
  TestEquals(FValues[1], Value);

  Value := FCUT.Peek;
  Assert.AreEqual(1, FCUT.Count);
  TestEquals(FValues[0], Value);
  Value := FCUT.Pop;
  TestEquals(FValues[0], Value);

  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestStack<T>.TestPop;
var
  Value: T;
begin
  FillStack;
  Assert.AreEqual(3, FCUT.Count);

  Value := FCUT.Pop;
  Assert.AreEqual(2, FCUT.Count);
  TestEquals(FValues[2], Value);

  Value := FCUT.Pop;
  Assert.AreEqual(1, FCUT.Count);
  TestEquals(FValues[1], Value);

  Value := FCUT.Pop;
  Assert.AreEqual(0, FCUT.Count);
  TestEquals(FValues[0], Value);
end;

procedure TTestStack<T>.TestPush;
var
  Values: TArray<T>;
begin
  Values := CreateValues(3);
  FCUT.Push(Values[0]);
  Assert.AreEqual(1, FCUT.Count);
  FCUT.Push(Values[1]);
  Assert.AreEqual(2, FCUT.Count);
  FCUT.Push(Values[2]);
  Assert.AreEqual(3, FCUT.Count);
  CheckItems(Values);
end;

procedure TTestStack<T>.TestToArray;
var
  A: TArray<T>;
begin
  FillStack;
  SetLength(A, 3);
  A[0] := FValues[0];
  A[1] := FValues[1];
  A[2] := FValues[2];
  CheckItems(A);
end;

procedure TTestStack<T>.TestTrimExcess;
begin
  FillStack;
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);
  FCUT.TrimExcess;
  Assert.AreEqual(3, FCUT.Capacity);
end;

{ TTestTgrObjectStack }

procedure TTestTgrObjectStack.CheckItems(const AExpected: array of Integer);
var
  Actual: TArray<TFoo>;
  I: Integer;
begin
  Assert.AreEqual(Length(AExpected), FCUT.Count);
  Actual := FCUT.ToArray;
  Assert.AreEqual(Length(AExpected), Length(Actual));
  for I := 0 to Length(AExpected) - 1 do
    Assert.AreEqual(AExpected[I], Actual[I].Value);
end;

procedure TTestTgrObjectStack.FillStack;
var
  I: Integer;
begin
  for I := 0 to 2 do
    FCUT.Push(TFoo.Create(I));
end;

procedure TTestTgrObjectStack.SetUp;
begin
  inherited;
  FCUT := TObjectStack<TFoo>.Create;
end;

procedure TTestTgrObjectStack.TearDown;
begin
  FCUT.Free;
  inherited;
end;

procedure TTestTgrObjectStack.TestClear;
begin
  FillStack;
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Clear;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestTgrObjectStack.TestExtract;
var
  Value: TFoo;
begin
  FillStack;
  Assert.AreEqual(3, FCUT.Count);

  Value := FCUT.Extract;
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual(2, Value.Value);
  Value.Free;

  Value := FCUT.Extract;
  Assert.AreEqual(1, FCUT.Count);
  Assert.AreEqual(1, Value.Value);
  Value.Free;

  Value := FCUT.Extract;
  Assert.AreEqual(0, FCUT.Count);
  Assert.AreEqual(0, Value.Value);
  Value.Free;
end;

procedure TTestTgrObjectStack.TestGetEnumerator;
var
  Value: TFoo;
  I: Integer;
begin
  FillStack;
  I := 0;
  for Value in FCUT do
  begin
    Assert.AreEqual(I, Value.Value);
    Inc(I);
  end;
end;

procedure TTestTgrObjectStack.TestPeek;
var
  Value: TFoo;
begin
  FillStack;
  Assert.AreEqual(3, FCUT.Count);

  Value := FCUT.Peek;
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(2, Value.Value);
  FCUT.Pop;

  Value := FCUT.Peek;
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual(1, Value.Value);
  FCUT.Pop;

  Value := FCUT.Peek;
  Assert.AreEqual(1, FCUT.Count);
  Assert.AreEqual(0, Value.Value);
  FCUT.Pop;

  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestTgrObjectStack.TestPop;
begin
  FillStack;
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Pop;
  Assert.AreEqual(2, FCUT.Count);

  FCUT.Pop;
  Assert.AreEqual(1, FCUT.Count);

  FCUT.Pop;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestTgrObjectStack.TestPush;
var
  I: Integer;
begin
  for I := 0 to 2 do
    FCUT.Push(TFoo.Create(I));
  CheckItems([0, 1, 2]);
end;

procedure TTestTgrObjectStack.TestToArray;
begin
  FillStack;
  CheckItems([0, 1, 2]);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestStack<ShortInt>);
  {$IFNDEF LIMITED_GENERICS}
  TDUnitX.RegisterTestFixture(TTestStack<Byte>);
  TDUnitX.RegisterTestFixture(TTestStack<SmallInt>);
  TDUnitX.RegisterTestFixture(TTestStack<Word>);
  TDUnitX.RegisterTestFixture(TTestStack<Integer>);
  TDUnitX.RegisterTestFixture(TTestStack<Cardinal>);
  TDUnitX.RegisterTestFixture(TTestStack<Boolean>);
  TDUnitX.RegisterTestFixture(TTestStack<TDigit>);
  TDUnitX.RegisterTestFixture(TTestStack<TDigits>);
  TDUnitX.RegisterTestFixture(TTestStack<Single>);
  TDUnitX.RegisterTestFixture(TTestStack<Double>);
  TDUnitX.RegisterTestFixture(TTestStack<Extended>);
  TDUnitX.RegisterTestFixture(TTestStack<Comp>);
  TDUnitX.RegisterTestFixture(TTestStack<Currency>);
  TDUnitX.RegisterTestFixture(TTestStack<TFoo>);
  TDUnitX.RegisterTestFixture(TTestStack<IBaz>);
  TDUnitX.RegisterTestFixture(TTestStack<TFooClass>);
  TDUnitX.RegisterTestFixture(TTestStack<PInteger>);
  TDUnitX.RegisterTestFixture(TTestStack<TTestProc>);
  TDUnitX.RegisterTestFixture(TTestStack<TTestMethod>);
  {$IFNDEF NEXTGEN}
  TDUnitX.RegisterTestFixture(TTestStack<TStr2>);
  TDUnitX.RegisterTestFixture(TTestStack<TStr3>);
  TDUnitX.RegisterTestFixture(TTestStack<ShortString>);
  TDUnitX.RegisterTestFixture(TTestStack<AnsiString>);
  TDUnitX.RegisterTestFixture(TTestStack<WideString>);
  TDUnitX.RegisterTestFixture(TTestStack<AnsiChar>);
  {$ENDIF}
  TDUnitX.RegisterTestFixture(TTestStack<RawByteString>);
  TDUnitX.RegisterTestFixture(TTestStack<UnicodeString>);
  TDUnitX.RegisterTestFixture(TTestStack<Variant>);
  TDUnitX.RegisterTestFixture(TTestStack<Int64>);
  TDUnitX.RegisterTestFixture(TTestStack<UInt64>);
  TDUnitX.RegisterTestFixture(TTestStack<TBytes>);
  TDUnitX.RegisterTestFixture(TTestStack<WideChar>);
  TDUnitX.RegisterTestFixture(TTestStack<TTestArray>);
  TDUnitX.RegisterTestFixture(TTestStack<TSimpleRecord>);
  TDUnitX.RegisterTestFixture(TTestStack<TManagedRecord>);
  TDUnitX.RegisterTestFixture(TTestStack<TFooBarRecord>);
  TDUnitX.RegisterTestFixture(TTestStack<TManagedArray>);
  TDUnitX.RegisterTestFixture(TTestStack<TFooBarArray>);
  {$ENDIF LIMITED_GENERICS}

  TDUnitX.RegisterTestFixture(TTestTgrObjectStack);
end.
