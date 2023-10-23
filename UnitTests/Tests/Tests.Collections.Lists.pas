unit Tests.Collections.Lists;

interface

uses
  DUnitX.TestFramework,
  System.Generics.Defaults,
  Tests.Collections.Base,
  Neslib.Collections;

type
  TTestList<T> = class(TTestCollectionBase<T>)
  private const
    LIMIT = 1000;
  private
    FCUT: TList<T>;
    FSimpleValues: TArray<T>;
    procedure SimpleFillList;
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestInit;
    [Test] procedure TestAdd;
    [Test] procedure TestAddRangeArray;
    [Test] procedure TestAddRangeTgrEnumerable;
    [Test] procedure TestInsert;
    [Test] procedure TestInsertBetween;
    [Test] procedure TestInsertBeginning;
    [Test] procedure TestInsertRangeArray;
    [Test] procedure TestInsertRangeTgrEnumerable;
    [Test] procedure TestListSimpleDelete;
    [Test] procedure TestListMultipleDelete;
    [Test] procedure TestListSimpleExchange;
    [Test] procedure TestListReverse;
    [Test] procedure TestListSortDefault;
    [Test] procedure TestListSortIComparer;
    [Test] procedure TestListSortCompareFunc;
    [Test] procedure TestListIndexOf;
    [Test] procedure TestLastIndexOf;
    [Test] procedure TestListMove;
    [Test] procedure TestListClear;
    [Test] procedure TestListLargeDelete;
    [Test] procedure TestRemove;
    [Test] procedure TestRemoveItem;
    [Test] procedure TestDeleteRange;
    [Test] procedure TestFirst;
    [Test] procedure TestLast;
    [Test] procedure TestContains;
    [Test] procedure TestIndexOf;
    [Test] procedure TestIndexOfItem;
    [Test] procedure TestBinarySearchDefault;
    [Test] procedure TestBinarySearchIComparer;
    [Test] procedure TestBinarySearchCompareFunc;
    [Test] procedure TestToArray;
    [Test] procedure TestGetEnumerator;
    [Test] procedure TestGetCapacityAndCount;
    [Test] procedure TestSetCountIncrease;
    [Test] procedure TestSetCountDecrease;
    [Test] procedure TestTrimExcess;
    [Test] procedure TestSetItem;
  end;

type
  TTestSortedList = class
  private
    FCUT: TSortedList<Integer>;
    FValues: TArray<Integer>;
    procedure SimpleFillList;
    procedure CreateRandomValuesWithoutDuplicates;
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestInit;
    [Test] procedure TestAdd;
    [Test] procedure TestAddRangeArray;
    [Test] procedure TestAddRangeTgrEnumerable;
    [Test] procedure TestListSimpleDelete;
    [Test] procedure TestListMultipleDelete;
    [Test] procedure TestListIndexOf;
    [Test] procedure TestLastIndexOf;
    [Test] procedure TestListClear;
    [Test] procedure TestListLargeDelete;
    [Test] procedure TestRemove;
    [Test] procedure TestRemoveItem;
    [Test] procedure TestDeleteRange;
    [Test] procedure TestFirst;
    [Test] procedure TestLast;
    [Test] procedure TestContains;
    [Test] procedure TestIndexOf;
    [Test] procedure TestIndexOfItem;
    [Test] procedure TestToArray;
    [Test] procedure TestGetEnumerator;
    [Test] procedure TestGetCapacityAndCount;
    [Test] procedure TestDuplicatesAccept;
    [Test] procedure TestDuplicatesIgnore;
    [Test] procedure TestDuplicatesError;
    [Test] procedure TestCustomComparer;
  end;

type
  TTestObjectList = class(TTestCollectionBase<TFoo>)
  private
    FCUT: TObjectList<TFoo>;
    procedure SimpleFillList;
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestAdd;
    [Test] procedure TestDelete;
    [Test] procedure TestDeleteRange;
    [Test] procedure TestRemove;
    [Test] procedure TestRemoveItem;
    [Test] procedure TestExtract;
    [Test] procedure TestExtractItem;
    [Test] procedure TestSetItem;
  end;

type
  TTestSortedObjectList = class(TTestCollectionBase<TFoo>)
  private
    FCUT: TSortedObjectList<TFoo>;
    procedure SimpleFillList;
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestAdd;
    [Test] procedure TestDelete;
    [Test] procedure TestDeleteRange;
    [Test] procedure TestRemove;
    [Test] procedure TestRemoveItem;
    [Test] procedure TestExtract;
    [Test] procedure TestExtractItem;
  end;

type
  TIntList = TList<Integer>;

type
  TReverseComparer<T> = class(TComparer<T>)
  private
    FOriginalComparer: IComparer<T>;
  public
    constructor Create(const AOriginalComparer: IComparer<T>);
    function Compare(const Left, Right: T): Integer; override;
  end;

type
  TFooComparer = class(TComparer<TFoo>)
  public
    function Compare(const Left, Right: TFoo): Integer; override;
  end;

implementation

uses
  System.Types,
  System.SysUtils;

{ TReverseComparer<T> }

function TReverseComparer<T>.Compare(const Left, Right: T): Integer;
begin
  Result := FOriginalComparer.Compare(Right, Left);
end;

constructor TReverseComparer<T>.Create(const AOriginalComparer: IComparer<T>);
begin
  inherited Create;
  FOriginalComparer := AOriginalComparer;
end;

{ TFooComparer }

function TFooComparer.Compare(const Left, Right: TFoo): Integer;
begin
  Result := Left.Value - Right.Value;
end;

{ TTestList<T> }

procedure TTestList<T>.SetUp;
begin
  inherited SetUp;
  FCUT := TList<T>.Create;
end;

procedure TTestList<T>.SimpleFillList;
begin
  Assert.IsNotNull(FCUT);
  FSimpleValues := CreateValues([1, 2, 3]);
  FCUT.Add(FSimpleValues[0]);
  FCUT.Add(FSimpleValues[1]);
  FCUT.Add(FSimpleValues[2]);
end;

procedure TTestList<T>.TearDown;
begin
  inherited TearDown;
  FCUT.Free;
end;

procedure TTestList<T>.TestAdd;
var
  I: Integer;
  Values: TArray<T>;
begin
  Values := CreateValues(LIMIT);
  for I := 0 to LIMIT - 1 do
  begin
    Assert.AreEqual(I, FCUT.Count);
    Assert.AreEqual(I, FCUT.Add(Values[I]));
    TestEquals(Values[I], FCUT[I]);
  end;
