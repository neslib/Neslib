unit Tests.SysUtils;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  Neslib.SysUtils;

type
  TTestUnformat = class
  private
    FUSFormat: TFormatSettings;
    FNLFormat: TFormatSettings;
  public
    [Setup] procedure Setup;
    [Test] procedure TestInt8;
    [Test] procedure TestUInt8;
    [Test] procedure TestInt16;
    [Test] procedure TestUInt16;
    [Test] procedure TestInt32;
    [Test] procedure TestInt64;
    [Test] procedure TestUInt32;
    [Test] procedure TestUInt64;
    [Test] procedure TestHex;
    [Test] procedure TestInteger;
    [Test] procedure TestSingle;
    [Test] procedure TestDouble;
    [Test] procedure TestExtended;
    [Test] procedure TestFormatSettings;
    [Test] procedure TestPointer;
    [Test] procedure TestStringUnicode;
    [Test] procedure TestPatternUnicode;
    [Test] procedure TestIndex;
    [Test] procedure TestWidth;
    [Test] procedure TestNil;
    [Test] procedure TestCaseSensitive;
    [Test] procedure TestCount;
    [Test] procedure TestBadFormatStrings;
    [Test] procedure TestEscape;
    [Test] procedure TestExampleURI;
    [Test] procedure TestExampleHTTPMessage;
    [Test] procedure TestWhiteSpace;
  end;

implementation

uses
  System.Math;

{ TTestUnformat }

procedure TTestUnformat.Setup;
begin
  FUSFormat.ThousandSeparator := ',';
  FUSFormat.DecimalSeparator := '.';
  FNLFormat.ThousandSeparator := '.';
  FNLFormat.DecimalSeparator := ',';
end;

procedure TTestUnformat.TestBadFormatStrings;
var
  S: String;
begin
  { This function returns True because an empty format string matches an empty
    array of outputs. }
  Assert.IsTrue(Unformat('The Quick Brown Fox', '', []));

  { This function returns False because an empty format string does not match
    an expected output parameter. }
  Assert.IsFalse(Unformat('The Quick Brown Fox', '', [@S]));

  { These functions return False because the format string does dot contain
    a format specifier, or contains an invalid format specifier. }

  Assert.IsFalse(Unformat('The Quick Brown Fox', 'The', [@S]));
  Assert.IsFalse(Unformat('The Quick Brown Fox', 'Abc', [@S]));

  Assert.IsFalse(Unformat('The Quick Brown Fox', '%z', [@S]));
  Assert.IsFalse(Unformat('The Quick Brown Fox', '%12', [@S]));
  Assert.IsFalse(Unformat('The Quick Brown Fox', '%[a', [@S]));
end;

procedure TTestUnformat.TestCaseSensitive;
var
  A, B: String;
  Count: Integer;
begin
  { By default, literal strings in the format string ('The' and 'Brown') are
    match case-INsensitive, so the following to calls succeed }

  Assert.IsTrue(Unformat('The Quick Brown Fox', 'The %s Brown %s', [@A, @B]));
  Assert.AreEqual('Quick', A);
  Assert.AreEqual('Fox', B);

  Assert.IsTrue(Unformat('The Quick Brown Fox', 'the %s brown %s', [@A, @B]));
  Assert.AreEqual('Quick', A);
  Assert.AreEqual('Fox', B);

  { This call fails with case-sensitive checking }
  Assert.IsFalse(Unformat('The Quick Brown Fox', 'the %s brown %s', [@A, @B], [TUnformatOption.CaseSensitive]));

  Assert.IsFalse(Unformat('The Quick Brown Fox', 'the %s brown %s', [@A, @B], Count, [TUnformatOption.CaseSensitive]));
  Assert.AreEqual(Count, 0);

  { This call fails with case-sensitive checking because 'brown' does not match
    the case. But it does return the first string because 'The' does match
    the case. }
  Assert.IsFalse(Unformat('The Quick Brown Fox', 'The %s brown %s', [@A, @B], Count, [TUnformatOption.CaseSensitive]));
  Assert.AreEqual(Count, 1);
  Assert.AreEqual('Quick', A);
end;

procedure TTestUnformat.TestCount;
var
  A, B, C, D: String;
  Count: Integer;
