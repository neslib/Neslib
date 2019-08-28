unit Tests.Collections.Dictionaries;

interface

uses
  DUnitX.TestFramework,
  System.Generics.Defaults,
  Tests.Collections.Base,
  Neslib.Collections;

type
  TTestDictionaryByKey<TKey> = class(TTestCollectionBase<TKey>)
  private type
    TPair = TPair<TKey, Integer>;
  private
    FCUT: TDictionary<TKey, Integer>;
    FKeys: TArray<TKey>;
    procedure FillDictionary;
    procedure CheckItems(const AExpectedKeys: TArray<TKey>;
      const AExpectedValues: array of Integer);
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestAdd;
    [Test] procedure TestRemove;
    [Test] procedure TestClear;
    [Test] procedure TestTryGetValue;
    [Test] procedure TestAddOrSetValue;
    [Test] procedure TestContainsKey;
    [Test] procedure TestContainsValue;
    [Test] procedure TestToArray;
    [Test] procedure TestGetEnumerator;
    [Test] procedure TestGetItem;
    [Test] procedure TestSetItem;
    [Test] procedure TestKeys;
    [Test] procedure TestValues;
  end;

type
  TTestDictionaryByValue<TValue> = class(TTestCollectionBase<TValue>)
  private type
    TPair = TPair<Integer, TValue>;
  private
    FCUT: TDictionary<Integer, TValue>;
    FValues: TArray<TValue>;
    procedure FillDictionary;
    procedure CheckItems(const AExpectedKeys: array of Integer;
      const AExpectedValues: TArray<TValue>);
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestAdd;
    [Test] procedure TestRemove;
    [Test] procedure TestClear;
    [Test] procedure TestTryGetValue;
    [Test] procedure TestAddOrSetValue;
    [Test] procedure TestContainsKey;
    [Test] procedure TestContainsValue;
    [Test] procedure TestToArray;
    [Test] procedure TestGetEnumerator;
    [Test] procedure TestGetItem;
    [Test] procedure TestSetItem;
    [Test] procedure TestKeys;
    [Test] procedure TestValues;
  end;

type
  TTestObjectDictionary = class(TTestCollectionBase<TFoo>)
  private type
    TPair = TPair<TFoo, TBar>;
  private
    FCUT: TObjectDictionary<TFoo, TBar>;
    FKeys: TArray<TFoo>;
    FValues: TArray<TBar>;
    procedure FillDictionary;
    procedure CheckItems(const AExpectedKeysIndices,
      AExpectedValues: array of Integer);
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestAdd;
    [Test] procedure TestRemove;
    [Test] procedure TestClear;
    [Test] procedure TestTryGetValue;
    [Test] procedure TestAddOrSetValue;
    [Test] procedure TestContainsKey;
    [Test] procedure TestContainsValue;
    [Test] procedure TestToArray;
    [Test] procedure TestGetEnumerator;
    [Test] procedure TestGetItem;
    [Test] procedure TestSetItem;
    [Test] procedure TestKeys;
    [Test] procedure TestValues;
    [Test] procedure TestExtractPair;
  end;

implementation

uses
  System.SysUtils;

{ TTestDictionaryByKey<TKey> }

procedure TTestDictionaryByKey<TKey>.CheckItems(
  const AExpectedKeys: TArray<TKey>; const AExpectedValues: array of Integer);
var
  Key: TKey;
  I, Value: Integer;
begin
  Assert.AreEqual<Integer>(Length(AExpectedKeys), FCUT.Count);
  Assert.AreEqual<Integer>(Length(AExpectedValues), FCUT.Count);

  for I := 0 to Length(AExpectedKeys) - 1 do
  begin
    Key := AExpectedKeys[I];
    Assert.IsTrue(FCUT.TryGetValue(Key, Value));
    Assert.AreEqual(AExpectedValues[I], Value);
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
  FCUT := TDictionary<TKey, Integer>.Create;
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
  Assert.AreEqual(3, FCUT.Count);

  FCUT.AddOrSetValue(Keys[1], 40);
  Assert.AreEqual(3, FCUT.Count);

  FCUT.AddOrSetValue(Keys[3], 50);
  CheckItems(Keys, [10, 40, 30, 50]);
