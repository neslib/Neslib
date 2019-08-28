unit Tests.Collections.Dictionaries;

interface

uses
  DUnitX.TestFramework,
  Tests.Collections.Base;

type
  TTestDictionaryByKey<TKey> = class(TTestCollectionBase<TKey>)
  private type
    TPair = TPair<TKey, Integer>;
  private
    FCUT: TgrDictionary<TKey, Integer>;
    FKeys: TArray<TKey>;
    procedure FillDictionary;
    procedure CheckItems(const AExpectedKeys: TArray<TKey>;
      const AExpectedValues: array of Integer);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAdd;
    procedure TestRemove;
    procedure TestClear;
    procedure TestTryGetValue;
    procedure TestAddOrSetValue;
    procedure TestContainsKey;
    procedure TestContainsValue;
    procedure TestToArray;
    procedure TestGetEnumerator;
    procedure TestGetItem;
    procedure TestSetItem;
    procedure TestKeys;
    procedure TestValues;
  end;

(*type
  TTestTgrDictionaryByValue<TValue> = class(TBaseTest<TValue>)
  private type
    TPair = TgrPair<Integer, TValue>;
  private
    FCUT: TgrDictionary<Integer, TValue>;
    FValues: TArray<TValue>;
    procedure FillDictionary;
    procedure CheckItems(const AExpectedKeys: array of Integer;
      const AExpectedValues: TArray<TValue>);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAdd;
    procedure TestRemove;
    procedure TestClear;
    procedure TestTryGetValue;
    procedure TestAddOrSetValue;
    procedure TestContainsKey;
    procedure TestContainsValue;
    procedure TestToArray;
    procedure TestGetEnumerator;
    procedure TestGetItem;
    procedure TestSetItem;
    procedure TestKeys;
    procedure TestValues;
  end;

type
  TTestTgrObjectDictionary = class(TBaseTest<TFoo>)
  private type
    TPair = TgrPair<TFoo, TBar>;
  private
    FCUT: TgrObjectDictionary<TFoo, TBar>;
    FKeys: TArray<TFoo>;
    FValues: TArray<TBar>;
    procedure FillDictionary;
    procedure CheckItems(const AExpectedKeysIndices,
      AExpectedValues: array of Integer);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAdd;
    procedure TestRemove;
    procedure TestClear;
    procedure TestTryGetValue;
    procedure TestAddOrSetValue;
    procedure TestContainsKey;
    procedure TestContainsValue;
    procedure TestToArray;
    procedure TestGetEnumerator;
    procedure TestGetItem;
    procedure TestSetItem;
    procedure TestKeys;
    procedure TestValues;
    procedure TestExtractPair;
  end;*)

implementation

{ TTestDictionaryByKey<TKey> }

procedure TTestDictionaryByKey<TKey>.CheckItems(
  const AExpectedKeys: TArray<TKey>; const AExpectedValues: array of Integer);
var
  Key: TKey;
  I, Value: Integer;
begin
  CheckEquals(Length(AExpectedKeys), FCUT.Count);
  CheckEquals(Length(AExpectedValues), FCUT.Count);

  for I := 0 to Length(AExpectedKeys) - 1 do
  begin
    Key := AExpectedKeys[I];
    CheckTrue(FCUT.TryGetValue(Key, Value));
    CheckEquals(AExpectedValues[I], Value);
  end;
end;

procedure TTestDictionaryByKey<TKey>.FillDictionary;
begin
  FKeys := CreateValues(3);
  FCUT.Add(FKeys[0], 10);
  FCUT.Add(FKeys[1], 20);
  FCUT.Add(FKeys[2], 30);
end;

procedure TTestDictionaryByKey<TKey>.SetUp;
begin
  inherited;
  FCUT := TgrDictionary<TKey, Integer>.Create;
end;

procedure TTestDictionaryByKey<TKey>.TearDown;
begin
  FCUT.Free;
  inherited;
end;

procedure TTestDictionaryByKey<TKey>.TestAdd;
begin
  FillDictionary;
  CheckItems(FKeys, [10, 20, 30]);
end;