end;

procedure TTestList<T>.TestAddRangeArray;
var
  Values: TArray<T>;
begin
  Values := CreateValues(4);
  FCUT.AddRange(Values);
  Assert.AreEqual(4, FCUT.Count);
  TestEquals(Values[0], FCUT[0]);
  TestEquals(Values[1], FCUT[1]);
  TestEquals(Values[2], FCUT[2]);
  TestEquals(Values[3], FCUT[3]);
end;

procedure TTestList<T>.TestAddRangeTgrEnumerable;
var
  Values: TArray<T>;
  Src: TList<T>;
begin
  Values := CreateValues(4);
  Src := TList<T>.Create;
  try
    Src.AddRange(Values);
    FCUT.AddRange(Src);
  finally
    Src.Free;
  end;
  Assert.AreEqual(4, FCUT.Count);
  TestEquals(Values[0], FCUT[0]);
  TestEquals(Values[1], FCUT[1]);
  TestEquals(Values[2], FCUT[2]);
  TestEquals(Values[3], FCUT[3]);
end;

procedure TTestList<T>.TestBinarySearchCompareFunc;
var
  CUT: TIntList;
  Index: Integer;
  Comparer: IComparer<Integer>;
begin
  { This test is specialized for integers }
  Comparer := TReverseComparer<Integer>.Create(TComparer<Integer>.Default);
  CUT := TIntList.Create;
  try
    CUT.AddRange([6, 0, 2, 5, 7, 1, 8, 3, 4, 9]);
    CUT.Sort(Comparer);
    Assert.IsFalse(CUT.BinarySearch(10, Index, Comparer));
    Assert.IsTrue(CUT.BinarySearch(6, Index, Comparer));
    Assert.AreEqual(3, Index);
  finally
    CUT.Free;
  end;
end;

procedure TTestList<T>.TestBinarySearchDefault;
var
  Values: TArray<T>;
  V10: T;
  Index: Integer;
begin
  if (not Comparable) then
    Exit;

  Values := CreateValues([6, 0, 2, 5, 7, 1, 8, 3, 4, 9]);
  V10 := CreateValue(10);
  FCUT.AddRange(Values);
  FCUT.Sort;
  Assert.IsFalse(FCUT.BinarySearch(V10, Index));
  Assert.IsTrue(FCUT.BinarySearch(Values[0], Index));
  Assert.AreEqual(6, Index);
end;

procedure TTestList<T>.TestBinarySearchIComparer;
var
  Values: TArray<T>;
  V10: T;
  Comparer: IComparer<T>;
  Index: Integer;
begin
  if (not Comparable) then
    Exit;

  Values := CreateValues([6, 0, 2, 5, 7, 1, 8, 3, 4, 9]);
  V10 := CreateValue(10);
  FCUT.AddRange(Values);

  Comparer := TReverseComparer<T>.Create(TComparer<T>.Default);
  FCUT.Sort(Comparer);
  Assert.IsFalse(FCUT.BinarySearch(V10, Index, Comparer));
  Assert.IsTrue(FCUT.BinarySearch(Values[0], Index, Comparer));
  Assert.AreEqual(3, Index);
end;

procedure TTestList<T>.TestContains;
var
  Values: TArray<T>;
  V0, V1: T;
begin
  if (not Comparable) then
    Exit;

  Values := CreateValues([2, 3, 5, 8]);
  V0 := CreateValue(0);
  V1 := CreateValue(0);

  Assert.IsFalse(FCUT.Contains(V0));

  FCUT.AddRange(Values);
  Assert.IsFalse(FCUT.Contains(V1));
  Assert.IsTrue(FCUT.Contains(Values[0]));
  Assert.IsTrue(FCUT.Contains(Values[3]));
end;

procedure TTestList<T>.TestDeleteRange;
var
  Values: TArray<T>;
begin
  Values := CreateValues([1, 2, 3, 2, 1]);
  FCUT.AddRange(Values);
  FCUT.DeleteRange(1, 3);
  Assert.AreEqual(2, FCUT.Count);
  TestEquals(Values[0], FCUT[0]);
  TestEquals(Values[4], FCUT[1]);
end;

procedure TTestList<T>.TestFirst;
var
  Values: TArray<T>;
begin
  Values := CreateValues([2, 3, 5, 8]);
  FCUT.AddRange(Values);
  TestEquals(Values[0], FCUT.First);
end;

procedure TTestList<T>.TestGetCapacityAndCount;
var
  Values: TArray<T>;
  Value: T;
begin
  Value := CreateValue(1);
  Values := CreateValues([1, 1]);

  Assert.AreEqual(0, FCUT.Count);
  Assert.AreEqual(0, FCUT.Capacity);

  FCUT.Add(Value);
  Assert.AreEqual(1, FCUT.Count);
  {$IF (RTLVersion >= 33)}
  Assert.AreEqual(4, FCUT.Capacity);
  {$ELSE}
  Assert.AreEqual(1, FCUT.Capacity);
  {$ENDIF}

  FCUT.Add(Value);
  Assert.AreEqual(2, FCUT.Count);
  {$IF (RTLVersion >= 33)}
  Assert.AreEqual(4, FCUT.Capacity);
  {$ELSE}
  Assert.AreEqual(2, FCUT.Capacity);
  {$ENDIF}

  FCUT.Add(Value);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.AddRange(Values);
  Assert.AreEqual(5, FCUT.Count);
  Assert.AreEqual(8, FCUT.Capacity);

  FCUT.Delete(0);
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(8, FCUT.Capacity);

  FCUT.Delete(0);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(8, FCUT.Capacity);

  FCUT.TrimExcess;
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(3, FCUT.Capacity);

  FCUT.DeleteRange(0, 3);
  Assert.AreEqual(0, FCUT.Count);
  Assert.AreEqual(3, FCUT.Capacity);
end;

procedure TTestList<T>.TestGetEnumerator;
var
  Values: TArray<T>;
  Item: T;
  I: Integer;
begin
  Values := CreateValues([0, 1, 2, 3]);
  FCUT.AddRange(Values);
  I := 0;
  for Item in FCUT do
  begin
    TestEquals(Values[I], Item);
    Inc(I);
  end;
end;

procedure TTestList<T>.TestIndexOf;
var
  Values: TArray<T>;
  V1: T;
