unit Tests.Collections.Sets;

interface

uses
  DUnitX.TestFramework,
  System.Generics.Defaults,
  Tests.Collections.Base,
  Neslib.Collections;

type
  TTestSet<T> = class(TTestCollectionBase<T>)
  private
    FCUT: TSet<T>;
    FValues: TArray<T>;
    procedure FillSet;
    procedure CheckItems(const AExpected: TArray<T>);
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestAdd;
    [Test] procedure TestRemove;
    [Test] procedure TestClear;
    [Test] procedure TestAddOrSet;
    [Test] procedure TestContains;
    [Test] procedure TestToArray;
    [Test] procedure TestGetEnumerator;
  end;

type
  TTestObjectSet = class(TTestCollectionBase<TFoo>)
  private
    FCUT: TObjectSet<TFoo>;
    FValues: TArray<TFoo>;
    procedure FillSet;
    procedure CheckItems(const AExpectedIndices: array of Integer);
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestAdd;
    [Test] procedure TestRemove;
    [Test] procedure TestClear;
    [Test] procedure TestAddOrSet;
    [Test] procedure TestContains;
    [Test] procedure TestToArray;
    [Test] procedure TestGetEnumerator;
    [Test] procedure TestExtract;
  end;

implementation

uses
  System.SysUtils;

{ TTestSet<T> }

procedure TTestSet<T>.CheckItems(const AExpected: TArray<T>);
var
  Value: T;
  I: Integer;
begin
  Assert.AreEqual<Integer>(Length(AExpected), FCUT.Count);

  for I := 0 to Length(AExpected) - 1 do
  begin
    Value := AExpected[I];
    Assert.IsTrue(FCUT.Contains(Value));
  end;
end;

procedure TTestSet<T>.FillSet;
begin
  FValues := CreateValues(3);
  FCUT.Add(FValues[0]);
  FCUT.Add(FValues[1]);
  FCUT.Add(FValues[2]);
end;

procedure TTestSet<T>.SetUp;
begin
  inherited;
  FCUT := TSet<T>.Create;
end;

procedure TTestSet<T>.TearDown;
begin
  FCUT.Free;
  inherited;
end;

procedure TTestSet<T>.TestAdd;
begin
  FillSet;
  CheckItems(FValues);
end;

procedure TTestSet<T>.TestAddOrSet;
var
  Values: TArray<T>;
begin
  Values := CreateValues(4);
  FCUT.Add(Values[0]);
  FCUT.Add(Values[1]);
  FCUT.Add(Values[2]);
  Assert.AreEqual(3, FCUT.Count);

  FCUT.AddOrSet(Values[1]);
  Assert.AreEqual(3, FCUT.Count);

  FCUT.AddOrSet(Values[3]);
  CheckItems(Values);
end;

procedure TTestSet<T>.TestClear;
begin
  FillSet;
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Clear;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestSet<T>.TestContains;
var
  RogueValue: T;
begin
  FillSet;
  RogueValue := CreateValue(3);
  Assert.IsTrue(FCUT.Contains(FValues[0]));
  Assert.IsTrue(FCUT.Contains(FValues[1]));
  Assert.IsTrue(FCUT.Contains(FValues[2]));
  Assert.IsFalse(FCUT.Contains(RogueValue));
end;

procedure TTestSet<T>.TestGetEnumerator;
var
  Value: T;
  B: Byte;
  C: IEqualityComparer<T>;
begin
  FillSet;
  C := TEqualityComparer<T>.Default;
  B := 0;
  for Value in FCUT do
  begin
    if (C.Equals(Value, FValues[0])) then
      B := B or $01
    else if (C.Equals(Value, FValues[1])) then
      B := B or $02
    else if (C.Equals(Value, FValues[2])) then
      B := B or $04
    else
      Assert.Fail('Unexpected item');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

procedure TTestSet<T>.TestRemove;
var
  RogueValue: T;
  V: TArray<T>;