procedure TTestDictionaryByKey<TKey>.TestAddOrSetValue;
var
  Keys: TArray<TKey>;
begin
  Keys := CreateValues(4);
  FCUT.Add(Keys[0], 10);
  FCUT.Add(Keys[1], 20);
  FCUT.Add(Keys[2], 30);
  CheckEquals(3, FCUT.Count);

  FCUT.AddOrSetValue(Keys[1], 40);
  CheckEquals(3, FCUT.Count);

  FCUT.AddOrSetValue(Keys[3], 50);
  CheckItems(Keys, [10, 40, 30, 50]);
end;

procedure TTestDictionaryByKey<TKey>.TestClear;
begin
  FillDictionary;
  CheckEquals(3, FCUT.Count);

  FCUT.Clear;
  CheckEquals(0, FCUT.Count);
end;

procedure TTestDictionaryByKey<TKey>.TestContainsKey;
var
  RogueKey: TKey;
begin
  FillDictionary;
  RogueKey := CreateValue(3);
  CheckTrue(FCUT.ContainsKey(FKeys[0]));
  CheckTrue(FCUT.ContainsKey(FKeys[1]));
  CheckTrue(FCUT.ContainsKey(FKeys[2]));
  CheckFalse(FCUT.ContainsKey(RogueKey));
end;

procedure TTestDictionaryByKey<TKey>.TestContainsValue;
begin
  FillDictionary;
  CheckTrue(FCUT.ContainsValue(10));
  CheckTrue(FCUT.ContainsValue(20));
  CheckTrue(FCUT.ContainsValue(30));
  CheckFalse(FCUT.ContainsValue(40));
end;

procedure TTestDictionaryByKey<TKey>.TestGetEnumerator;
var
  Pair: TPair;
  B: Byte;
  C: TgrEqualityComparer<TKey>;
begin
  FillDictionary;
  TgrGenericFunctions.DefaultEqualityComparer(System.TypeInfo(TKey), SizeOf(TKey), C);
  B := 0;
  for Pair in FCUT do
  begin
    if (C.Equals(Pair.Key, FKeys[0], C.Param)) then
    begin
      B := B or $01;
      CheckEquals(10, Pair.Value)
    end
    else if (C.Equals(Pair.Key, FKeys[1], C.Param)) then
    begin
      B := B or $02;
      CheckEquals(20, Pair.Value)
    end
    else if (C.Equals(Pair.Key, FKeys[2], C.Param)) then
    begin
      B := B or $04;
      CheckEquals(30, Pair.Value)
    end
    else
      Fail('Unexpected item');
  end;
  CheckEquals($07, B);
end;

procedure TTestDictionaryByKey<TKey>.TestGetItem;
begin
  FillDictionary;
  CheckEquals(10, FCUT[FKeys[0]]);
  CheckEquals(20, FCUT[FKeys[1]]);
  CheckEquals(30, FCUT[FKeys[2]]);
end;

procedure TTestDictionaryByKey<TKey>.TestKeys;
var
  Key: TKey;
  B: Byte;
  C: TgrEqualityComparer<TKey>;
begin
  FillDictionary;
  TgrGenericFunctions.DefaultEqualityComparer(System.TypeInfo(TKey), SizeOf(TKey), C);
  B := 0;
  for Key in FCUT.Keys do
  begin
    if (C.Equals(Key, FKeys[0], C.Param)) then
      B := B or $01
    else if (C.Equals(Key, FKeys[1], C.Param)) then
      B := B or $02
    else if (C.Equals(Key, FKeys[2], C.Param)) then
      B := B or $04
    else
      Fail('Unexpected item');
  end;
  CheckEquals($07, B);
end;

procedure TTestDictionaryByKey<TKey>.TestRemove;
var
  RogueKey: TKey;
  V: TArray<TKey>;
