unit Tests.Collections.Queues;

interface

uses
  DUnitX.TestFramework,
  Tests.Collections.Base,
  Neslib.Collections;

type
  TTestQueue<T> = class(TTestCollectionBase<T>)
  private
    FCUT: TQueue<T>;
    FValues: TArray<T>;
    procedure FillQueue;
    procedure CheckItems(const AExpected: TArray<T>);
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestEnqueue;
    [Test] procedure TestDequeue;
    [Test] procedure TestPeek;
    [Test] procedure TestClear;
    [Test] procedure TestToArray;
    [Test] procedure TestGetCapacityAndCount;
    [Test] procedure TestWrapAroundAndEnumerator;
  end;

type
  TTestObjectQueue = class(TTestCollectionBase<TFoo>)
  private
    FCUT: TObjectQueue<TFoo>;
    procedure FillQueue;
    procedure CheckItems(const AExpected: array of Integer);
  public
    [Setup] procedure SetUp;
    [Teardown] procedure TearDown;
    [Test] procedure TestEnqueue;
    [Test] procedure TestDequeue;
    [Test] procedure TestPeek;
    [Test] procedure TestClear;
    [Test] procedure TestToArray;
    [Test] procedure TestGetCapacityAndCount;
    [Test] procedure TestWrapAroundAndEnumerator;
  end;

type
  TQueueOpener<T> = class(TQueue<T>);
  TObjectQueueOpener<T: class> = class(TObjectQueue<T>);

implementation

uses
  System.SysUtils;

{ TTestQueue<T> }

procedure TTestQueue<T>.CheckItems(const AExpected: TArray<T>);
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

procedure TTestQueue<T>.FillQueue;
var
  Value: T;
begin
  FValues := CreateValues(6);
  for Value in FValues do
    FCUT.Enqueue(Value);
end;

procedure TTestQueue<T>.SetUp;
begin
  inherited;
  FCUT := TQueue<T>.Create;
end;

procedure TTestQueue<T>.TearDown;
begin
  FCUT.Free;
  inherited;
end;

procedure TTestQueue<T>.TestClear;
begin
  FillQueue;
  Assert.AreEqual(6, FCUT.Count);
  FCUT.Clear;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestQueue<T>.TestDequeue;
begin
  FillQueue;
  TestEquals(FValues[0], FCUT.Dequeue);
  TestEquals(FValues[1], FCUT.Dequeue);
  TestEquals(FValues[2], FCUT.Dequeue);
  TestEquals(FValues[3], FCUT.Dequeue);
  TestEquals(FValues[4], FCUT.Dequeue);
  TestEquals(FValues[5], FCUT.Dequeue);
end;

procedure TTestQueue<T>.TestEnqueue;
var
  Values: TArray<T>;
begin
  Values := CreateValues(6);
  FCUT.Enqueue(Values[0]);
  Assert.AreEqual(1, FCUT.Count);
  FCUT.Enqueue(Values[1]);
  Assert.AreEqual(2, FCUT.Count);
  FCUT.Enqueue(Values[2]);
  Assert.AreEqual(3, FCUT.Count);
  FCUT.Enqueue(Values[3]);
  Assert.AreEqual(4, FCUT.Count);
  FCUT.Enqueue(Values[4]);
  Assert.AreEqual(5, FCUT.Count);
  FCUT.Enqueue(Values[5]);
  Assert.AreEqual(6, FCUT.Count);
  CheckItems(Values);
end;

procedure TTestQueue<T>.TestGetCapacityAndCount;
var
  Value: T;