begin
  FillSet;
  RogueValue := CreateValue(3);
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Remove(RogueValue);
  Assert.AreEqual(3, FCUT.Count);
  CheckItems(FValues);

  FCUT.Remove(FValues[0]);
  Assert.AreEqual(2, FCUT.Count);
  SetLength(V, 2);
  V[0] := FValues[1];
  V[1] := FValues[2];
  CheckItems(V);

  FCUT.Remove(FValues[2]);
  Assert.AreEqual(1, FCUT.Count);
  SetLength(V, 1);
  V[0] := FValues[1];
  CheckItems(V);

  FCUT.Remove(FValues[1]);
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestSet<T>.TestToArray;
var
  A: TArray<T>;
  C: IEqualityComparer<T>;
  I: Integer;
  B: Byte;
begin
  FillSet;
  C := TEqualityComparer<T>.Default;
  A := FCUT.ToArray;
  Assert.AreEqual<Integer>(3, Length(A));
  B := 0;
  for I := 0 to 2 do
  begin
    if C.Equals(A[I], FValues[0]) then
      B := B or $01
    else if C.Equals(A[I], FValues[1]) then
      B := B or $02
    else if C.Equals(A[I], FValues[2]) then
      B := B or $04
    else
      Assert.Fail('Unexpected key in set');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

{ TTestObjectSet }

procedure TTestObjectSet.CheckItems(const AExpectedIndices: array of Integer);
var
  I: Integer;
  Value: TFoo;
begin
  Assert.AreEqual(Length(AExpectedIndices), FCUT.Count);

  for I := 0 to Length(AExpectedIndices) - 1 do
  begin
    Value := FValues[AExpectedIndices[I]];
    Assert.IsTrue(FCUT.Contains(Value));
  end;
end;

procedure TTestObjectSet.FillSet;
var
  I: Integer;
begin
  SetLength(FValues, 3);
  for I := 0 to 2 do
  begin
    FValues[I] := TFoo.Create(I);
    FCUT.Add(FValues[I]);
  end;
end;

procedure TTestObjectSet.SetUp;
begin
  inherited;
  FCUT := TObjectSet<TFoo>.Create;
end;

procedure TTestObjectSet.TearDown;
var
  I: Integer;
begin
  for I := 0 to Length(FValues) - 1 do
    FValues[I] := nil;
  FCUT.Free;
  FCUT := nil;
  inherited;
end;

procedure TTestObjectSet.TestAdd;
begin
  FillSet;
  CheckItems([0, 1, 2]);
end;

procedure TTestObjectSet.TestAddOrSet;
begin
  FillSet;
  Assert.AreEqual(3, FCUT.Count);

  FCUT.AddOrSet(FValues[1]);
  Assert.AreEqual(3, FCUT.Count);

  SetLength(FValues, 4);
  FValues[3] := TFoo.Create(5);
  FCUT.AddOrSet(FValues[3]);
  CheckItems([0, 1, 2, 3]);
end;

procedure TTestObjectSet.TestClear;
begin
  FillSet;
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Clear;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestObjectSet.TestContains;
var
  RogueValue: TFoo;
begin
  FillSet;
  RogueValue := TFoo.Create(5);
  Assert.IsTrue(FCUT.Contains(FValues[0]));
  Assert.IsTrue(FCUT.Contains(FValues[1]));
  Assert.IsTrue(FCUT.Contains(FValues[2]));
  Assert.IsFalse(FCUT.Contains(RogueValue));
  RogueValue.Free;
end;

procedure TTestObjectSet.TestExtract;
var
  Value, RogueValue: TFoo;
begin
  FillSet;
  RogueValue := TFoo.Create(5);

  Value := FCUT.Extract(FValues[1]);
  Assert.IsNotNull(Value);
  Value.Free;

  Value := FCUT.Extract(RogueValue);
  Assert.IsNull(Value);
  RogueValue.Free;
end;

procedure TTestObjectSet.TestGetEnumerator;
var
  Value: TFoo;
  B: Byte;
begin
  FillSet;
  B := 0;
  for Value in FCUT do
  begin
    if (Value.Value = 0) then
      B := B or $01
    else if (Value.Value = 1) then
      B := B or $02
    else if (Value.Value = 2) then
      B := B or $04
    else
      Assert.Fail('Unexpected item');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

procedure TTestObjectSet.TestRemove;
var
  RogueValue: TFoo;