begin
  { Test how many strings are extracted }

  Assert.IsTrue(Unformat('The Quick Brown Fox', '%s %s %s %s', [@A, @B, @C, @D], Count));
  Assert.AreEqual(4, Count);

  Assert.IsFalse(Unformat('The Quick Brown', '%s %s %s %s', [@A, @B, @C, @D], Count));
  Assert.AreEqual(3, Count);

  Assert.IsFalse(Unformat('The Quick', '%s %s %s %s', [@A, @B, @C, @D], Count));
  Assert.AreEqual(2, Count);

  Assert.IsFalse(Unformat('The', '%s %s %s %s', [@A, @B, @C, @D], Count));
  Assert.AreEqual(1, Count);

  Assert.IsFalse(Unformat('', '%s %s %s %s', [@A, @B, @C, @D], Count));
  Assert.AreEqual(0, Count);
end;

procedure TTestUnformat.TestDouble;
var
  Value, Expected: Double;
begin
  { Test extraction of Double-size floating point values, including values
    NaN and Inf
    NOTE: You can specify #d to signal that Value is of type Double, but this
    is not necessary because Double is the default. }

  Assert.IsTrue(Unformat('NAN', '%f', [@Value], FUSFormat));
  Assert.IsTrue(IsNan(Value));

  Assert.IsTrue(Unformat('-NAN', '%f', [@Value], FUSFormat));
  Assert.IsTrue(IsNan(Value));

  Assert.IsTrue(Unformat('INF', '%f', [@Value], FUSFormat));
  Assert.IsTrue(IsInfinite(Value));

  Assert.IsTrue(Unformat('-INF', '%f', [@Value], FUSFormat));
  Assert.IsTrue(IsInfinite(Value));

  Assert.IsTrue(Unformat('1234567.1234567', '%#df', [@Value], FUSFormat));
  Expected := 1234567.1234567;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-1234567.1234567', '%#df', [@Value], FUSFormat));
  Expected := -1234567.1234567;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('.1234567', '%f', [@Value], FUSFormat));
  Expected := 0.1234567;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('1234567e123', '%g', [@Value], FUSFormat));
  Expected := 1234567e123;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-1234567e123', '%e', [@Value], FUSFormat));
  Expected := -1234567e123;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('+1234567e-123', '%#dg', [@Value], FUSFormat));
  Expected := 1234567e-123;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('1234567e+123', '%#de', [@Value], FUSFormat));
  Expected := 1234567e123;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-1234567e-123', '%f', [@Value], FUSFormat));
  Expected := -1234567e-123;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-1234567e+123', '%f', [@Value], FUSFormat));
  Expected := -1234567e123;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('1234567.1234567e123', '%f', [@Value], FUSFormat));
  Expected := 1234567.1234567e123;
  Assert.IsTrue(SameValue(Expected, Value));
end;

procedure TTestUnformat.TestEscape;
var
  A, B: Integer;
begin
  { '%%' in format strings are matched as literal '%' }
  Assert.IsTrue(Unformat('Completed 10% of 100%', 'Completed %d%% of %d%%', [@A, @B]));
  Assert.AreEqual(10, A);
  Assert.AreEqual(100, B);
end;

procedure TTestUnformat.TestExampleHTTPMessage;
var
  Scheme, Msg: String;
  Version: Double;
  Code: Integer;
begin
  { Extract values from an HTTP message:

    %s/%f %d %s

    %s  matches a string until whitespace or the next character ('/') is
        found (the scheme)
    /   matches the literal '/' character
    %f  matches a floating point version number
    %d  matches an integer response code
    %s  matches the response message }

  Assert.IsTrue(Unformat(
    'HTTP/1.1 200 OK',
    '%s/%f %d %s',
    [@Scheme, @Version, @Code, @Msg], FUSFormat));
  Assert.AreEqual('HTTP', Scheme);
  Assert.AreEqual(1.1, Version, 0.00001);
  Assert.AreEqual(200, Code);
  Assert.AreEqual('OK', Msg);
end;

procedure TTestUnformat.TestExampleURI;
var
  Scheme, Auth, Path, Query: String;
  Count: Integer;