begin
  if (not Comparable) then
    Exit;

  Values := CreateValues([2, 2, 3, 5, 8]);
  V1 := CreateValue(1);
  FCUT.AddRange(Values);

  Assert.AreEqual(-1, FCUT.IndexOf(V1));
  Assert.AreEqual(0, FCUT.IndexOf(Values[0]));
  Assert.AreEqual(2, FCUT.IndexOf(Values[2]));
end;

procedure TTestList<T>.TestIndexOfItem;
var
  Values: TArray<T>;
  V1: T;
begin
  if (not Comparable) then
    Exit;

  Values := CreateValues([2, 2, 3, 5, 8]);
  V1 := CreateValue(1);
  FCUT.AddRange(Values);

  Assert.AreEqual(-1, FCUT.IndexOfItem(V1, TDirection.FromBeginning));
  Assert.AreEqual(0, FCUT.IndexOfItem(Values[0], TDirection.FromBeginning));
  Assert.AreEqual(1, FCUT.IndexOfItem(Values[1], TDirection.FromEnd));
end;

procedure TTestList<T>.TestInit;
begin
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestList<T>.TestInsert;
var
  Values: TArray<T>;
  I: Integer;
begin
  Values := CreateValues(LIMIT);
  for I := 0 to LIMIT - 1 do
  begin
    Assert.AreEqual(I, FCUT.Count);
    FCUT.Insert(0, Values[I]);
    TestEquals(Values[I], FCUT[0]);
  end;
end;

procedure TTestList<T>.TestInsertBeginning;
var
  Values: TArray<T>;
begin
  Values := CreateValues([0, 1, 42]);
  FCUT.Add(Values[0]);
  FCUT.Add(Values[1]);
  FCUT.Insert(0, Values[2]);
  Assert.AreEqual(3, FCUT.Count);
  TestEquals(Values[2], FCUT[0]);
  TestEquals(Values[0], FCUT[1]);
  TestEquals(Values[1], FCUT[2]);
end;

procedure TTestList<T>.TestInsertBetween;
var
  Values: TArray<T>;
begin
  Values := CreateValues([0, 1, 42]);
  FCUT.Add(Values[0]);
  FCUT.Add(Values[1]);
  FCUT.Insert(1, Values[2]);
  Assert.AreEqual(3, FCUT.Count);
  TestEquals(Values[0], FCUT[0]);
  TestEquals(Values[2], FCUT[1]);
  TestEquals(Values[1], FCUT[2]);
end;

procedure TTestList<T>.TestInsertRangeArray;
var
  Values1, Values2: TArray<T>;
begin
  Values1 := CreateValues([1, 13]);
  Values2 := CreateValues([2, 3, 5, 8]);

  FCUT.Add(Values1[0]);
  FCUT.Add(Values1[1]);

  FCUT.InsertRange(1, Values2);
  Assert.AreEqual(6, FCUT.Count);
  TestEquals(Values1[0], FCUT[0]);
  TestEquals(Values2[0], FCUT[1]);
  TestEquals(Values2[1], FCUT[2]);
  TestEquals(Values2[2], FCUT[3]);
  TestEquals(Values2[3], FCUT[4]);
  TestEquals(Values1[1], FCUT[5]);
end;

procedure TTestList<T>.TestInsertRangeTgrEnumerable;
var
  Values1, Values2: TArray<T>;
  Src: TList<T>;
begin
  Values1 := CreateValues([1, 13]);
  Values2 := CreateValues([2, 3, 5, 8]);

  FCUT.Add(Values1[0]);
  FCUT.Add(Values1[1]);
  Src := TList<T>.Create;
  try
    Src.Add(Values2[0]);
    Src.Add(Values2[1]);
    Src.Add(Values2[2]);
    Src.Add(Values2[3]);
    FCUT.InsertRange(1, Src);
  finally
    Src.Free;
  end;
  Assert.AreEqual(6, FCUT.Count);
  TestEquals(Values1[0], FCUT[0]);
  TestEquals(Values2[0], FCUT[1]);
  TestEquals(Values2[1], FCUT[2]);
  TestEquals(Values2[2], FCUT[3]);
  TestEquals(Values2[3], FCUT[4]);
  TestEquals(Values1[1], FCUT[5]);
end;

procedure TTestList<T>.TestLast;
var
  Values: TArray<T>;
begin
  Values := CreateValues([2, 3, 5, 8]);
  FCUT.AddRange(Values);
  TestEquals(Values[3], FCUT.Last);
end;

procedure TTestList<T>.TestLastIndexOf;
var
  Values: TArray<T>;
begin
  if (not Comparable) then
    Exit;

  Values := CreateValues([1, 1, 1, 2, 3]);
  FCUT.AddRange(Values);

  Assert.AreEqual(2, FCUT.LastIndexOf(Values[1]));
end;

procedure TTestList<T>.TestListClear;
var
  Values: TArray<T>;
begin
  Values := CreateValues(LIMIT);
  FCUT.AddRange(Values);
  Assert.AreEqual(LIMIT, FCUT.Count);

  FCUT.Clear;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestList<T>.TestListIndexOf;
var
  Values: TArray<T>;
  RogueValue: T;
  I: Integer;
begin
  if (not Comparable) then
    Exit;

  Values := CreateValues(100);
  RogueValue := CreateValue(110);
  FCUT.AddRange(Values);
  Assert.AreEqual(100, FCUT.Count);

  for I := 0 to 99 do
    Assert.AreEqual(I, FCUT.IndexOf(Values[I]));

  Assert.AreEqual(-1, FCUT.IndexOf(RogueValue));
end;

procedure TTestList<T>.TestListLargeDelete;
var
  Values: TArray<T>;
  I: Integer;
begin
  Values := CreateValues(LIMIT + 1);
  FCUT.AddRange(Values);
  Assert.AreEqual(LIMIT + 1, FCUT.Count);

  for I := 0 to LIMIT do
    FCUT.Delete(0);

  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestList<T>.TestListMove;
begin
  SimpleFillList;
  Assert.AreEqual(3, FCUT.Count);

  FCUT.Move(0, 2);
  Assert.AreEqual(3, FCUT.Count);

  TestEquals(FSimpleValues[1], FCUT[0]);
  TestEquals(FSimpleValues[2], FCUT[1]);
  TestEquals(FSimpleValues[0], FCUT[2]);
end;