begin
  FillDictionary;
  RogueKey := CreateValue(3);
  CheckEquals(3, FCUT.Count);

  FCUT.Remove(RogueKey);
  CheckEquals(3, FCUT.Count);
  CheckItems(FKeys, [10, 20, 30]);

  FCUT.Remove(FKeys[0]);
  CheckEquals(2, FCUT.Count);
  SetLength(V, 2);
  V[0] := FKeys[1];
  V[1] := FKeys[2];
  CheckItems(V, [20, 30]);

  FCUT.Remove(FKeys[2]);
  CheckEquals(1, FCUT.Count);
  SetLength(V, 1);
  V[0] := FKeys[1];
  CheckItems(V, [20]);

  FCUT.Remove(FKeys[1]);
  CheckEquals(0, FCUT.Count);
end;

procedure TTestDictionaryByKey<TKey>.TestSetItem;
begin
  FillDictionary;
  FCUT[FKeys[0]] := 11;
  FCUT[FKeys[2]] := 12;
  CheckItems(FKeys, [11, 20, 12]);
end;

procedure TTestDictionaryByKey<TKey>.TestToArray;
var
  A: TArray<TPair>;
  C: TgrEqualityComparer<TKey>;
  I: Integer;
begin
  FillDictionary;
  TgrGenericFunctions.DefaultEqualityComparer(System.TypeInfo(TKey), SizeOf(TKey), C);
  A := FCUT.ToArray;
  CheckEquals(3, Length(A));
  for I := 0 to 2 do
  begin
    if C.Equals(A[I].Key, FKeys[0], C.Param) then
      CheckEquals(10, A[I].Value)
    else if C.Equals(A[I].Key, FKeys[1], C.Param) then
      CheckEquals(20, A[I].Value)
    else if C.Equals(A[I].Key, FKeys[2], C.Param) then
      CheckEquals(30, A[I].Value)
    else
      Fail('Unexpected key in dictionary');
  end;
end;

procedure TTestDictionaryByKey<TKey>.TestTryGetValue;
var
  RogueKey: TKey;
  Value: Integer;
begin
  FillDictionary;
  RogueKey := CreateValue(3);
  CheckFalse(FCUT.TryGetValue(RogueKey, Value));
  CheckEquals(Value, 0);

  CheckTrue(FCUT.TryGetValue(FKeys[1], Value));
  CheckEquals(Value, 20);
end;

procedure TTestDictionaryByKey<TKey>.TestValues;
var
  Value: Integer;
  B: Byte;
begin
  FillDictionary;
  B := 0;
  for Value in FCUT.Values do
  begin
    if (Value = 10) then
      B := B or $01
    else if (Value = 20) then
      B := B or $02
    else if (Value = 30) then
      B := B or $04
    else
      Fail('Unexpected item');
  end;
  CheckEquals($07, B);
end;

{ TTestTgrDictionaryByValue<TValue> }

procedure TTestTgrDictionaryByValue<TValue>.CheckItems(
  const AExpectedKeys: array of Integer; const AExpectedValues: TArray<TValue>);
var
  Value: TValue;
  I, Key: Integer;
begin
  CheckEquals(Length(AExpectedKeys), FCUT.Count);
  CheckEquals(Length(AExpectedValues), FCUT.Count);

  for I := 0 to Length(AExpectedKeys) - 1 do
  begin
    Key := AExpectedKeys[I];
    CheckTrue(FCUT.TryGetValue(Key, Value));
    TestEquals(AExpectedValues[I], Value);
  end;
end;

procedure TTestTgrDictionaryByValue<TValue>.FillDictionary;
begin
  FValues := CreateValues(3);
  FCUT.Add(10, FValues[0]);
  FCUT.Add(20, FValues[1]);
  FCUT.Add(30, FValues[2]);
end;

procedure TTestTgrDictionaryByValue<TValue>.SetUp;
begin
  inherited;
  FCUT := TgrDictionary<Integer, TValue>.Create;
end;

procedure TTestTgrDictionaryByValue<TValue>.TearDown;
begin
  FCUT.Free;
  inherited;
end;

procedure TTestTgrDictionaryByValue<TValue>.TestAdd;
begin
  FillDictionary;
  CheckItems([10, 20, 30], FValues);
end;

procedure TTestTgrDictionaryByValue<TValue>.TestAddOrSetValue;
var
  Values, NewValues: TArray<TValue>;