begin
  { Extract values from an URI:

    %s://%s/%s?%s

    %s   matches a string until whitespace or the next character (':') is
         found (scheme)
    ://  matches the literal '://' sequence
    %s   matches a string until whitespace or the next character ('/') is
         found (Authority)
    /    matches the literal '/' character
    %s   matches a string until whitespace or the next character ('?') is
         found (Path)
    ?    matches the literal '?' character
    %s   matches the rest of the string (Query) }

  { The first example returns True because all parts of the URI are present }

  Assert.IsTrue(Unformat(
    'http://www.bilsen.com/index.html?foo=bar?baz=42',
    '%s://%s/%s?%s',
    [@Scheme, @Auth, @Path, @Query]));
  Assert.AreEqual('http', Scheme);
  Assert.AreEqual('www.bilsen.com', Auth);
  Assert.AreEqual('index.html', Path);
  Assert.AreEqual('foo=bar?baz=42', Query);

  { These 2 examples return False because the given URI does not contain a
    Query or Path. However, it returns in Count the number of fields that are
    successfully extracted. }

  Assert.IsFalse(Unformat(
    'http://www.bilsen.com/index.html',
    '%s://%s/%s?%s',
    [@Scheme, @Auth, @Path, @Query], Count));
  Assert.AreEqual(3, Count);
  Assert.AreEqual('http', Scheme);
  Assert.AreEqual('www.bilsen.com', Auth);
  Assert.AreEqual('index.html', Path);

  Assert.IsFalse(Unformat(
    'http://www.bilsen.com',
    '%s://%s/%s?%s',
    [@Scheme, @Auth, @Path, @Query], Count));
  Assert.AreEqual(2, Count);
  Assert.AreEqual('http', Scheme);

  { This example behaves differently than you might expect. It returns the
    entire URI because the input string does not contain a ':' after HTTP.
    Since it searches for anything until a ':' or whitespace, it matches until
    the end of the string }
  Assert.IsFalse(Unformat(
    'http//www.bilsen.com',
    '%s://%s/%s?%s',
    [@Scheme, @Auth, @Path, @Query], Count));
  Assert.AreEqual(1, Count);
  Assert.AreEqual('http//www.bilsen.com', Scheme);
end;

procedure TTestUnformat.TestExtended;
var
  Value, Expected: Extended;
begin
  { Test extraction of Extended-size floating point values, including values
    NaN and Inf
    NOTE: You need to specify #3 to signal that Value is of type Extended }

  Assert.IsTrue(Unformat('NAN', '%#ef', [@Value], FUSFormat));
  Assert.IsTrue(IsNan(Value));

  Assert.IsTrue(Unformat('-NAN', '%#ef', [@Value], FUSFormat));
  Assert.IsTrue(IsNan(Value));

  Assert.IsTrue(Unformat('INF', '%#ef', [@Value], FUSFormat));
  Assert.IsTrue(IsInfinite(Value));

  Assert.IsTrue(Unformat('-INF', '%#ef', [@Value], FUSFormat));
  Assert.IsTrue(IsInfinite(Value));

  Assert.IsTrue(Unformat('123456789.123456789', '%#ef', [@Value], FUSFormat));
  Expected := 123456789.123456789;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-123456789.123456789', '%#ef', [@Value], FUSFormat));
  Expected := -123456789.123456789;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('.123456789', '%#ef', [@Value], FUSFormat));
  Expected := 0.123456789;
  Assert.IsTrue(SameValue(Expected, Value));

{$IF SizeOf(Extended) = 10}
  Assert.IsTrue(Unformat('123456789e1234', '%#eg', [@Value], FUSFormat));
  Expected := 123456789e1234;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-123456789e1234', '%#ee', [@Value], FUSFormat));
  Expected := -123456789e1234;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('+123456789e-1234', '%#eg', [@Value], FUSFormat));
  Expected := 123456789e-1234;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('123456789e+1234', '%#ee', [@Value], FUSFormat));
  Expected := 123456789e1234;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-123456789e-1234', '%#ef', [@Value], FUSFormat));
  Expected := -123456789e-1234;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-123456789e+1234', '%#ef', [@Value], FUSFormat));
  Expected := -123456789e1234;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('123456789.123456789e1234', '%#ef', [@Value], FUSFormat));
  Expected := 123456789.123456789e1234;
  Assert.IsTrue(SameValue(Expected, Value));