end;

procedure TTestDictionaryByKey<TKey>.TestClear;
begin
  FillDictionary;
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Clear;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestDictionaryByKey<TKey>.TestContainsKey;
var
  RogueKey: TKey;
begin
  FillDictionary;
  RogueKey := CreateValue(3);
  Assert.IsTrue(FCUT.ContainsKey(FKeys[0]));
  Assert.IsTrue(FCUT.ContainsKey(FKeys[1]));
  Assert.IsTrue(FCUT.ContainsKey(FKeys[2]));
  Assert.IsFalse(FCUT.ContainsKey(RogueKey));
end;

procedure TTestDictionaryByKey<TKey>.TestContainsValue;
begin
  FillDictionary;
  Assert.IsTrue(FCUT.ContainsValue(10));
  Assert.IsTrue(FCUT.ContainsValue(20));
  Assert.IsTrue(FCUT.ContainsValue(30));
  Assert.IsFalse(FCUT.ContainsValue(40));
end;

procedure TTestDictionaryByKey<TKey>.TestGetEnumerator;
var
  Pair: TPair;
  B: Byte;
  C: IEqualityComparer<TKey>;
begin
  FillDictionary;
  C := TEqualityComparer<TKey>.Default;
  B := 0;
  for Pair in FCUT do
  begin
    if (C.Equals(Pair.Key, FKeys[0])) then
    begin
      B := B or $01;
      Assert.AreEqual(10, Pair.Value)
    end
    else if (C.Equals(Pair.Key, FKeys[1])) then
    begin
      B := B or $02;
      Assert.AreEqual(20, Pair.Value)
    end
    else if (C.Equals(Pair.Key, FKeys[2])) then
    begin
      B := B or $04;
      Assert.AreEqual(30, Pair.Value)
    end
    else
      Assert.Fail('Unexpected item');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

procedure TTestDictionaryByKey<TKey>.TestGetItem;
begin
  FillDictionary;
  Assert.AreEqual(10, FCUT[FKeys[0]]);
  Assert.AreEqual(20, FCUT[FKeys[1]]);
  Assert.AreEqual(30, FCUT[FKeys[2]]);
end;

procedure TTestDictionaryByKey<TKey>.TestKeys;
var
  Key: TKey;
  B: Byte;
  C: IEqualityComparer<TKey>;
begin
  FillDictionary;
  C := TEqualityComparer<TKey>.Default;
  B := 0;
  for Key in FCUT.Keys do
  begin
    if (C.Equals(Key, FKeys[0])) then
      B := B or $01
    else if (C.Equals(Key, FKeys[1])) then
      B := B or $02
    else if (C.Equals(Key, FKeys[2])) then
      B := B or $04
    else
      Assert.Fail('Unexpected item');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

procedure TTestDictionaryByKey<TKey>.TestRemove;
var
  RogueKey: TKey;
  V: TArray<TKey>;
begin
  FillDictionary;
  RogueKey := CreateValue(3);
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Remove(RogueKey);
  Assert.AreEqual(3, FCUT.Count);
  CheckItems(FKeys, [10, 20, 30]);

  FCUT.Remove(FKeys[0]);
  Assert.AreEqual(2, FCUT.Count);
  SetLength(V, 2);
  V[0] := FKeys[1];
  V[1] := FKeys[2];
  CheckItems(V, [20, 30]);

  FCUT.Remove(FKeys[2]);
  Assert.AreEqual(1, FCUT.Count);
  SetLength(V, 1);
  V[0] := FKeys[1];
  CheckItems(V, [20]);

  FCUT.Remove(FKeys[1]);
  Assert.AreEqual(0, FCUT.Count);
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
  C: IEqualityComparer<TKey>;
  I: Integer;