begin
  Values := CreateValues(5);
  FCUT.Add(10, Values[0]);
  FCUT.Add(20, Values[1]);
  FCUT.Add(30, Values[2]);
  CheckEquals(3, FCUT.Count);

  FCUT.AddOrSetValue(20, Values[3]);
  CheckEquals(3, FCUT.Count);

  FCUT.AddOrSetValue(40, Values[4]);

  SetLength(NewValues, 4);
  NewValues[0] := Values[0];
  NewValues[1] := Values[3];
  NewValues[2] := Values[2];
  NewValues[3] := Values[4];
  CheckItems([10, 20, 30, 40], NewValues);
end;

procedure TTestTgrDictionaryByValue<TValue>.TestClear;
begin
  FillDictionary;
  CheckEquals(3, FCUT.Count);

  FCUT.Clear;
  CheckEquals(0, FCUT.Count);
end;

procedure TTestTgrDictionaryByValue<TValue>.TestContainsKey;
begin
  FillDictionary;
  CheckTrue(FCUT.ContainsKey(10));
  CheckTrue(FCUT.ContainsKey(20));
  CheckTrue(FCUT.ContainsKey(30));
  CheckFalse(FCUT.ContainsKey(40));
end;

procedure TTestTgrDictionaryByValue<TValue>.TestContainsValue;
var
  RogueValue: TValue;
begin
  FillDictionary;
  RogueValue := CreateValue(3);
  CheckTrue(FCUT.ContainsValue(FValues[0]));
  CheckTrue(FCUT.ContainsValue(FValues[1]));
  CheckTrue(FCUT.ContainsValue(FValues[2]));
  CheckFalse(FCUT.ContainsValue(RogueValue));
end;

procedure TTestTgrDictionaryByValue<TValue>.TestGetEnumerator;
var
  Pair: TPair;
  B: Byte;
  C: TgrEqualityComparer<TValue>;
begin
  FillDictionary;
  TgrGenericFunctions.DefaultEqualityComparer(System.TypeInfo(TValue), SizeOf(TValue), C);
  B := 0;
  for Pair in FCUT do
  begin
    if (Pair.Key = 10) then
    begin
      B := B or $01;
      CheckTrue(C.Equals(Pair.Value, FValues[0], C.Param))
    end
    else if (Pair.Key = 20) then
    begin
      B := B or $02;
      CheckTrue(C.Equals(Pair.Value, FValues[1], C.Param))
    end
    else if (Pair.Key = 30) then
    begin
      B := B or $04;
      CheckTrue(C.Equals(Pair.Value, FValues[2], C.Param))
    end
    else
      Fail('Unexpected item');
  end;
  CheckEquals($07, B);
end;

procedure TTestTgrDictionaryByValue<TValue>.TestGetItem;
begin
  FillDictionary;
  TestEquals(FValues[0], FCUT[10]);
  TestEquals(FValues[1], FCUT[20]);
  TestEquals(FValues[2], FCUT[30]);
end;

procedure TTestTgrDictionaryByValue<TValue>.TestKeys;
var
  Key: Integer;
  B: Byte;
begin
  FillDictionary;
  B := 0;
  for Key in FCUT.Keys do
  begin
    if (Key = 10) then
      B := B or $01
    else if (Key = 20) then
      B := B or $02
    else if (Key = 30) then
      B := B or $04
    else
      Fail('Unexpected item');
  end;
  CheckEquals($07, B);
end;

procedure TTestTgrDictionaryByValue<TValue>.TestRemove;
var
  V: TArray<TValue>;
begin
  FillDictionary;
  CheckEquals(3, FCUT.Count);

  FCUT.Remove(40);
  CheckEquals(3, FCUT.Count);
  CheckItems([10, 20, 30], FValues);

  FCUT.Remove(10);
  CheckEquals(2, FCUT.Count);
  SetLength(V, 2);
  V[0] := FValues[1];
  V[1] := FValues[2];
  CheckItems([20, 30], V);

  FCUT.Remove(30);
  CheckEquals(1, FCUT.Count);
  SetLength(V, 1);
  V[0] := FValues[1];
  CheckItems([20], V);

  FCUT.Remove(20);
  CheckEquals(0, FCUT.Count);