begin
  FillSet;
  RogueValue := TFoo.Create(3);
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Remove(RogueValue);
  Assert.AreEqual(3, FCUT.Count);
  CheckItems([0, 1, 2]);
  RogueValue.Free;

  FCUT.Remove(FValues[0]);
  Assert.AreEqual(2, FCUT.Count);
  CheckItems([1, 2]);

  FCUT.Remove(FValues[2]);
  Assert.AreEqual(1, FCUT.Count);
  CheckItems([1]);

  FCUT.Remove(FValues[1]);
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestObjectSet.TestToArray;
var
  A: TArray<TFoo>;
  I: Integer;
  B: Byte;
begin
  FillSet;
  A := FCUT.ToArray;
  Assert.AreEqual<Integer>(3, Length(A));
  B := 0;
  for I := 0 to 2 do
  begin
    if (A[I].Value = 0) then
      B := B or $01
    else if (A[I].Value = 1) then
      B := B or $02
    else if (A[I].Value = 2) then
      B := B or $04
    else
      Assert.Fail('Unexpected key in set');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestSet<ShortInt>);
  {$IFNDEF LIMITED_GENERICS}
  TDUnitX.RegisterTestFixture(TTestSet<Byte>);
  TDUnitX.RegisterTestFixture(TTestSet<SmallInt>);
  TDUnitX.RegisterTestFixture(TTestSet<Word>);
  TDUnitX.RegisterTestFixture(TTestSet<Integer>);
  TDUnitX.RegisterTestFixture(TTestSet<Cardinal>);
  TDUnitX.RegisterTestFixture(TTestSet<Boolean>);
  TDUnitX.RegisterTestFixture(TTestSet<TDigit>);
  TDUnitX.RegisterTestFixture(TTestSet<TDigits>);
  TDUnitX.RegisterTestFixture(TTestSet<Single>);
  TDUnitX.RegisterTestFixture(TTestSet<Double>);
  TDUnitX.RegisterTestFixture(TTestSet<Extended>);
  TDUnitX.RegisterTestFixture(TTestSet<Comp>);
  TDUnitX.RegisterTestFixture(TTestSet<Currency>);
  TDUnitX.RegisterTestFixture(TTestSet<TFoo>);
  TDUnitX.RegisterTestFixture(TTestSet<IBaz>);
  TDUnitX.RegisterTestFixture(TTestSet<PInteger>);
  TDUnitX.RegisterTestFixture(TTestSet<TTestProc>);
  TDUnitX.RegisterTestFixture(TTestSet<TTestMethod>);
  {$IFNDEF NEXTGEN}
  TDUnitX.RegisterTestFixture(TTestSet<ShortString>);
  TDUnitX.RegisterTestFixture(TTestSet<AnsiString>);
  TDUnitX.RegisterTestFixture(TTestSet<WideString>);
  TDUnitX.RegisterTestFixture(TTestSet<AnsiChar>);
  {$ENDIF}
  TDUnitX.RegisterTestFixture(TTestSet<RawByteString>);
  TDUnitX.RegisterTestFixture(TTestSet<UnicodeString>);
  TDUnitX.RegisterTestFixture(TTestSet<Variant>);
  TDUnitX.RegisterTestFixture(TTestSet<Int64>);
  TDUnitX.RegisterTestFixture(TTestSet<UInt64>);
  TDUnitX.RegisterTestFixture(TTestSet<TBytes>);
  TDUnitX.RegisterTestFixture(TTestSet<WideChar>);
  TDUnitX.RegisterTestFixture(TTestSet<TTestArray>);
  TDUnitX.RegisterTestFixture(TTestSet<TSimpleRecord>);
  TDUnitX.RegisterTestFixture(TTestSet<TManagedRecord>);
  TDUnitX.RegisterTestFixture(TTestSet<TFooBarRecord>);
  TDUnitX.RegisterTestFixture(TTestSet<TManagedArray>);
  TDUnitX.RegisterTestFixture(TTestSet<TFooBarArray>);
  {$ENDIF LIMITED_GENERICS}

  TDUnitX.RegisterTestFixture(TTestObjectSet);
end.