begin
  FillDictionary;
  C := TEqualityComparer<TKey>.Default;
  A := FCUT.ToArray;
  Assert.AreEqual<Integer>(3, Length(A));
  for I := 0 to 2 do
  begin
    if C.Equals(A[I].Key, FKeys[0]) then
      Assert.AreEqual(10, A[I].Value)
    else if C.Equals(A[I].Key, FKeys[1]) then
      Assert.AreEqual(20, A[I].Value)
    else if C.Equals(A[I].Key, FKeys[2]) then
      Assert.AreEqual(30, A[I].Value)
    else
      Assert.Fail('Unexpected key in dictionary');
  end;
end;

procedure TTestDictionaryByKey<TKey>.TestTryGetValue;
var
  RogueKey: TKey;
  Value: Integer;
begin
  FillDictionary;
  RogueKey := CreateValue(3);
  Assert.IsFalse(FCUT.TryGetValue(RogueKey, Value));
  Assert.AreEqual(Value, 0);

  Assert.IsTrue(FCUT.TryGetValue(FKeys[1], Value));
  Assert.AreEqual(Value, 20);
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
      Assert.Fail('Unexpected item');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

{ TTestDictionaryByValue<TValue> }

procedure TTestDictionaryByValue<TValue>.CheckItems(
  const AExpectedKeys: array of Integer; const AExpectedValues: TArray<TValue>);
var
  Value: TValue;
  I, Key: Integer;
begin
  Assert.AreEqual<Integer>(Length(AExpectedKeys), FCUT.Count);
  Assert.AreEqual<Integer>(Length(AExpectedValues), FCUT.Count);

  for I := 0 to Length(AExpectedKeys) - 1 do
  begin
    Key := AExpectedKeys[I];
    Assert.IsTrue(FCUT.TryGetValue(Key, Value));
    TestEquals(AExpectedValues[I], Value);
  end;
end;

procedure TTestDictionaryByValue<TValue>.FillDictionary;
begin
  FValues := CreateValues(3);
  FCUT.Add(10, FValues[0]);
  FCUT.Add(20, FValues[1]);
  FCUT.Add(30, FValues[2]);
end;

procedure TTestDictionaryByValue<TValue>.SetUp;
begin
  inherited;
  FCUT := TDictionary<Integer, TValue>.Create;
end;

procedure TTestDictionaryByValue<TValue>.TearDown;
begin
  FCUT.Free;
  inherited;
end;

procedure TTestDictionaryByValue<TValue>.TestAdd;
begin
  FillDictionary;
  CheckItems([10, 20, 30], FValues);
end;

procedure TTestDictionaryByValue<TValue>.TestAddOrSetValue;
var
  Values, NewValues: TArray<TValue>;
begin
  Values := CreateValues(5);
  FCUT.Add(10, Values[0]);
  FCUT.Add(20, Values[1]);
  FCUT.Add(30, Values[2]);
  Assert.AreEqual(3, FCUT.Count);

  FCUT.AddOrSetValue(20, Values[3]);
  Assert.AreEqual(3, FCUT.Count);

  FCUT.AddOrSetValue(40, Values[4]);

  SetLength(NewValues, 4);
  NewValues[0] := Values[0];
  NewValues[1] := Values[3];
  NewValues[2] := Values[2];
  NewValues[3] := Values[4];
  CheckItems([10, 20, 30, 40], NewValues);
end;

procedure TTestDictionaryByValue<TValue>.TestClear;
begin
  FillDictionary;
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Clear;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestDictionaryByValue<TValue>.TestContainsKey;
begin
  FillDictionary;
  Assert.IsTrue(FCUT.ContainsKey(10));
  Assert.IsTrue(FCUT.ContainsKey(20));
  Assert.IsTrue(FCUT.ContainsKey(30));
  Assert.IsFalse(FCUT.ContainsKey(40));
end;

procedure TTestDictionaryByValue<TValue>.TestContainsValue;
var
  RogueValue: TValue;
begin
  FillDictionary;
  RogueValue := CreateValue(3);
  Assert.IsTrue(FCUT.ContainsValue(FValues[0]));
  Assert.IsTrue(FCUT.ContainsValue(FValues[1]));
  Assert.IsTrue(FCUT.ContainsValue(FValues[2]));
  Assert.IsFalse(FCUT.ContainsValue(RogueValue));
end;