end;

procedure TTestTgrDictionaryByValue<TValue>.TestSetItem;
var
  NewValues: TArray<TValue>;
begin
  FillDictionary;
  SetLength(NewValues, 3);
  NewValues[0] := CreateValue(3);
  NewValues[1] := FValues[1];
  NewValues[2] := CreateValue(4);
  FCUT[10] := NewValues[0];
  FCUT[30] := NewValues[2];

  CheckItems([10, 20, 30], NewValues);
end;

procedure TTestTgrDictionaryByValue<TValue>.TestToArray;
var
  A: TArray<TPair>;
  C: TgrEqualityComparer<TValue>;
  I: Integer;
begin
  FillDictionary;
  TgrGenericFunctions.DefaultEqualityComparer(System.TypeInfo(TValue), SizeOf(TValue), C);
  A := FCUT.ToArray;
  CheckEquals(3, Length(A));
  for I := 0 to 2 do
  begin
    if (A[I].Key = 10) then
      TestEquals(FValues[0], A[I].Value)
    else if (A[I].Key = 20) then
      TestEquals(FValues[1], A[I].Value)
    else if (A[I].Key = 30) then
      TestEquals(FValues[2], A[I].Value)
    else
      Fail('Unexpected key in dictionary');
  end;
end;

procedure TTestTgrDictionaryByValue<TValue>.TestTryGetValue;
var
  Value, NullValue: TValue;
  C: TgrEqualityComparer<TValue>;
begin
  FillDictionary;
  TgrGenericFunctions.DefaultEqualityComparer(System.TypeInfo(TValue), SizeOf(TValue), C);
  NullValue := Default(TValue);

  CheckFalse(FCUT.TryGetValue(40, Value));
  CheckTrue(C.Equals(NullValue, Value, C.Param));

  CheckTrue(FCUT.TryGetValue(20, Value));
  CheckTrue(C.Equals(FValues[1], Value, C.Param));
end;

procedure TTestTgrDictionaryByValue<TValue>.TestValues;
var
  Value: TValue;
  B: Byte;
  C: TgrEqualityComparer<TValue>;
begin
  FillDictionary;
  TgrGenericFunctions.DefaultEqualityComparer(System.TypeInfo(TValue), SizeOf(TValue), C);
  B := 0;
  for Value in FCUT.Values do
  begin
    if (C.Equals(Value, FValues[0], C.Param)) then
      B := B or $01
    else if (C.Equals(Value, FValues[1], C.Param)) then
      B := B or $02
    else if (C.Equals(Value, FValues[2], C.Param)) then
      B := B or $04
    else
      Fail('Unexpected item');
  end;
  CheckEquals($07, B);
end;

{ TTestTgrObjectDictionary }

procedure TTestTgrObjectDictionary.CheckItems(const AExpectedKeysIndices,
  AExpectedValues: array of Integer);
var
  I: Integer;
  Key: TFoo;
  Value: TBar;
begin
  CheckEquals(Length(AExpectedKeysIndices), FCUT.Count);
  CheckEquals(Length(AExpectedValues), FCUT.Count);

  for I := 0 to Length(AExpectedKeysIndices) - 1 do
  begin
    Key := FKeys[AExpectedKeysIndices[I]];
    CheckTrue(FCUT.TryGetValue(Key, Value));
    CheckEquals(AExpectedValues[I], Value.Value);
  end;
end;

procedure TTestTgrObjectDictionary.FillDictionary;
var
  I: Integer;
begin
  SetLength(FKeys, 3);
  SetLength(FValues, 3);
  for I := 0 to 2 do
  begin
    FKeys[I] := TFoo.Create(I + 1);
    FValues[I] := TBar.Create((I + 1) * 10);
    FCUT.Add(FKeys[I], FValues[I]);
  end;
end;