procedure TTestList<T>.TestListMultipleDelete;
begin
  SimpleFillList;
  Assert.AreEqual(3, FCUT.Count);
  FCUT.Delete(0);
  Assert.AreEqual(2, FCUT.Count);
  FCUT.Delete(0);
  Assert.AreEqual(1, FCUT.Count);
  FCUT.Delete(0);
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestList<T>.TestListReverse;
var
  Values: TArray<T>;
  I: Integer;
begin
  Values := CreateValues(LIMIT + 1);
  for I := 0 to LIMIT do
    FCUT.Add(Values[I]);
  Assert.AreEqual(LIMIT + 1, FCUT.Count);

  FCUT.Reverse;

  for I := LIMIT downto 0 do
    TestEquals(Values[I], FCUT[LIMIT - I]);
end;

procedure TTestList<T>.TestListSimpleDelete;
var
  Value: T;
begin
  Value := CreateValue(1);
  FCUT.Add(Value);
  Assert.AreEqual(1, FCUT.Count);
  FCUT.Delete(0);
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestList<T>.TestListSimpleExchange;
var
  Values: TArray<T>;
begin
  Values := CreateValues([0, 1]);
  FCUT.Add(Values[0]);
  FCUT.Add(Values[1]);
  Assert.AreEqual(2, FCUT.Count);
  FCUT.Exchange(0, 1);
  Assert.AreEqual(2, FCUT.Count);
  TestEquals(Values[0], FCUT[1]);
  TestEquals(Values[1], FCUT[0]);
end;

procedure TTestList<T>.TestListSortCompareFunc;
var
  Comparer: IComparer<Integer>;
  CUT: TIntList;
  I: Integer;
begin
  Comparer := TReverseComparer<Integer>.Create(TComparer<Integer>.Default);
  { This test is specialized for Integers }
  CUT := TIntList.Create;
  try
    CUT.Add(6);
    CUT.Add(0);
    CUT.Add(2);
    CUT.Add(5);
    CUT.Add(7);
    CUT.Add(1);
    CUT.Add(8);
    CUT.Add(3);
    CUT.Add(4);
    CUT.Add(9);
    Assert.AreEqual(10, CUT.Count);

    CUT.Sort(Comparer);

    for I := 0 to 9 do
      Assert.AreEqual(9 - I, CUT[I]);
  finally
    CUT.Free;
  end;
end;

procedure TTestList<T>.TestListSortDefault;
var
  I: Integer;
  Values, Expected: TArray<T>;