{$ELSE}
  Assert.IsTrue(Unformat('123456789e300', '%#eg', [@Value], FUSFormat));
  Expected := 123456789e300;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-123456789e300', '%#ee', [@Value], FUSFormat));
  Expected := -123456789e300;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('+123456789e-316', '%#eg', [@Value], FUSFormat));
  Expected := 123456789e-316;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('123456789e+300', '%#ee', [@Value], FUSFormat));
  Expected := 123456789e300;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-123456789e-316', '%#ef', [@Value], FUSFormat));
  Expected := -123456789e-316;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-123456789e+300', '%#ef', [@Value], FUSFormat));
  Expected := -123456789e300;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('123456789.123456789e300', '%#ef', [@Value], FUSFormat));
  Expected := 123456789.123456789e300;
  Assert.IsTrue(SameValue(Expected, Value));
{$ENDIF}
end;

procedure TTestUnformat.TestFormatSettings;
var
  Value, Expected: Double;
begin
  { Test the parsing of floating point numbers with US and Dutch format
    settings.
    The US format settings use '.' as decimal separator and ',' as thousand
    separator. With the Dutch format settings, its the other way around. }

  { The '.' is part of a US floating point value. }
  Assert.IsTrue(Unformat('123.456', '%f', [@Value], FUSFormat));
  Expected := 123.456;
  Assert.IsTrue(SameValue(Expected, Value));

  { The ',' is NOT part of a US floating point value, so the parsing will
    stop here. }
  Assert.IsTrue(Unformat('123,456', '%f', [@Value], FUSFormat));
  Expected := 123;
  Assert.IsTrue(SameValue(Expected, Value));

  { With %n, the '.' is part of a US floating point value. }
  Assert.IsTrue(Unformat('123.456', '%n', [@Value], FUSFormat));
  Expected := 123.456;
  Assert.IsTrue(SameValue(Expected, Value));

  { With %n, the ',' is a US thousand separator, and thus ignored. }
  Assert.IsTrue(Unformat('123,456', '%n', [@Value], FUSFormat));
  Expected := 123456;
  Assert.IsTrue(SameValue(Expected, Value));

  { Same tests for Dutch format settings }

  Assert.IsTrue(Unformat('123.456', '%f', [@Value], FNLFormat));
  Expected := 123;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('123,456', '%f', [@Value], FNLFormat));
  Expected := 123.456;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('123.456', '%n', [@Value], FNLFormat));
  Expected := 123456;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('123,456', '%n', [@Value], FNLFormat));
  Expected := 123.456;
  Assert.IsTrue(SameValue(Expected, Value));
end;

procedure TTestUnformat.TestHex;
var
  Value64: Int64;
  Value32: Int32;
begin
  { Test extraction of 32-bit and 64-bit hexadecimal values }

  Assert.IsTrue(Unformat('123456789abcdef', '%#64x', [@Value64]));
  Assert.AreEqual($123456789abcdef, Value64);

  Assert.IsTrue(Unformat('ABCDEF', '%x', [@Value32]));
  Assert.AreEqual($ABCDEF, Value32);

  Assert.IsTrue(Unformat('-123456789abcdef', '%#64x', [@Value64]));
  Assert.AreEqual(-$123456789abcdef, Value64);

  Assert.IsTrue(Unformat('-123456789ABCDEF', '%#64x', [@Value64]));
  Assert.AreEqual(-$123456789ABCDEF, Value64);
end;

procedure TTestUnformat.TestIndex;
var
  A, B: Integer;
begin
  { The 3rd specifier '%0:d' will put the 3rd value in variable number 0 (A=3) }
  Assert.IsTrue(Unformat('1 2 3 4', '%d %d %0:d', [@A, @B]));
  Assert.AreEqual(3, A);
  Assert.AreEqual(2, B);

  { After the '%0:d', the next specifier gets index 1 again, so variables 0 (A)
    and 1 (B) are overwritten by the 3rd and 4th values }
  Assert.IsTrue(Unformat('1 2 3 4', '%d %d %0:d %d', [@A, @B]));
  Assert.AreEqual(3, A);
  Assert.AreEqual(4, B);

  { Here, A and B are retrieved in reverse order }
  Assert.IsTrue(Unformat('1 2 3 4', '%d %d %1:d %0:d', [@A, @B]));
  Assert.AreEqual(4, A);
  Assert.AreEqual(3, B);