procedure TTestTgrObjectDictionary.SetUp;
begin
  inherited;
  FCUT := TgrObjectDictionary<TFoo, TBar>.Create([doOwnsKeys, doOwnsValues]);
end;

procedure TTestTgrObjectDictionary.TearDown;
var
  I: Integer;
begin
  { Make sure all references are cleared before checking for leaks }
  for I := 0 to Length(FKeys) - 1 do
    FKeys[I] := nil;
  for I := 0 to Length(FValues) - 1 do
    FValues[I] := nil;
  FCUT.Free;
  inherited;
end;

procedure TTestTgrObjectDictionary.TestAdd;
begin
  FillDictionary;
  CheckItems([0, 1, 2], [10, 20, 30]);
end;

procedure TTestTgrObjectDictionary.TestAddOrSetValue;
begin
  FillDictionary;
  // 0:1>10, 1:2>20, 2:3>30
  CheckEquals(3, FCUT.Count);

  FCUT.AddOrSetValue(FKeys[1], TBar.Create(40));
  // 0:1>10, 1:2>40, 2:3>30
  CheckEquals(3, FCUT.Count);

  SetLength(FKeys, 4);
  FKeys[3] := TFoo.Create(4);
  // 0:1>10, 1:2>40, 2:3>30, 3:4>50
  FCUT.AddOrSetValue(FKeys[3], TBar.Create(50));

  CheckItems([0, 1, 2, 3], [10, 40, 30, 50]);
end;

procedure TTestTgrObjectDictionary.TestClear;
begin
  FillDictionary;
  CheckEquals(3, FCUT.Count);

  FCUT.Clear;
  CheckEquals(0, FCUT.Count);
end;

procedure TTestTgrObjectDictionary.TestContainsKey;
var
  RogueKey: TFoo;
begin
  FillDictionary;
  RogueKey := TFoo.Create(5);
  CheckTrue(FCUT.ContainsKey(FKeys[0]));
  CheckTrue(FCUT.ContainsKey(FKeys[1]));
  CheckTrue(FCUT.ContainsKey(FKeys[2]));
  CheckFalse(FCUT.ContainsKey(RogueKey));
  RogueKey.Free;
end;

procedure TTestTgrObjectDictionary.TestContainsValue;
var
  RogueValue: TBar;
begin
  FillDictionary;
  RogueValue := TBar.Create(5);
  CheckTrue(FCUT.ContainsValue(FValues[0]));
  CheckTrue(FCUT.ContainsValue(FValues[1]));
  CheckTrue(FCUT.ContainsValue(FValues[2]));
  CheckFalse(FCUT.ContainsValue(RogueValue));
  RogueValue.Free;
end;

procedure TTestTgrObjectDictionary.TestExtractPair;
var
  RogueKey: TFoo;
  Pair: TgrPair<TFoo, TBar>;
begin
  FillDictionary;
  RogueKey := TFoo.Create(5);

  Pair := FCUT.ExtractPair(RogueKey);
  CheckSame(RogueKey, Pair.Key);
  CheckSame(nil, Pair.Value);
  RogueKey.Free;

  CheckTrue(FCUT.ContainsKey(FKeys[1]));
  Pair := FCUT.ExtractPair(FKeys[1]);
  CheckSame(FKeys[1], Pair.Key);
  CheckSame(FValues[1], Pair.Value);
  CheckFalse(FCUT.ContainsKey(FKeys[1]));
  Pair.Key.Free;
  Pair.Value.Free;
end;

procedure TTestTgrObjectDictionary.TestGetEnumerator;
var
  Pair: TPair;
  B: Byte;
begin
  FillDictionary;
  B := 0;
  for Pair in FCUT do
  begin
    if (Pair.Key.Value = 1) then
    begin
      B := B or $01;
      CheckEquals(10, Pair.Value.Value)
    end
    else if (Pair.Key.Value = 2) then
    begin
      B := B or $02;
      CheckEquals(20, Pair.Value.Value)
    end
    else if (Pair.Key.Value = 3) then
    begin
      B := B or $04;
      CheckEquals(30, Pair.Value.Value)
    end
    else
      Fail('Unexpected item');
  end;
  CheckEquals($07, B);