procedure TTestDictionaryByValue<TValue>.TestGetEnumerator;
var
  Pair: TPair;
  B: Byte;
  C: IEqualityComparer<TValue>;
begin
  FillDictionary;
  C := TEqualityComparer<TValue>.Default;
  B := 0;
  for Pair in FCUT do
  begin
    if (Pair.Key = 10) then
    begin
      B := B or $01;
      Assert.IsTrue(C.Equals(Pair.Value, FValues[0]))
    end
    else if (Pair.Key = 20) then
    begin
      B := B or $02;
      Assert.IsTrue(C.Equals(Pair.Value, FValues[1]))
    end
    else if (Pair.Key = 30) then
    begin
      B := B or $04;
      Assert.IsTrue(C.Equals(Pair.Value, FValues[2]))
    end
    else
      Assert.Fail('Unexpected item');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

procedure TTestDictionaryByValue<TValue>.TestGetItem;
begin
  FillDictionary;
  TestEquals(FValues[0], FCUT[10]);
  TestEquals(FValues[1], FCUT[20]);
  TestEquals(FValues[2], FCUT[30]);
end;

procedure TTestDictionaryByValue<TValue>.TestKeys;
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
      Assert.Fail('Unexpected item');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

procedure TTestDictionaryByValue<TValue>.TestRemove;
var
  V: TArray<TValue>;
begin
  FillDictionary;
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Remove(40);
  Assert.AreEqual(3, FCUT.Count);
  CheckItems([10, 20, 30], FValues);

  FCUT.Remove(10);
  Assert.AreEqual(2, FCUT.Count);
  SetLength(V, 2);
  V[0] := FValues[1];
  V[1] := FValues[2];
  CheckItems([20, 30], V);

  FCUT.Remove(30);
  Assert.AreEqual(1, FCUT.Count);
  SetLength(V, 1);
  V[0] := FValues[1];
  CheckItems([20], V);

  FCUT.Remove(20);
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestDictionaryByValue<TValue>.TestSetItem;
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

procedure TTestDictionaryByValue<TValue>.TestToArray;
var
  A: TArray<TPair>;
  I: Integer;
begin
  FillDictionary;
  A := FCUT.ToArray;
  Assert.AreEqual<Integer>(3, Length(A));
  for I := 0 to 2 do
  begin
    if (A[I].Key = 10) then
      TestEquals(FValues[0], A[I].Value)
    else if (A[I].Key = 20) then
      TestEquals(FValues[1], A[I].Value)
    else if (A[I].Key = 30) then
      TestEquals(FValues[2], A[I].Value)
    else
      Assert.Fail('Unexpected key in dictionary');
  end;
end;

procedure TTestDictionaryByValue<TValue>.TestTryGetValue;
var
  Value, NullValue: TValue;
  C: IEqualityComparer<TValue>;
begin
  FillDictionary;
  C := TEqualityComparer<TValue>.Default;
  NullValue := Default(TValue);

  Assert.IsFalse(FCUT.TryGetValue(40, Value));
  Assert.IsTrue(C.Equals(NullValue, Value));

  Assert.IsTrue(FCUT.TryGetValue(20, Value));
  Assert.IsTrue(C.Equals(FValues[1], Value));
end;

procedure TTestDictionaryByValue<TValue>.TestValues;
var
  Value: TValue;
  B: Byte;
  C: IEqualityComparer<TValue>;
begin
  FillDictionary;
  C := TEqualityComparer<TValue>.Default;
  B := 0;
  for Value in FCUT.Values do
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

{ TTestObjectDictionary }

procedure TTestObjectDictionary.CheckItems(const AExpectedKeysIndices,
  AExpectedValues: array of Integer);
var
  I: Integer;
  Key: TFoo;
  Value: TBar;
begin
  Assert.AreEqual(Length(AExpectedKeysIndices), FCUT.Count);
  Assert.AreEqual(Length(AExpectedValues), FCUT.Count);

  for I := 0 to Length(AExpectedKeysIndices) - 1 do
  begin
    Key := FKeys[AExpectedKeysIndices[I]];
    Assert.IsTrue(FCUT.TryGetValue(Key, Value));
    Assert.AreEqual(AExpectedValues[I], Value.Value);
  end;