end;

procedure TTestUnformat.TestInt16;
var
  Value: Int16;
begin
  { Test extraction of 16-bit signed integers.
    NOTE: You need to specify #16 to signal that Value is a 16-bit type }
  Assert.IsTrue(Unformat('12345', '%#16d', [@Value]));
  Assert.AreEqual<Int16>(12345, Value);

  Assert.IsTrue(Unformat('-12345', '%#16d', [@Value]));
  Assert.AreEqual<Int16>(-12345, Value);

  { This input value doesn't fit in a 16-bit signed integer, so the returned
    value is clipped to 16 bits }
  Assert.IsTrue(Unformat('34567', '%#16d', [@Value]));
  Assert.AreEqual<Int16>(34567-65536, Value);
end;

procedure TTestUnformat.TestInt32;
var
  Value: Int32;
begin
  { Test extraction of 32-bit signed integers.
    NOTE: You can specify #32 to signal that Value is a 32-bit type, but this
    is not necessary because 32-bit is the default. }
  Assert.IsTrue(Unformat('12345678', '%#32d', [@Value]));
  Assert.AreEqual(12345678, Value);

  Assert.IsTrue(Unformat('-12345678', '%#32d', [@Value]));
  Assert.AreEqual(-12345678, Value);

  Assert.IsTrue(Unformat('3456789123', '%#32d', [@Value]));
  Assert.AreEqual(Int64(3456789123)-Int64($100000000), Value);

  Assert.IsTrue(Unformat('12345678', '%d', [@Value]));
  Assert.AreEqual(12345678, Value);

  Assert.IsTrue(Unformat('-12345678', '%d', [@Value]));
  Assert.AreEqual(-12345678, Value);

  { This input value doesn't fit in a 32-bit signed integer, so the returned
    value is clipped to 32 bits }
  Assert.IsTrue(Unformat('3456789123', '%d', [@Value]));
  Assert.AreEqual(Int64(3456789123)-Int64($100000000), Value);
end;

procedure TTestUnformat.TestInt64;
var
  Value: Int64;
begin
  { Test extraction of 64-bit signed integers.
    NOTE: You need to specify #64 to signal that Value is a 64-bit type }
  Assert.IsTrue(Unformat('123456789123456', '%#64d', [@Value]));
  Assert.AreEqual(123456789123456, Value);

  Assert.IsTrue(Unformat('-123456789123456', '%#64d', [@Value]));
  Assert.AreEqual(-123456789123456, Value);

  { This input value doesn't fit in a 64-bit signed integer, so the returned
    value is clipped to 64 bits }
  Assert.IsTrue(Unformat('12345678912345678912', '%#64d', [@Value]));
  Assert.AreEqual(-6101065161363872704, Value);

  { Nil output }
  Assert.IsTrue(Unformat('12345678912345678912', '%#64d', [nil]));
end;

procedure TTestUnformat.TestInt8;
var
  Value: Int8;
begin
  { Test extraction of 8-bit signed integers.
    NOTE: You need to specify #8 to signal that Value is a 8-bit type }
  Assert.IsTrue(Unformat('123', '%#8d', [@Value]));
  Assert.AreEqual<Int8>(123, Value);

  Assert.IsTrue(Unformat('-123', '%#8d', [@Value]));
  Assert.AreEqual<Int8>(-123, Value);

  { This input value doesn't fit in a 8-bit signed integer, so the returned
    value is clipped to 8 bits }
  Assert.IsTrue(Unformat('234', '%#8d', [@Value]));
  Assert.AreEqual<Int8>(234-256, Value);
end;

procedure TTestUnformat.TestInteger;
var
  Value: Integer;
begin
  { The '%i' specifier can be used to extract both Decimal and Hexadecimal
    values, depending on a '$', '0x' or '0X' prefix in the input string }
  Assert.IsTrue(Unformat('12345', '%i', [@Value]));
  Assert.AreEqual(12345, Value);

  Assert.IsTrue(Unformat('$12345', '%i', [@Value]));
  Assert.AreEqual($12345, Value);

  Assert.IsTrue(Unformat('0x12345', '%i', [@Value]));
  Assert.AreEqual($12345, Value);

  Assert.IsTrue(Unformat('0X12345', '%i', [@Value]));
  Assert.AreEqual($12345, Value);

  Assert.IsTrue(Unformat('-0X12345', '%i', [@Value]));
  Assert.AreEqual(-$12345, Value);

  Assert.IsTrue(Unformat('00', '%i', [@Value]));
  Assert.AreEqual(0, Value);
end;

procedure TTestUnformat.TestNil;
var
  A, B: String;
begin
  { You can pass nil values in the output array for values you don't care about }
  Assert.IsTrue(Unformat('The Quick Brown Fox', '%s %s %s %s', [@A, nil, nil, @B]));
  Assert.AreEqual('The', A);
  Assert.AreEqual('Fox', B);
end;

procedure TTestUnformat.TestPatternUnicode;
var
  Value: String;
begin
  { Same as TestPatternAnsi, but returns result in a String }

  Assert.IsTrue(Unformat('abcDEF012', '%[a]', [@Value]));
  Assert.AreEqual('a', Value);

  Assert.IsTrue(Unformat('abcDEF012', '%[ac]', [@Value]));
  Assert.AreEqual('a', Value);

  Assert.IsTrue(Unformat('abcDEF012', '%[a-c]', [@Value]));
  Assert.AreEqual('abc', Value);

  Assert.IsTrue(Unformat('abcDEF012', '%[a-cA-Z]', [@Value]));
  Assert.AreEqual('abcDEF', Value);

  Assert.IsTrue(Unformat('abcDEF012', '%[a-c0-5A-Z]', [@Value]));
  Assert.AreEqual('abcDEF012', Value);

  Assert.IsTrue(Unformat('abcDEF012', '%[^0-5]', [@Value]));
  Assert.AreEqual('abcDEF', Value);

  Assert.IsTrue(Unformat('abcDEF012', '%[^0]', [@Value]));
  Assert.AreEqual('abcDEF', Value);

  Assert.IsTrue(Unformat('abcDEF012', '%[^2]', [@Value]));
  Assert.AreEqual('abcDEF01', Value);

  Assert.IsTrue(Unformat('abcDEF012', '%5[a-c0-5A-Z]', [@Value]));
  Assert.AreEqual('abcDE', Value);

  Assert.IsTrue(Unformat('abc-DEF-012', '%[a-c0-5A-Z]', [@Value]));
  Assert.AreEqual('abc', Value);

  Assert.IsTrue(Unformat('abc-DEF-012', '%[-a-c0-5A-Z]', [@Value]));
  Assert.AreEqual('abc-DEF-012', Value);

  Assert.IsTrue(Unformat('abc[DEF]012', '%[][a-c0-5A-Z]', [@Value]));
  Assert.AreEqual('abc[DEF]012', Value);

  Assert.IsTrue(Unformat('abc DEF 012', '%[a-c0-5A-Z]', [@Value]));
  Assert.AreEqual('abc', Value);

  Assert.IsTrue(Unformat('abc DEF 012', '%[a-c0-5 A-Z]', [@Value]));
  Assert.AreEqual('abc DEF 012', Value);
end;

procedure TTestUnformat.TestPointer;
var
  P: Pointer;
begin
  { Returns a hexadecimal value into a pointer }
  Assert.IsTrue(Unformat('1234aBcD', '%p', [@P]));
  Assert.AreEqual($1234abcd, Integer(P));
end;

procedure TTestUnformat.TestSingle;
var
  Value, Expected: Single;
begin
  { Test extraction of Single-size floating point values, including values
    NaN and Inf.
    NOTE: You need to specify #s to signal that Value is of type Single }

  Assert.IsTrue(Unformat('NAN', '%#sf', [@Value], FUSFormat));
  Assert.IsTrue(IsNan(Value));

  Assert.IsTrue(Unformat('-NAN', '%#sf', [@Value], FUSFormat));
  Assert.IsTrue(IsNan(Value));

  Assert.IsTrue(Unformat('INF', '%#sf', [@Value], FUSFormat));
  Assert.IsTrue(IsInfinite(Value));

  Assert.IsTrue(Unformat('-INF', '%#sf', [@Value], FUSFormat));
  Assert.IsTrue(IsInfinite(Value));

  Assert.IsTrue(Unformat('123.456', '%#sf', [@Value], FUSFormat));
  Expected := 123.456;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-123.456', '%#sf', [@Value], FUSFormat));
  Expected := -123.456;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('.456', '%#sf', [@Value], FUSFormat));
  Expected := 0.456;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('123e12', '%#sf', [@Value], FUSFormat));
  Expected := 123e12;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-123e12', '%#sf', [@Value], FUSFormat));
  Expected := -123e12;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('+123e-12', '%#sf', [@Value], FUSFormat));
  Expected := 123e-12;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('123e+12', '%#sf', [@Value], FUSFormat));
  Expected := 123e12;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-123e-12', '%#sf', [@Value], FUSFormat));
  Expected := -123e-12;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('-123e+12', '%#sf', [@Value], FUSFormat));
  Expected := -123e12;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsTrue(Unformat('123.456e12', '%#sf', [@Value], FUSFormat));
  Expected := 123.456e12;
  Assert.IsTrue(SameValue(Expected, Value));

  Assert.IsFalse(Unformat('-', '%#sf', [@Value], FUSFormat));
  Assert.IsFalse(Unformat('abc', '%#sf', [@Value], FUSFormat));