end;

procedure TTestTgrObjectDictionary.TestGetItem;
begin
  FillDictionary;
  CheckSame(FValues[0], FCUT[FKeys[0]]);
  CheckSame(FValues[1], FCUT[FKeys[1]]);
  CheckSame(FValues[2], FCUT[FKeys[2]]);
end;

procedure TTestTgrObjectDictionary.TestKeys;
var
  Key: TFoo;
  B: Byte;
begin
  FillDictionary;
  B := 0;
  for Key in FCUT.Keys do
  begin
    if (Key.Value = 1) then
      B := B or $01
    else if (Key.Value = 2) then
      B := B or $02
    else if (Key.Value = 3) then
      B := B or $04
    else
      Fail('Unexpected item');
  end;
  CheckEquals($07, B);
end;

procedure TTestTgrObjectDictionary.TestRemove;
var
  RogueKey: TFoo;
begin
  FillDictionary;
  CheckEquals(3, FCUT.Count);

  RogueKey := TFoo.Create(5);
  FCUT.Remove(RogueKey);
  CheckEquals(3, FCUT.Count);
  CheckItems([0, 1, 2], [10, 20, 30]);
  RogueKey.Free;

  FCUT.Remove(FKeys[0]);
  CheckEquals(2, FCUT.Count);
  CheckItems([1, 2], [20, 30]);

  FCUT.Remove(FKeys[2]);
  CheckEquals(1, FCUT.Count);
  CheckItems([1], [20]);

  FCUT.Remove(FKeys[1]);
  CheckEquals(0, FCUT.Count);
end;

procedure TTestTgrObjectDictionary.TestSetItem;
begin
  FillDictionary;
  // 0:1>10, 1:2>20, 2:3>30
  FCUT[FKeys[0]] := TBar.Create(40);
  FCUT[FKeys[2]] := TBar.Create(50);

  CheckItems([0, 1, 2], [40, 20, 50]);
end;

procedure TTestTgrObjectDictionary.TestToArray;
var
  A: TArray<TPair>;
  I: Integer;
begin
  FillDictionary;
  A := FCUT.ToArray;
  CheckEquals(3, Length(A));
  for I := 0 to 2 do
  begin
    if (A[I].Key.Value = 1) then
      CheckEquals(10, A[I].Value.Value)
    else if (A[I].Key.Value = 2) then
      CheckEquals(20, A[I].Value.Value)
    else if (A[I].Key.Value = 3) then
      CheckEquals(30, A[I].Value.Value)
    else
      Fail('Unexpected key in dictionary');
  end;
end;

procedure TTestTgrObjectDictionary.TestTryGetValue;
var
  RogueKey: TFoo;
  Value: TBar;
begin
  FillDictionary;
  RogueKey := CreateValue(5);
  CheckFalse(FCUT.TryGetValue(RogueKey, Value));
  CheckSame(nil, Value);

  CheckTrue(FCUT.TryGetValue(FKeys[1], Value));
  CheckEquals(20, Value.Value);
end;

procedure TTestTgrObjectDictionary.TestValues;
var
  Value: TBar;
  B: Byte;
begin
  FillDictionary;
  B := 0;
  for Value in FCUT.Values do
  begin
    if (Value.Value = 10) then
      B := B or $01
    else if (Value.Value = 20) then
      B := B or $02
    else if (Value.Value = 30) then
      B := B or $04
    else
      Fail('Unexpected item');
  end;
  CheckEquals($07, B);
end;