end;

procedure TTestObjectDictionary.FillDictionary;
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

procedure TTestObjectDictionary.SetUp;
begin
  inherited;
  FCUT := TObjectDictionary<TFoo, TBar>.Create([doOwnsKeys, doOwnsValues]);
end;

procedure TTestObjectDictionary.TearDown;
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

procedure TTestObjectDictionary.TestAdd;
begin
  FillDictionary;
  CheckItems([0, 1, 2], [10, 20, 30]);
end;

procedure TTestObjectDictionary.TestAddOrSetValue;
begin
  FillDictionary;
  // 0:1>10, 1:2>20, 2:3>30
  Assert.AreEqual(3, FCUT.Count);

  FCUT.AddOrSetValue(FKeys[1], TBar.Create(40));
  // 0:1>10, 1:2>40, 2:3>30
  Assert.AreEqual(3, FCUT.Count);

  SetLength(FKeys, 4);
  FKeys[3] := TFoo.Create(4);
  // 0:1>10, 1:2>40, 2:3>30, 3:4>50
  FCUT.AddOrSetValue(FKeys[3], TBar.Create(50));

  CheckItems([0, 1, 2, 3], [10, 40, 30, 50]);
end;

procedure TTestObjectDictionary.TestClear;
begin
  FillDictionary;
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Clear;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestObjectDictionary.TestContainsKey;
var
  RogueKey: TFoo;
begin
  FillDictionary;
  RogueKey := TFoo.Create(5);
  Assert.IsTrue(FCUT.ContainsKey(FKeys[0]));
  Assert.IsTrue(FCUT.ContainsKey(FKeys[1]));
  Assert.IsTrue(FCUT.ContainsKey(FKeys[2]));
  Assert.IsFalse(FCUT.ContainsKey(RogueKey));
  RogueKey.Free;
end;

procedure TTestObjectDictionary.TestContainsValue;
var
  RogueValue: TBar;
begin
  FillDictionary;
  RogueValue := TBar.Create(5);
  Assert.IsTrue(FCUT.ContainsValue(FValues[0]));
  Assert.IsTrue(FCUT.ContainsValue(FValues[1]));
  Assert.IsTrue(FCUT.ContainsValue(FValues[2]));
  Assert.IsFalse(FCUT.ContainsValue(RogueValue));
  RogueValue.Free;
end;

procedure TTestObjectDictionary.TestExtractPair;
var
  RogueKey: TFoo;
  Pair: TPair<TFoo, TBar>;
begin
  FillDictionary;
  RogueKey := TFoo.Create(5);

  Pair := FCUT.ExtractPair(RogueKey);
  Assert.AreSame(RogueKey, Pair.Key);
  Assert.AreEqual<TBar>(nil, Pair.Value);
  RogueKey.Free;

  Assert.IsTrue(FCUT.ContainsKey(FKeys[1]));
  Pair := FCUT.ExtractPair(FKeys[1]);
  Assert.AreSame(FKeys[1], Pair.Key);
  Assert.AreSame(FValues[1], Pair.Value);
  Assert.IsFalse(FCUT.ContainsKey(FKeys[1]));
  Pair.Key.Free;
  Pair.Value.Free;
end;

procedure TTestObjectDictionary.TestGetEnumerator;
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
      Assert.AreEqual(10, Pair.Value.Value)
    end
    else if (Pair.Key.Value = 2) then
    begin
      B := B or $02;
      Assert.AreEqual(20, Pair.Value.Value)
    end
    else if (Pair.Key.Value = 3) then
    begin
      B := B or $04;
      Assert.AreEqual(30, Pair.Value.Value)
    end
    else
      Assert.Fail('Unexpected item');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

procedure TTestObjectDictionary.TestGetItem;
begin
  FillDictionary;
  Assert.AreSame(FValues[0], FCUT[FKeys[0]]);
  Assert.AreSame(FValues[1], FCUT[FKeys[1]]);
  Assert.AreSame(FValues[2], FCUT[FKeys[2]]);
end;

procedure TTestObjectDictionary.TestKeys;
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
      Assert.Fail('Unexpected item');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