begin
  Value := CreateValue(1);

  Assert.AreEqual(0, FCUT.Count);
  Assert.AreEqual(0, FCUT.Capacity);

  FCUT.Enqueue(Value);
  Assert.AreEqual(1, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Enqueue(Value);
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Enqueue(Value);
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Enqueue(Value);
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Enqueue(Value);
  Assert.AreEqual(5, FCUT.Count);
  Assert.AreEqual(8, FCUT.Capacity);
end;

procedure TTestQueue<T>.TestPeek;
begin
  FillQueue;
  TestEquals(FValues[0], FCUT.Peek);
  FCUT.Dequeue;
  TestEquals(FValues[1], FCUT.Peek);
  FCUT.Dequeue;
  TestEquals(FValues[2], FCUT.Peek);
  FCUT.Dequeue;
end;

procedure TTestQueue<T>.TestToArray;
var
  A: TArray<T>;
begin
  FillQueue;
  SetLength(A, 6);
  A[0] := FValues[0];
  A[1] := FValues[1];
  A[2] := FValues[2];
  A[3] := FValues[3];
  A[4] := FValues[4];
  A[5] := FValues[5];
  CheckItems(A);
end;

procedure TTestQueue<T>.TestWrapAroundAndEnumerator;
var
  Values, A: TArray<T>;
  Value: T;
  CUT: TQueueOpener<T>;
  I: Integer;
begin
  CUT := TQueueOpener<T>(FCUT);
  Values := CreateValues(14);

  { Enqueue 4 items (H=Head, T=Tail):
    Count=4, Capacity = 4, Mask = 3
     T/H
      0 - 1 - 2 - 3 }
  for I := 0 to 3 do
  begin
    CUT.Enqueue(Values[I]);
    Assert.AreEqual(I + 1, CUT.Count);
    Assert.AreEqual(4, CUT.Capacity);
    Assert.AreEqual(3, CUT.FMask);
    Assert.AreEqual((I + 1) and 3, CUT.FHead);
    Assert.AreEqual(0, CUT.FTail);
  end;

  Assert.AreEqual(CUT.FHead, CUT.FTail);
  { Enqueue 2 more items:
    Count=6, Capacity = 8, Mask = 7
              H       T
      4 - 5 - x - x - 0 - 1 - 2 - 3 }
  for I := 4 to 5 do
  begin
    CUT.Enqueue(Values[I]);
    Assert.AreEqual(I + 1, CUT.Count);
    Assert.AreEqual(8, CUT.Capacity);
    Assert.AreEqual(7, CUT.FMask);
    Assert.AreEqual(I - 3, CUT.FHead);
    Assert.AreEqual(4, CUT.FTail);
  end;

  { Dequeue 3 items (0, 1 and 2):
    Count=3, Capacity = 8, Mask = 7
              H                   T
      4 - 5 - x - x - x - x - x - 3 }
  for I := 0 to 2 do
  begin
    Value := CUT.Dequeue;
    TestEquals(Value, Values[I]);
    Assert.AreEqual(5 - I, CUT.Count);
    Assert.AreEqual(8, CUT.Capacity);
    Assert.AreEqual(7, CUT.FMask);
    Assert.AreEqual(2, CUT.FHead);
    Assert.AreEqual(5 + I, CUT.FTail);
  end;

  { Queue has values 3-5 now. Test with Enumerator and ToArray. }
  I := 3;
  for Value in CUT do
  begin
    TestEquals(Value, Values[I]);
    Inc(I);
  end;

  A := CUT.ToArray;
  Assert.AreEqual(3, Length(A));
  for I := 0 to 2 do
    TestEquals(A[I], Values[I + 3]);

  { Enqueue 5 items:
    Count=8, Capacity = 8, Mask = 7
                                  T/H
      4 - 5 - 6 - 7 - 8 - 9 - 10 - 3 }
  for I := 0 to 4 do
  begin
    CUT.Enqueue(Values[I + 6]);
    Assert.AreEqual(I + 4, CUT.Count);
    Assert.AreEqual(8, CUT.Capacity);
    Assert.AreEqual(7, CUT.FMask);
    Assert.AreEqual(I + 3, CUT.FHead);
    Assert.AreEqual(7, CUT.FTail);
  end;

  { Enqueue 3 items:
    Count=11, Capacity = 16, Mask = 15
                                                  H                   T
      4 - 5 - 6 - 7 - 8 - 9 - 10 - 11 - 12 - 13 - x - x - x - x - x - 3 }
  for I := 0 to 2 do
  begin
    CUT.Enqueue(Values[I + 11]);
    Assert.AreEqual(I + 9, CUT.Count);
    Assert.AreEqual(16, CUT.Capacity);
    Assert.AreEqual(15, CUT.FMask);
    Assert.AreEqual(I + 8, CUT.FHead);
    Assert.AreEqual(15, CUT.FTail);
  end;

  { Dequeue 2 items (3 and 4):
    Count=9, Capacity = 16, Mask = 15
          T                                       H
      x - 5 - 6 - 7 - 8 - 9 - 10 - 11 - 12 - 13 - x - x - x - x - x - x }
  for I := 0 to 1 do
  begin
    Value := CUT.Dequeue;
    TestEquals(Value, Values[I + 3]);
    Assert.AreEqual(10 - I, CUT.Count);
    Assert.AreEqual(16, CUT.Capacity);
    Assert.AreEqual(15, CUT.FMask);
    Assert.AreEqual(10, CUT.FHead);
    Assert.AreEqual(I, CUT.FTail);
  end;

  { Queue has values 5-13 now. Test with Enumerator and ToArray. }
  I := 5;
  for Value in CUT do
  begin
    TestEquals(Value, Values[I]);
    Inc(I);
  end;

  A := CUT.ToArray;
  Assert.AreEqual(9, Length(A));
  for I := 0 to 8 do
    TestEquals(A[I], Values[I + 5]);
end;

{ TTestObjectQueue }

procedure TTestObjectQueue.CheckItems(const AExpected: array of Integer);
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

procedure TTestObjectQueue.FillQueue;
var
  I: Integer;
begin
  for I := 0 to 2 do
    FCUT.Enqueue(TFoo.Create(I));
end;

procedure TTestObjectQueue.SetUp;
begin
  inherited;
  FCUT := TObjectQueue<TFoo>.Create;
end;

procedure TTestObjectQueue.TearDown;
begin
  FCUT.Free;
  inherited;
end;

procedure TTestObjectQueue.TestClear;
begin
  FillQueue;
  Assert.AreEqual(3, FCUT.Count);
  FCUT.Clear;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestObjectQueue.TestDequeue;
begin
  FillQueue;
  Assert.AreEqual(3, FCUT.Count);
  FCUT.Dequeue;
  Assert.AreEqual(2, FCUT.Count);
  FCUT.Dequeue;
  Assert.AreEqual(1, FCUT.Count);
  FCUT.Dequeue;
  Assert.AreEqual(0, FCUT.Count);
end;

procedure TTestObjectQueue.TestEnqueue;
begin
  FCUT.Enqueue(TFoo.Create(0));
  Assert.AreEqual(1, FCUT.Count);
  FCUT.Enqueue(TFoo.Create(1));
  Assert.AreEqual(2, FCUT.Count);
  FCUT.Enqueue(TFoo.Create(2));
  Assert.AreEqual(3, FCUT.Count);
  CheckItems([0, 1, 2]);
end;

procedure TTestObjectQueue.TestGetCapacityAndCount;
begin
  Assert.AreEqual(0, FCUT.Count);
  Assert.AreEqual(0, FCUT.Capacity);

  FCUT.Enqueue(TFoo.Create(0));
  Assert.AreEqual(1, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Enqueue(TFoo.Create(0));
  Assert.AreEqual(2, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Enqueue(TFoo.Create(0));
  Assert.AreEqual(3, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Enqueue(TFoo.Create(0));
  Assert.AreEqual(4, FCUT.Count);
  Assert.AreEqual(4, FCUT.Capacity);

  FCUT.Enqueue(TFoo.Create(0));
  Assert.AreEqual(5, FCUT.Count);
  Assert.AreEqual(8, FCUT.Capacity);
end;

procedure TTestObjectQueue.TestPeek;
begin
  FillQueue;
  Assert.AreEqual(0, FCUT.Peek.Value);
  FCUT.Dequeue;
  Assert.AreEqual(1, FCUT.Peek.Value);
  FCUT.Dequeue;
  Assert.AreEqual(2, FCUT.Peek.Value);
  FCUT.Dequeue;
end;

procedure TTestObjectQueue.TestToArray;
begin
  FillQueue;
  CheckItems([0, 1, 2]);
end;

procedure TTestObjectQueue.TestWrapAroundAndEnumerator;
var
  CUT: TObjectQueueOpener<TFoo>;
  Value: TFoo;
  A: TArray<TFoo>;
  I: Integer;
begin
  CUT := TObjectQueueOpener<TFoo>(FCUT);

  { Enqueue 4 items (H=Head, T=Tail):
    Count=4, Capacity = 4, Mask = 3
     T/H
      0 - 1 - 2 - 3 }
  for I := 0 to 3 do
  begin
    CUT.Enqueue(TFoo.Create(I));
    Assert.AreEqual(I + 1, CUT.Count);
    Assert.AreEqual(4, CUT.Capacity);
    Assert.AreEqual(3, CUT.FMask);
    Assert.AreEqual((I + 1) and 3, CUT.FHead);
    Assert.AreEqual(0, CUT.FTail);
  end;

  Assert.AreEqual(CUT.FHead, CUT.FTail);

  { Enqueue 2 more items:
    Count=6, Capacity = 8, Mask = 7
              H       T
      4 - 5 - x - x - 0 - 1 - 2 - 3 }
  for I := 4 to 5 do
  begin
    CUT.Enqueue(TFoo.Create(I));
    Assert.AreEqual(I + 1, CUT.Count);
    Assert.AreEqual(8, CUT.Capacity);
    Assert.AreEqual(7, CUT.FMask);
    Assert.AreEqual(I - 3, CUT.FHead);
    Assert.AreEqual(4, CUT.FTail);
  end;

  { Dequeue 3 items (0, 1 and 2):
    Count=3, Capacity = 8, Mask = 7
              H                   T
      4 - 5 - x - x - x - x - x - 3 }
  for I := 0 to 2 do
  begin
    Assert.AreEqual(I, CUT.Peek.Value);
    CUT.Dequeue;
    Assert.AreEqual(5 - I, CUT.Count);
    Assert.AreEqual(8, CUT.Capacity);
    Assert.AreEqual(7, CUT.FMask);
    Assert.AreEqual(2, CUT.FHead);
    Assert.AreEqual(5 + I, CUT.FTail);
  end;

  { Queue has values 3-5 now. Test with Enumerator and ToArray. }
  I := 3;
  for Value in CUT do
  begin
    Assert.AreEqual(I, Value.Value);
    Inc(I);
  end;

  A := CUT.ToArray;
  Assert.AreEqual(3, Length(A));
  for I := 0 to 2 do
    Assert.AreEqual(I + 3, A[I].Value);

  { Enqueue 5 items:
    Count=8, Capacity = 8, Mask = 7
                                  T/H
      4 - 5 - 6 - 7 - 8 - 9 - 10 - 3 }
  for I := 0 to 4 do
  begin
    CUT.Enqueue(TFoo.Create(I + 6));
    Assert.AreEqual(I + 4, CUT.Count);
    Assert.AreEqual(8, CUT.Capacity);
    Assert.AreEqual(7, CUT.FMask);
    Assert.AreEqual(I + 3, CUT.FHead);
    Assert.AreEqual(7, CUT.FTail);
  end;

  { Enqueue 3 items:
    Count=11, Capacity = 16, Mask = 15
                                                  H                   T
      4 - 5 - 6 - 7 - 8 - 9 - 10 - 11 - 12 - 13 - x - x - x - x - x - 3 }
  for I := 0 to 2 do
  begin
    CUT.Enqueue(TFoo.Create(I + 11));
    Assert.AreEqual(I + 9, CUT.Count);
    Assert.AreEqual(16, CUT.Capacity);
    Assert.AreEqual(15, CUT.FMask);
    Assert.AreEqual(I + 8, CUT.FHead);
    Assert.AreEqual(15, CUT.FTail);
  end;

  { Dequeue 2 items (3 and 4):
    Count=9, Capacity = 16, Mask = 15
          T                                       H
      x - 5 - 6 - 7 - 8 - 9 - 10 - 11 - 12 - 13 - x - x - x - x - x - x }
  for I := 0 to 1 do
  begin
    Assert.AreEqual(I + 3, CUT.Peek.Value);
    CUT.Dequeue;
    Assert.AreEqual(10 - I, CUT.Count);
    Assert.AreEqual(16, CUT.Capacity);
    Assert.AreEqual(15, CUT.FMask);
    Assert.AreEqual(10, CUT.FHead);
    Assert.AreEqual(I, CUT.FTail);
  end;

  { Queue has values 5-13 now. Test with Enumerator and ToArray. }
  I := 5;
  for Value in CUT do
  begin
    Assert.AreEqual(I, Value.Value);
    Inc(I);
  end;

  A := CUT.ToArray;
  Assert.AreEqual(9, Length(A));
  for I := 0 to 8 do
    Assert.AreEqual(I + 5, A[I].Value);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestQueue<ShortInt>);
  {$IFNDEF LIMITED_GENERICS}
  TDUnitX.RegisterTestFixture(TTestQueue<Byte>);
  TDUnitX.RegisterTestFixture(TTestQueue<SmallInt>);
  TDUnitX.RegisterTestFixture(TTestQueue<Word>);
  TDUnitX.RegisterTestFixture(TTestQueue<Integer>);
  TDUnitX.RegisterTestFixture(TTestQueue<Cardinal>);
  TDUnitX.RegisterTestFixture(TTestQueue<Boolean>);
  TDUnitX.RegisterTestFixture(TTestQueue<TDigit>);
  TDUnitX.RegisterTestFixture(TTestQueue<TDigits>);
  TDUnitX.RegisterTestFixture(TTestQueue<Single>);
  TDUnitX.RegisterTestFixture(TTestQueue<Double>);
  TDUnitX.RegisterTestFixture(TTestQueue<Extended>);
  TDUnitX.RegisterTestFixture(TTestQueue<Comp>);
  TDUnitX.RegisterTestFixture(TTestQueue<Currency>);
  TDUnitX.RegisterTestFixture(TTestQueue<TFoo>);
  TDUnitX.RegisterTestFixture(TTestQueue<IBaz>);
  TDUnitX.RegisterTestFixture(TTestQueue<TFooClass>);
  TDUnitX.RegisterTestFixture(TTestQueue<PInteger>);
  TDUnitX.RegisterTestFixture(TTestQueue<TTestProc>);
  TDUnitX.RegisterTestFixture(TTestQueue<TTestMethod>);
  {$IFNDEF NEXTGEN}
  TDUnitX.RegisterTestFixture(TTestQueue<TStr2>);
  TDUnitX.RegisterTestFixture(TTestQueue<TStr3>);
  TDUnitX.RegisterTestFixture(TTestQueue<ShortString>);
  TDUnitX.RegisterTestFixture(TTestQueue<AnsiString>);
  TDUnitX.RegisterTestFixture(TTestQueue<WideString>);
  TDUnitX.RegisterTestFixture(TTestQueue<AnsiChar>);
  {$ENDIF}
  TDUnitX.RegisterTestFixture(TTestQueue<RawByteString>);
  TDUnitX.RegisterTestFixture(TTestQueue<UnicodeString>);
  TDUnitX.RegisterTestFixture(TTestQueue<Variant>);
  TDUnitX.RegisterTestFixture(TTestQueue<Int64>);
  TDUnitX.RegisterTestFixture(TTestQueue<UInt64>);
  TDUnitX.RegisterTestFixture(TTestQueue<TBytes>);
  TDUnitX.RegisterTestFixture(TTestQueue<WideChar>);
  TDUnitX.RegisterTestFixture(TTestQueue<TTestArray>);
  TDUnitX.RegisterTestFixture(TTestQueue<TSimpleRecord>);
  TDUnitX.RegisterTestFixture(TTestQueue<TManagedRecord>);
  TDUnitX.RegisterTestFixture(TTestQueue<TFooBarRecord>);
  TDUnitX.RegisterTestFixture(TTestQueue<TManagedArray>);
  TDUnitX.RegisterTestFixture(TTestQueue<TFooBarArray>);
  {$ENDIF LIMITED_GENERICS}

  TDUnitX.RegisterTestFixture(TTestObjectQueue);
end.