initialization
  grRegisterTests([
    TTestDictionaryByKey<ShortInt>,
    {$IFNDEF LIMITED_GENERICS}
    TTestDictionaryByKey<Byte>,
    TTestDictionaryByKey<SmallInt>,
    TTestDictionaryByKey<Word>,
    TTestDictionaryByKey<Integer>,
    TTestDictionaryByKey<Cardinal>,
    TTestDictionaryByKey<Boolean>,
    TTestDictionaryByKey<TDigit>,
    TTestDictionaryByKey<TDigits>,
    TTestDictionaryByKey<Single>,
    TTestDictionaryByKey<Double>,
    TTestDictionaryByKey<Extended>,
    TTestDictionaryByKey<Comp>,
    TTestDictionaryByKey<Currency>,
    TTestDictionaryByKey<TFoo>,
    TTestDictionaryByKey<IBaz>,
    TTestDictionaryByKey<PInteger>,
    TTestDictionaryByKey<TTestProc>,
    TTestDictionaryByKey<TTestMethod>,
    {$IFNDEF NEXTGEN}
    TTestDictionaryByKey<TStr1>,
    TTestDictionaryByKey<TStr2>,
    TTestDictionaryByKey<TStr3>,
    TTestDictionaryByKey<ShortString>,
    TTestDictionaryByKey<AnsiString>,
    TTestDictionaryByKey<WideString>,
    TTestDictionaryByKey<AnsiChar>,
    {$ENDIF}
    TTestDictionaryByKey<RawByteString>,
    TTestDictionaryByKey<UnicodeString>,
    TTestDictionaryByKey<Variant>,
    TTestDictionaryByKey<Int64>,
    TTestDictionaryByKey<UInt64>,
    TTestDictionaryByKey<TBytes>,
    TTestDictionaryByKey<WideChar>,
    TTestDictionaryByKey<TTestArray>,
    TTestDictionaryByKey<TSimpleRecord>,
    TTestDictionaryByKey<TManagedRecord>,
    TTestDictionaryByKey<TFooBarRecord>,
    TTestDictionaryByKey<TManagedArray>,
    TTestDictionaryByKey<TFooBarArray>,

    TTestTgrDictionaryByValue<ShortInt>,
    TTestTgrDictionaryByValue<Byte>,
    TTestTgrDictionaryByValue<SmallInt>,
    TTestTgrDictionaryByValue<Word>,
    TTestTgrDictionaryByValue<Integer>,
    TTestTgrDictionaryByValue<Cardinal>,
    TTestTgrDictionaryByValue<Boolean>,
    TTestTgrDictionaryByValue<TDigit>,
    TTestTgrDictionaryByValue<TDigits>,
    TTestTgrDictionaryByValue<Single>,
    TTestTgrDictionaryByValue<Double>,
    TTestTgrDictionaryByValue<Extended>,
    TTestTgrDictionaryByValue<Comp>,
    TTestTgrDictionaryByValue<Currency>,
    TTestTgrDictionaryByValue<TFoo>,
    TTestTgrDictionaryByValue<IBaz>,
    TTestTgrDictionaryByValue<PInteger>,
    TTestTgrDictionaryByValue<TTestProc>,
    TTestTgrDictionaryByValue<TTestMethod>,
    {$IFNDEF NEXTGEN}
    TTestTgrDictionaryByValue<TStr1>,
    TTestTgrDictionaryByValue<TStr2>,
    TTestTgrDictionaryByValue<TStr3>,
    TTestTgrDictionaryByValue<ShortString>,
    TTestTgrDictionaryByValue<AnsiString>,
    TTestTgrDictionaryByValue<WideString>,
    TTestTgrDictionaryByValue<AnsiChar>,
    {$ENDIF}
    TTestTgrDictionaryByValue<RawByteString>,
    TTestTgrDictionaryByValue<UnicodeString>,
    TTestTgrDictionaryByValue<Variant>,
    TTestTgrDictionaryByValue<Int64>,
    TTestTgrDictionaryByValue<UInt64>,
    TTestTgrDictionaryByValue<TBytes>,
    TTestTgrDictionaryByValue<WideChar>,
    TTestTgrDictionaryByValue<TTestArray>,
    TTestTgrDictionaryByValue<TSimpleRecord>,
    TTestTgrDictionaryByValue<TManagedRecord>,
    TTestTgrDictionaryByValue<TFooBarRecord>,
    TTestTgrDictionaryByValue<TManagedArray>,
    {$ENDIF !LIMITED_GENERICS}
    TTestTgrDictionaryByValue<TFooBarArray>,
    TTestTgrObjectDictionary
    ]);
end.