procedure TTestObjectDictionary.TestRemove;
var
  RogueKey: TFoo;
begin
  FillDictionary;
  Assert.AreEqual(3, FCUT.Count);

  RogueKey := TFoo.Create(5);
  FCUT.Remove(RogueKey);
  Assert.AreEqual(3, FCUT.Count);
  CheckItems([0, 1, 2], [10, 20, 30]);
  RogueKey.Free;

  FCUT.Remove(FKeys[0]);
  Assert.AreEqual(2, FCUT.Count);
  CheckItems([1, 2], [20, 30]);

  FCUT.Remove(FKeys[2]);
  Assert.AreEqual(1, FCUT.Count);
  CheckItems([1], [20]);

  FCUT.Remove(FKeys[1]);
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestObjectDictionary.TestSetItem;
begin
  FillDictionary;
  // 0:1>10, 1:2>20, 2:3>30
  FCUT[FKeys[0]] := TBar.Create(40);
  FCUT[FKeys[2]] := TBar.Create(50);

  CheckItems([0, 1, 2], [40, 20, 50]);
end;

procedure TTestObjectDictionary.TestToArray;
var
  A: TArray<TPair>;
  I: Integer;
begin
  FillDictionary;
  A := FCUT.ToArray;
  Assert.AreEqual<Integer>(3, Length(A));
  for I := 0 to 2 do
  begin
    if (A[I].Key.Value = 1) then
      Assert.AreEqual(10, A[I].Value.Value)
    else if (A[I].Key.Value = 2) then
      Assert.AreEqual(20, A[I].Value.Value)
    else if (A[I].Key.Value = 3) then
      Assert.AreEqual(30, A[I].Value.Value)
    else
      Assert.Fail('Unexpected key in dictionary');
  end;
end;

procedure TTestObjectDictionary.TestTryGetValue;
var
  RogueKey: TFoo;
  Value: TBar;
begin
  FillDictionary;
  RogueKey := CreateValue(5);
  Assert.IsFalse(FCUT.TryGetValue(RogueKey, Value));
  Assert.AreEqual<TBar>(nil, Value);

  Assert.IsTrue(FCUT.TryGetValue(FKeys[1], Value));
  Assert.AreEqual(20, Value.Value);
end;

procedure TTestObjectDictionary.TestValues;
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
      Assert.Fail('Unexpected item');
  end;
  Assert.AreEqual<Byte>($07, B);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<ShortInt>);
  {$IFNDEF LIMITED_GENERICS}
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Byte>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<SmallInt>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Word>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Integer>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Cardinal>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Boolean>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TDigit>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TDigits>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Single>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Double>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Extended>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Comp>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Currency>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TFoo>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<IBaz>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<PInteger>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TTestProc>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TTestMethod>);
  {$IFNDEF NEXTGEN}
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<ShortString>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<AnsiString>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<WideString>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<AnsiChar>);
  {$ENDIF}
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<RawByteString>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<UnicodeString>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Variant>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<Int64>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<UInt64>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TBytes>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<WideChar>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TTestArray>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TSimpleRecord>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TManagedRecord>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TFooBarRecord>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TManagedArray>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByKey<TFooBarArray>);

  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<ShortInt>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Byte>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<SmallInt>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Word>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Integer>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Cardinal>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Boolean>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TDigit>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TDigits>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Single>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Double>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Extended>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Comp>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Currency>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TFoo>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<IBaz>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<PInteger>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TTestProc>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TTestMethod>);
  {$IFNDEF NEXTGEN}
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<ShortString>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<AnsiString>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<WideString>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<AnsiChar>);
  {$ENDIF}
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<RawByteString>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<UnicodeString>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Variant>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<Int64>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<UInt64>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TBytes>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<WideChar>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TTestArray>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TSimpleRecord>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TManagedRecord>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TFooBarRecord>);
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TManagedArray>);
  {$ENDIF !LIMITED_GENERICS}
  TDUnitX.RegisterTestFixture(TTestDictionaryByValue<TFooBarArray>);
  TDUnitX.RegisterTestFixture(TTestObjectDictionary);
end.