end;

procedure TTestUnformat.TestStringUnicode;
var
  Value: String;
begin
  { Same as TestStringAnsi, but returns result in a String }

  Assert.IsTrue(Unformat('Abc', '%s', [@Value]));
  Assert.AreEqual('Abc', Value);

  { The #u specifier is optional when Unformat is used }
  Assert.IsTrue(Unformat('Abc', '%#us', [@Value]));
  Assert.AreEqual('Abc', Value);

  Assert.IsTrue(Unformat('Abc Def', '%s', [@Value]));
  Assert.AreEqual('Abc', Value);

  Assert.IsTrue(Unformat('Abc Def', 'Abc %s', [@Value]));
  Assert.AreEqual('Def', Value);

  Assert.IsTrue(Unformat('Abc Def', 'abc %s', [@Value]));
  Assert.AreEqual('Def', Value);

  Assert.IsFalse(Unformat('Abc Def', 'abc %s', [@Value], [TUnformatOption.CaseSensitive]));

  Assert.IsTrue(Unformat('Abc Def', '%2s', [@Value]));
  Assert.AreEqual('Ab', Value);

  Assert.IsTrue(Unformat('Abc Def', 'Abc %-2s', [@Value]));
  Assert.AreEqual('De', Value);

  Assert.IsTrue(Unformat('Abc Def', '%5s', [@Value]));
  Assert.AreEqual('Abc', Value);
end;

procedure TTestUnformat.TestUInt16;
var
  Value: UInt16;
begin
  { Test extraction of 16-bit unsigned integers.
    NOTE: You need to specify #16 to signal that Value is a 16-bit type }
  Assert.IsTrue(Unformat('12345', '%#16u', [@Value]));
  Assert.AreEqual(12345, Value);

  { This input value doesn't fit in a 16-bit unsigned integer, so the returned
    value is clipped to 16 bits }
  Assert.IsTrue(Unformat('-12345', '%#16u', [@Value]));
  Assert.AreEqual(-12345+65536, Value);

  Assert.IsTrue(Unformat('34567', '%#16u', [@Value]));
  Assert.AreEqual(34567, Value);

  { This input value doesn't fit in a 16-bit unsigned integer, so the returned
    value is clipped to 16 bits }
  Assert.IsTrue(Unformat('345678', '%#16u', [@Value]));
  Assert.AreEqual(345678 and $FFFF, Value);
end;

procedure TTestUnformat.TestUInt32;
var
  Value: UInt32;
begin
  { Test extraction of 32-bit unsigned integers.
    NOTE: You can specify #32 to signal that Value is a 32-bit type, but this
    is not necessary because 32-bit is the default. }
  Assert.IsTrue(Unformat('12345678', '%#32u', [@Value]));
  Assert.AreEqual(12345678, Value);

  { This input value doesn't fit in a 32-bit unsigned integer, so the returned
    value is clipped to 32 bits }
  Assert.IsTrue(Unformat('-12345678', '%#32u', [@Value]));
  Assert.AreEqual(Int64(-12345678)+Int64($100000000), Value);

  Assert.IsTrue(Unformat('3456789123', '%#32u', [@Value]));
  Assert.AreEqual(3456789123, Value);

  Assert.IsTrue(Unformat('12345678', '%u', [@Value]));
  Assert.AreEqual(12345678, Value);

  Assert.IsTrue(Unformat('-12345678', '%u', [@Value]));
  Assert.AreEqual(Int64(-12345678)+Int64($100000000), Value);

  Assert.IsTrue(Unformat('3456789123', '%u', [@Value]));
  Assert.AreEqual(3456789123, Value);
end;

procedure TTestUnformat.TestUInt64;
var
  Value: UInt64;
begin
  { Test extraction of 64-bit unsigned integers.
    NOTE: You need to specify #64 to signal that Value is a 64-bit type }
  Assert.IsTrue(Unformat('123456789123456', '%#64u', [@Value]));
  Assert.AreEqual<UInt64>(123456789123456, Value);

  { This input value doesn't fit in a 64-bit unsigned integer, so the returned
    value is clipped to 64 bits }
  Assert.IsTrue(Unformat('-123456789123456', '%#64u', [@Value]));
  Assert.AreEqual<Int64>(-123456789123456, Int64(Value));

  Assert.IsTrue(Unformat('12345678912345678912', '%#64u', [@Value]));
  Assert.AreEqual<Int64>(Int64(12345678912345678912), Int64(Value));
end;

procedure TTestUnformat.TestUInt8;
var
  Value: UInt8;
begin
  { Test extraction of 8-bit unsigned integers.
    NOTE: You need to specify #8 to signal that Value is a 8-bit type }
  Assert.IsTrue(Unformat('123', '%#8u', [@Value]));
  Assert.AreEqual<UInt8>(123, Value);

  { This input value doesn't fit in a 8-bit unsigned integer, so the returned
    value is clipped to 8 bits }
  Assert.IsTrue(Unformat('-123', '%#8u', [@Value]));
  Assert.AreEqual<UInt8>(-123+256, Value);

  Assert.IsTrue(Unformat('234', '%#8u', [@Value]));
  Assert.AreEqual<UInt8>(234, Value);

  { This input value doesn't fit in a 8-bit unsigned integer, so the returned
    value is clipped to 8 bits }
  Assert.IsTrue(Unformat('345', '%#8u', [@Value]));
  Assert.AreEqual<UInt8>(345 and $FF, Value);
end;

procedure TTestUnformat.TestWhiteSpace;
var
  S: String;
  U: Cardinal;
begin
  Assert.IsTrue(Unformat('  Foo', '  %s', [@S]));
  Assert.AreEqual('Foo', S);

  Assert.IsTrue(Unformat('  123', '%u', [@U]));
  Assert.AreEqual(123, U);
end;

procedure TTestUnformat.TestWidth;
var
  S: String;
begin
  Assert.IsTrue(Unformat('JabbaDabbaDoo', '%s', [@S]));
  Assert.AreEqual('JabbaDabbaDoo', S);

  { Extract a string up to 5 characters }
  Assert.IsTrue(Unformat('JabbaDabbaDoo', '%5s', [@S]));
  Assert.AreEqual('Jabba', S);

  { The optional precision specifier '.3' is ignored }
  Assert.IsTrue(Unformat('JabbaDabbaDoo', '%5.3s', [@S]));
  Assert.AreEqual('Jabba', S);

  { As is the optional left-justification specifier '-' is ignored }
  Assert.IsTrue(Unformat('JabbaDabbaDoo', '%-10s', [@S]));
  Assert.AreEqual('JabbaDabba', S);

  { The first 5 characters are ignored (by specifying a nil output) and the
    next 5 characters are returned. }
  Assert.IsTrue(Unformat('JabbaDabbaDoo', '%5s%5s', [nil, @S]));
  Assert.AreEqual('Dabba', S);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestUnformat);

end.