begin
  if (not Comparable) then
    Exit;

  Values := CreateValues([6, 0, 2, 5, 7, 1, 8, 3, 4, 9]);
  Expected := CreateValues([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);

  FCUT.AddRange(Values);
  Assert.AreEqual(10, FCUT.Count);
  FCUT.Sort;
  for I := 0 to 9 do
    TestEquals(Expected[I], FCUT[I]);
end;

procedure TTestList<T>.TestListSortIComparer;
var
  I: Integer;
  Values, Expected: TArray<T>;
  Comparer: IComparer<T>;
begin
  if (not Comparable) then
    Exit;

  Values := CreateValues([6, 0, 2, 5, 7, 1, 8, 3, 4, 9]);
  Expected := CreateValues([9, 8, 7, 6, 5, 4, 3, 2, 1, 0]);

  FCUT.AddRange(Values);
  Assert.AreEqual(10, FCUT.Count);

  Comparer := TReverseComparer<T>.Create(TComparer<T>.Default);
  FCUT.Sort(Comparer);

  for I := 0 to 9 do
    TestEquals(Expected[I], FCUT[I]);
end;

procedure TTestList<T>.TestRemove;
var
  Values: TArray<T>;
  RogueValue: T;
begin
  if (TypeInfo.Kind = tkClassRef) then
    Exit;

  Values := CreateValues([1, 2, 3, 2, 1]);
  RogueValue := CreateValue(4);
  FCUT.AddRange(Values);
  Assert.AreEqual(-1, FCUT.Remove(RogueValue));
  Assert.AreEqual(5, FCUT.Count);

  Assert.AreEqual(1, FCUT.Remove(Values[1]));
  Assert.AreEqual(4, FCUT.Count);
  TestEquals(Values[0], FCUT[0]);
  TestEquals(Values[2], FCUT[1]);
  TestEquals(Values[3], FCUT[2]);
  TestEquals(Values[4], FCUT[3]);
end;

procedure TTestList<T>.TestRemoveItem;
var
  Values: TArray<T>;
  RogueValue: T;
begin
  if (not Comparable) then
    Exit;

  Values := CreateValues([1, 2, 3, 2, 1]);
  RogueValue := CreateValue(4);
  FCUT.AddRange(Values);

  Assert.AreEqual(-1, FCUT.RemoveItem(RogueValue, TDirection.FromBeginning));
  Assert.AreEqual(5, FCUT.Count);

  Assert.AreEqual(3, FCUT.RemoveItem(Values[3], TDirection.FromEnd));
  Assert.AreEqual(4, FCUT.Count);
  TestEquals(Values[0], FCUT[0]);
  TestEquals(Values[1], FCUT[1]);
  TestEquals(Values[2], FCUT[2]);
  TestEquals(Values[4], FCUT[3]);

  Assert.AreEqual(0, FCUT.RemoveItem(Values[0], TDirection.FromBeginning));
  Assert.AreEqual(3, FCUT.Count);
  TestEquals(Values[1], FCUT[0]);
  TestEquals(Values[2], FCUT[1]);
  TestEquals(Values[4], FCUT[2]);
end;

procedure TTestList<T>.TestSetCountDecrease;
var
  Values: TArray<T>;
begin
  if (TypeInfo.Kind = tkMethod) then
    Exit;

  Values := CreateValues([1, 2, 3, 2, 1]);
  FCUT.AddRange(Values);
  FCUT.Count := 3;

  Assert.AreEqual(3, FCUT.Count);
  {$IF (RTLVersion >= 33)}
  Assert.AreEqual(8, FCUT.Capacity);
  {$ELSE}
  Assert.AreEqual(5, FCUT.Capacity);
  {$ENDIF}

  TestEquals(Values[0], FCUT[0]);
  TestEquals(Values[1], FCUT[1]);
  TestEquals(Values[2], FCUT[2]);
end;

procedure TTestList<T>.TestSetCountIncrease;
var
  Values: TArray<T>;
begin
  if (TypeInfo.Kind = tkMethod) then
    Exit;

  Values := CreateValues([1, 2, 3, 2, 1]);
  FCUT.AddRange(Values);
  FCUT.Count := 7;

  Assert.AreEqual(7, FCUT.Count);
  {$IF (RTLVersion >= 33)}
  Assert.AreEqual(8, FCUT.Capacity);
  {$ELSE}
  Assert.AreEqual(7, FCUT.Capacity);
  {$ENDIF}

  TestEquals(Values[0], FCUT[0]);
  TestEquals(Values[1], FCUT[1]);
  TestEquals(Values[2], FCUT[2]);
  TestEquals(Values[3], FCUT[3]);
  TestEquals(Values[4], FCUT[4]);
  TestEquals(Default(T), FCUT[5]);
  TestEquals(Default(T), FCUT[6]);
end;

procedure TTestList<T>.TestSetItem;
var
  Values: TArray<T>;
  V4, V5: T;
begin
  Values := CreateValues([1, 2, 3, 2, 1]);
  V4 := CreateValue(4);
  V5 := CreateValue(5);
  FCUT.AddRange(Values);
  FCUT[1] := V4;
  FCUT[3] := V5;

  TestEquals(Values[0], FCUT[0]);
  TestEquals(V4, FCUT[1]);
  TestEquals(Values[2], FCUT[2]);
  TestEquals(V5, FCUT[3]);
  TestEquals(Values[4], FCUT[4]);
end;

procedure TTestList<T>.TestToArray;
var
  Values: TArray<T>;
  A: TArray<T>;
  I: Integer;
begin
  Values := CreateValues([2, 3, 5, 8]);
  FCUT.AddRange(Values);
  A := FCUT.ToArray;
  Assert.AreEqual<Integer>(FCUT.Count, Length(A));
  for I := 0 to FCUT.Count - 1 do
    TestEquals(FCUT[I], A[I]);
end;

procedure TTestList<T>.TestTrimExcess;
var
  I: Integer;
begin
  for I := 0 to 20 do
    FCUT.Add(CreateValue(I));

  Assert.AreEqual(21, FCUT.Count);
  {$IF (RTLVersion >= 33)}
  Assert.AreEqual(28, FCUT.Capacity);
  {$ELSE}
  Assert.AreEqual(32, FCUT.Capacity);
  {$ENDIF}

  FCUT.TrimExcess;
  Assert.AreEqual(21, FCUT.Count);
  Assert.AreEqual(21, FCUT.Capacity);
end;

{ TTestSortedList }

procedure TTestSortedList.CreateRandomValuesWithoutDuplicates;
var
  Sorted: TList<Integer>;
  I, J: Integer;
begin
  SetLength(FValues, 100);
  Sorted := TList<Integer>.Create;
  try
    for I := 0 to 99 do
      Sorted.Add(I);

    for I := 0 to 99 do
    begin
      J := Random(Sorted.Count);
      FValues[I] := Sorted[J];
      Sorted.Delete(J);
    end;
    Assert.AreEqual(0, Sorted.Count);
  finally
    Sorted.Free;
  end;
end;

procedure TTestSortedList.SetUp;
begin
  inherited;
  FCUT := TSortedList<Integer>.Create;
end;

procedure TTestSortedList.SimpleFillList;
begin
  Assert.IsNotNull(FCUT);
  FCUT.Add(2);
  FCUT.Add(1);
  FCUT.Add(3);
end;

procedure TTestSortedList.TearDown;
begin
  inherited;
  FCUT.Free;
end;

procedure TTestSortedList.TestAdd;
var
  I, J, Value: Integer;
  Values: TList<Integer>;
begin
  Values := TList<Integer>.Create;
  try
    for I := 0 to 99 do
      Values.Add(I);

    FCUT.Duplicates := dupError;
    for I := 0 to 99 do
    begin
      Assert.AreEqual(I, FCUT.Count);

      J := Random(Values.Count);
      Value := Values[J];
      Values.Delete(J);

      J := FCUT.Add(Value);
      Assert.AreEqual(Value, FCUT[J]);
    end;
    Assert.AreEqual(0, Values.Count);

    // Check sort order
    Assert.AreEqual(100, FCUT.Count);
    for I := 0 to 99 do
      Assert.AreEqual(I, FCUT[I]);
  finally
    Values.Free;
  end;
end;

procedure TTestSortedList.TestAddRangeArray;
var
  I: Integer;
begin
  CreateRandomValuesWithoutDuplicates;
  FCUT.AddRange(FValues);

  Assert.AreEqual(100, FCUT.Count);
  for I := 0 to 99 do
    Assert.AreEqual(I, FCUT[I]);
end;

procedure TTestSortedList.TestAddRangeTgrEnumerable;
var
  Src: TList<Integer>;
  I: Integer;
begin
  CreateRandomValuesWithoutDuplicates;
  Src := TList<Integer>.Create;
  try
    Src.AddRange(FValues);
    FCUT.AddRange(Src);
  finally
    Src.Free;
  end;

  Assert.AreEqual(100, FCUT.Count);
  for I := 0 to 99 do
    Assert.AreEqual(I, FCUT[I]);
end;

procedure TTestSortedList.TestContains;
begin
  FCUT.Add(3);
  FCUT.Add(2);
  FCUT.Add(8);
  FCUT.Add(5);
  Assert.IsFalse(FCUT.Contains(1));
  Assert.IsTrue(FCUT.Contains(2));
  Assert.IsTrue(FCUT.Contains(3));
end;

procedure TTestSortedList.TestCustomComparer;
var
  Comparer: IComparer<Integer>;
  CUT: TSortedList<Integer>;
  I: Integer;
begin
  Comparer := TReverseComparer<Integer>.Create(TComparer<Integer>.Default);
  CUT := TSortedList<Integer>.Create(Comparer);
  try
    CreateRandomValuesWithoutDuplicates;
    CUT.AddRange(FValues);
    for I := 0 to 99 do
      Assert.AreEqual(99 - I, CUT[I]);
  finally
    CUT.Free;
  end;
end;

procedure TTestSortedList.TestDeleteRange;
begin
  FCUT.Duplicates := dupAccept;
  FCUT.Add(1);
  FCUT.Add(2);
  FCUT.Add(1);
  FCUT.Add(3);
  FCUT.Add(1);
  FCUT.DeleteRange(1, 3);
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual(1, FCUT[0]);
  Assert.AreEqual(3, FCUT[1]);
end;

procedure TTestSortedList.TestDuplicatesAccept;
begin
  FCUT.Duplicates := dupAccept;
  FCUT.Add(1);
  FCUT.Add(2);
  FCUT.Add(1);
  FCUT.Add(3);
  FCUT.Add(1);
  Assert.AreEqual(5, FCUT.Count);
  Assert.AreEqual(1, FCUT[0]);
  Assert.AreEqual(1, FCUT[1]);
  Assert.AreEqual(1, FCUT[2]);
  Assert.AreEqual(2, FCUT[3]);
  Assert.AreEqual(3, FCUT[4]);
end;

procedure TTestSortedList.TestDuplicatesError;
begin
  Assert.WillRaise(
    procedure
    begin
      FCUT.Duplicates := dupError;
      FCUT.Add(1);
      FCUT.Add(2);
      FCUT.Add(1);
    end, EListError);
end;

procedure TTestSortedList.TestDuplicatesIgnore;
begin
  FCUT.Duplicates := dupIgnore;
  FCUT.Add(1);
  FCUT.Add(2);
  FCUT.Add(1);
  FCUT.Add(3);
  FCUT.Add(1);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(1, FCUT[0]);
  Assert.AreEqual(2, FCUT[1]);
  Assert.AreEqual(3, FCUT[2]);
end;

procedure TTestSortedList.TestFirst;
begin
  FCUT.Add(3);
  FCUT.Add(2);
  FCUT.Add(8);
  FCUT.Add(5);
  Assert.AreEqual(2, FCUT.First);
end;

procedure TTestSortedList.TestGetCapacityAndCount;
begin
  Assert.AreEqual(0, FCUT.Count);
  Assert.AreEqual(0, FCUT.Capacity);

  FCUT.Add(3);
  Assert.AreEqual(1, FCUT.Count);
  {$IF (RTLVersion >= 33)}
  Assert.AreEqual(4, FCUT.Capacity);
  {$ELSE}
  Assert.AreEqual(1, FCUT.Capacity);
  {$ENDIF}

  FCUT.Add(1);
  Assert.AreEqual(2, FCUT.Count);
  {$IF (RTLVersion >= 33)}
  Assert.AreEqual(4, FCUT.Capacity);
  {$ELSE}
  Assert.AreEqual(2, FCUT.Capacity);
  {$ENDIF}

  FCUT.Add(4);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.AddRange([5, 2]);
  Assert.AreEqual(5, FCUT.Count);
  Assert.AreEqual(8, FCUT.Capacity);

  FCUT.Delete(0);
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(8, FCUT.Capacity);

  FCUT.Delete(0);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(8, FCUT.Capacity);

  FCUT.TrimExcess;
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(3, FCUT.Capacity);

  FCUT.DeleteRange(0, 3);
  Assert.AreEqual(0, FCUT.Count);
  Assert.AreEqual(3, FCUT.Capacity);
end;

procedure TTestSortedList.TestGetEnumerator;
var
  I, Item: Integer;
begin
  CreateRandomValuesWithoutDuplicates;
  FCUT.AddRange(FValues);
  I := 0;
  for Item in FCUT do
  begin
    Assert.AreEqual(I, Item);
    Inc(I);
  end;
end;

procedure TTestSortedList.TestIndexOf;
begin
  FCUT.Duplicates := dupAccept;
  FCUT.Add(1);
  FCUT.Add(2);
  FCUT.Add(3);
  FCUT.Add(2);
  FCUT.Add(1);
  Assert.AreEqual(-1, FCUT.IndexOf(0));
  Assert.AreEqual(0, FCUT.IndexOf(1));
  Assert.AreEqual(2, FCUT.IndexOf(2));
  Assert.AreEqual(4, FCUT.IndexOf(3));
end;

procedure TTestSortedList.TestIndexOfItem;
begin
  FCUT.Duplicates := dupAccept;
  FCUT.Add(1);
  FCUT.Add(2);
  FCUT.Add(3);
  FCUT.Add(2);
  FCUT.Add(1);

  Assert.AreEqual(-1, FCUT.IndexOfItem(0, TDirection.FromBeginning));
  Assert.AreEqual(0, FCUT.IndexOfItem(1, TDirection.FromBeginning));
  Assert.AreEqual(2, FCUT.IndexOfItem(2, TDirection.FromBeginning));
  Assert.AreEqual(4, FCUT.IndexOfItem(3, TDirection.FromBeginning));

  Assert.AreEqual(-1, FCUT.IndexOfItem(0, TDirection.FromEnd));
  Assert.AreEqual(1, FCUT.IndexOfItem(1, TDirection.FromEnd));
  Assert.AreEqual(3, FCUT.IndexOfItem(2, TDirection.FromEnd));
  Assert.AreEqual(4, FCUT.IndexOfItem(3, TDirection.FromEnd));
end;

procedure TTestSortedList.TestInit;
begin
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestSortedList.TestLast;
begin
  FCUT.Add(3);
  FCUT.Add(2);
  FCUT.Add(8);
  FCUT.Add(5);
  Assert.AreEqual(8, FCUT.Last);
end;

procedure TTestSortedList.TestLastIndexOf;
begin
  FCUT.Duplicates := dupAccept;
  FCUT.Add(1);
  FCUT.Add(2);
  FCUT.Add(1);
  FCUT.Add(3);
  FCUT.Add(1);
  Assert.AreEqual(5, FCUT.Count);
  Assert.AreEqual(2, FCUT.LastIndexOf(1));
end;

procedure TTestSortedList.TestListClear;
begin
  CreateRandomValuesWithoutDuplicates;
  FCUT.AddRange(FValues);
  Assert.AreEqual(100, FCUT.Count);

  FCUT.Clear;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestSortedList.TestListIndexOf;
var
  I: Integer;
begin
  CreateRandomValuesWithoutDuplicates;
  FCUT.AddRange(FValues);
  Assert.AreEqual(100, FCUT.Count);

  for I := 0 to 99 do
    Assert.AreEqual(I, FCUT.IndexOf(I));

  Assert.AreEqual(-1, FCUT.IndexOf(100));
end;

procedure TTestSortedList.TestListLargeDelete;
var
  I: Integer;
begin
  CreateRandomValuesWithoutDuplicates;
  FCUT.AddRange(FValues);
  Assert.AreEqual(100, FCUT.Count);

  for I := 0 to 99 do
    FCUT.Delete(0);

  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestSortedList.TestListMultipleDelete;
begin
  SimpleFillList;
  Assert.AreEqual(3, FCUT.Count);
  FCUT.Delete(0);
  Assert.AreEqual(2, FCUT.Count);
  FCUT.Delete(0);
  Assert.AreEqual(1, FCUT.Count);
  FCUT.Delete(0);
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestSortedList.TestListSimpleDelete;
begin
  FCUT.Add(42);
  Assert.AreEqual(1, FCUT.Count);
  FCUT.Delete(0);
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestSortedList.TestRemove;
begin
  FCUT.Duplicates := dupAccept;
  FCUT.Add(1);
  FCUT.Add(2);
  FCUT.Add(3);
  FCUT.Add(2);
  FCUT.Add(1);

  Assert.AreEqual(-1, FCUT.Remove(4));
  Assert.AreEqual(5, FCUT.Count);

  Assert.AreEqual(2, FCUT.Remove(2));
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(1, FCUT[0]);
  Assert.AreEqual(1, FCUT[1]);
  Assert.AreEqual(2, FCUT[2]);
  Assert.AreEqual(3, FCUT[3]);
end;

procedure TTestSortedList.TestRemoveItem;
begin
  FCUT.Duplicates := dupAccept;
  FCUT.Add(1);
  FCUT.Add(2);
  FCUT.Add(3);
  FCUT.Add(2);
  FCUT.Add(1);

  Assert.AreEqual(-1, FCUT.RemoveItem(4, TDirection.FromBeginning));
  Assert.AreEqual(5, FCUT.Count);

  Assert.AreEqual(3, FCUT.RemoveItem(2, TDirection.FromEnd));
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(1, FCUT[0]);
  Assert.AreEqual(1, FCUT[1]);
  Assert.AreEqual(2, FCUT[2]);
  Assert.AreEqual(3, FCUT[3]);

  Assert.AreEqual(0, FCUT.RemoveItem(1, TDirection.FromBeginning));
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(1, FCUT[0]);
  Assert.AreEqual(2, FCUT[1]);
  Assert.AreEqual(3, FCUT[2]);
end;

procedure TTestSortedList.TestToArray;
var
  A: TArray<Integer>;
begin
  FCUT.Duplicates := dupAccept;
  FCUT.Add(1);
  FCUT.Add(2);
  FCUT.Add(3);
  FCUT.Add(2);
  FCUT.Add(1);
  A := FCUT.ToArray;
  Assert.AreEqual<Integer>(5, Length(A));
  Assert.AreEqual(1, A[0]);
  Assert.AreEqual(1, A[1]);
  Assert.AreEqual(2, A[2]);
  Assert.AreEqual(2, A[3]);
  Assert.AreEqual(3, A[4]);
end;

{ TTestObjectList }

procedure TTestObjectList.SetUp;
begin
  inherited;
  FCUT := TObjectList<TFoo>.Create;
end;

procedure TTestObjectList.SimpleFillList;
begin
  Assert.IsNotNull(FCUT);
  FCUT.Add(TFoo.Create(1));
  FCUT.Add(TFoo.Create(2));
  FCUT.Add(TFoo.Create(3));
  FCUT.Add(TFoo.Create(4));
  FCUT.Add(TFoo.Create(5));
end;

procedure TTestObjectList.TearDown;
begin
  FCUT.Free;
  inherited;
end;

procedure TTestObjectList.TestAdd;
begin
  SimpleFillList;
end;

procedure TTestObjectList.TestDelete;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.Delete(0);
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(2, FCUT[0].Value);
  Assert.AreEqual(3, FCUT[1].Value);
  Assert.AreEqual(4, FCUT[2].Value);
  Assert.AreEqual(5, FCUT[3].Value);
end;

procedure TTestObjectList.TestDeleteRange;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.DeleteRange(1, 3);
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(5, FCUT[1].Value);
end;

procedure TTestObjectList.TestExtract;
var
  Value: TFoo;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.Remove(nil);
  Assert.AreEqual(5, FCUT.Count);

  Value := FCUT.Extract(FCUT[1]);
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(2, Value.Value);
  Value.Free;

  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(3, FCUT[1].Value);
  Assert.AreEqual(4, FCUT[2].Value);
  Assert.AreEqual(5, FCUT[3].Value);
end;

procedure TTestObjectList.TestExtractItem;
var
  Value: TFoo;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.RemoveItem(nil, TDirection.FromBeginning);
  Assert.AreEqual(5, FCUT.Count);

  Value := FCUT.ExtractItem(FCUT[4], TDirection.FromBeginning);
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(5, Value.Value);
  Value.Free;

  Value := FCUT.ExtractItem(FCUT[2], TDirection.FromEnd);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(3, Value.Value);
  Value.Free;

  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(2, FCUT[1].Value);
  Assert.AreEqual(4, FCUT[2].Value);
end;

procedure TTestObjectList.TestRemove;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.Remove(nil);
  Assert.AreEqual(5, FCUT.Count);
  FCUT.Remove(FCUT[1]);
  Assert.AreEqual(4, FCUT.Count);

  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(3, FCUT[1].Value);
  Assert.AreEqual(4, FCUT[2].Value);
  Assert.AreEqual(5, FCUT[3].Value);
end;

procedure TTestObjectList.TestRemoveItem;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.RemoveItem(nil, TDirection.FromBeginning);
  Assert.AreEqual(5, FCUT.Count);
  FCUT.RemoveItem(FCUT[4], TDirection.FromBeginning);
  Assert.AreEqual(4, FCUT.Count);
  FCUT.RemoveItem(FCUT[2], TDirection.FromEnd);
  Assert.AreEqual(3, FCUT.Count);

  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(2, FCUT[1].Value);
  Assert.AreEqual(4, FCUT[2].Value);
end;

procedure TTestObjectList.TestSetItem;
var
  Value: TFoo;
begin
  SimpleFillList;
  Value := TFoo.Create(6);
  FCUT.Items[3] := Value;

  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(2, FCUT[1].Value);
  Assert.AreEqual(3, FCUT[2].Value);
  Assert.AreEqual(6, FCUT[3].Value);
  Assert.AreEqual(5, FCUT[4].Value);
end;

{ TTestSortedObjectList }

procedure TTestSortedObjectList.SetUp;
begin
  inherited;
  FCUT := TSortedObjectList<TFoo>.Create(TFooComparer.Create);
  FCUT.Duplicates := dupAccept
end;

procedure TTestSortedObjectList.SimpleFillList;
begin
  Assert.IsNotNull(FCUT);
  FCUT.Add(TFoo.Create(1));
  FCUT.Add(TFoo.Create(2));
  FCUT.Add(TFoo.Create(3));
  FCUT.Add(TFoo.Create(2));
  FCUT.Add(TFoo.Create(1));
end;

procedure TTestSortedObjectList.TearDown;
begin
  FCUT.Free;
  inherited;
end;

procedure TTestSortedObjectList.TestAdd;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(1, FCUT[1].Value);
  Assert.AreEqual(2, FCUT[2].Value);
  Assert.AreEqual(2, FCUT[3].Value);
  Assert.AreEqual(3, FCUT[4].Value);
end;

procedure TTestSortedObjectList.TestDelete;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.Delete(0);
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(2, FCUT[1].Value);
  Assert.AreEqual(2, FCUT[2].Value);
  Assert.AreEqual(3, FCUT[3].Value);
end;

procedure TTestSortedObjectList.TestDeleteRange;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.DeleteRange(1, 3);
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(3, FCUT[1].Value);
end;

procedure TTestSortedObjectList.TestExtract;
var
  Value: TFoo;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.Remove(nil);
  Assert.AreEqual(5, FCUT.Count);

  Value := FCUT.Extract(FCUT[1]);
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(1, Value.Value);
  Value.Free;

  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(2, FCUT[1].Value);
  Assert.AreEqual(2, FCUT[2].Value);
  Assert.AreEqual(3, FCUT[3].Value);
end;

procedure TTestSortedObjectList.TestExtractItem;
var
  Value: TFoo;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.RemoveItem(nil, TDirection.FromBeginning);
  Assert.AreEqual(5, FCUT.Count);

  Value := FCUT.ExtractItem(FCUT[4], TDirection.FromBeginning);
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(3, Value.Value);
  Value.Free;

  Value := FCUT.ExtractItem(FCUT[2], TDirection.FromEnd);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(2, Value.Value);
  Value.Free;

  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(1, FCUT[1].Value);
  Assert.AreEqual(2, FCUT[2].Value);
end;

procedure TTestSortedObjectList.TestRemove;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.Remove(nil);
  Assert.AreEqual(5, FCUT.Count);
  FCUT.Remove(FCUT[1]);
  Assert.AreEqual(4, FCUT.Count);

  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(2, FCUT[1].Value);
  Assert.AreEqual(2, FCUT[2].Value);
  Assert.AreEqual(3, FCUT[3].Value);
end;

procedure TTestSortedObjectList.TestRemoveItem;
begin
  SimpleFillList;
  Assert.AreEqual(5, FCUT.Count);
  FCUT.RemoveItem(nil, TDirection.FromBeginning);
  Assert.AreEqual(5, FCUT.Count);
  FCUT.RemoveItem(FCUT[4], TDirection.FromBeginning);
  Assert.AreEqual(4, FCUT.Count);
  FCUT.RemoveItem(FCUT[2], TDirection.FromEnd);
  Assert.AreEqual(3, FCUT.Count);

  Assert.AreEqual(1, FCUT[0].Value);
  Assert.AreEqual(1, FCUT[1].Value);
  Assert.AreEqual(2, FCUT[2].Value);
end;

initialization
  ReportMemoryLeaksOnShutdown := True;
  TDUnitX.RegisterTestFixture(TTestList<TBytes>);
  TDUnitX.RegisterTestFixture(TTestList<ShortInt>);
  {$IFNDEF LIMITED_GENERICS}
  TDUnitX.RegisterTestFixture(TTestList<Byte>);
  TDUnitX.RegisterTestFixture(TTestList<SmallInt>);
  TDUnitX.RegisterTestFixture(TTestList<Word>);
  TDUnitX.RegisterTestFixture(TTestList<Integer>);
  TDUnitX.RegisterTestFixture(TTestList<Cardinal>);
  TDUnitX.RegisterTestFixture(TTestList<Boolean>);
  TDUnitX.RegisterTestFixture(TTestList<TDigit>);
  TDUnitX.RegisterTestFixture(TTestList<TDigits>);
  TDUnitX.RegisterTestFixture(TTestList<Single>);
  TDUnitX.RegisterTestFixture(TTestList<Double>);
  TDUnitX.RegisterTestFixture(TTestList<Extended>);
  TDUnitX.RegisterTestFixture(TTestList<Comp>);
  TDUnitX.RegisterTestFixture(TTestList<Currency>);
  TDUnitX.RegisterTestFixture(TTestList<TFoo>);
  TDUnitX.RegisterTestFixture(TTestList<IBaz>);
  TDUnitX.RegisterTestFixture(TTestList<TFooClass>);
  TDUnitX.RegisterTestFixture(TTestList<PInteger>);
  TDUnitX.RegisterTestFixture(TTestList<TTestProc>);
  TDUnitX.RegisterTestFixture(TTestList<TTestMethod>);
  {$IFNDEF NEXTGEN}
  TDUnitX.RegisterTestFixture(TTestList<ShortString>);
  TDUnitX.RegisterTestFixture(TTestList<AnsiString>);
  TDUnitX.RegisterTestFixture(TTestList<WideString>);
  TDUnitX.RegisterTestFixture(TTestList<AnsiChar>);
  {$ENDIF}
  TDUnitX.RegisterTestFixture(TTestList<RawByteString>);
  TDUnitX.RegisterTestFixture(TTestList<UnicodeString>);
  TDUnitX.RegisterTestFixture(TTestList<Variant>);
  TDUnitX.RegisterTestFixture(TTestList<Int64>);
  TDUnitX.RegisterTestFixture(TTestList<UInt64>);
  TDUnitX.RegisterTestFixture(TTestList<TBytes>);
  TDUnitX.RegisterTestFixture(TTestList<WideChar>);
  TDUnitX.RegisterTestFixture(TTestList<TTestArray>);
  TDUnitX.RegisterTestFixture(TTestList<TSimpleRecord>);
  TDUnitX.RegisterTestFixture(TTestList<TManagedRecord>);
  TDUnitX.RegisterTestFixture(TTestList<TFooBarRecord>);
  TDUnitX.RegisterTestFixture(TTestList<TManagedArray>);
  TDUnitX.RegisterTestFixture(TTestList<TFooBarArray>);
  {$ENDIF LIMITED_GENERICS}

  TDUnitX.RegisterTestFixture(TTestSortedList);
  TDUnitX.RegisterTestFixture(TTestObjectList);
  TDUnitX.RegisterTestFixture(TTestSortedObjectList);

end.
