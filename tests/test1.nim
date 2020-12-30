import ../src/ka2parser, ../src/ka2cpp, ../src/ka2shaping, ../src/ka2node, ../src/ka2token
import unittest, strutils

proc findStr(code: string, str: string): bool =
  return code.count(str) != 0

proc makeProgram(str: string): string =
  var code = "main do\n" & str & "\nend"
  var nodes = code.makeAST().astShaping(false, true)[0]
  var root = Node(
    kind:        nkRoot,
    token:       Token(Type: "", Literal: ""),
    child_nodes: nodes,
  )
  return makeCppCode(root, 0, true)

suite "operators":
  test "1 + 1":
    initTables()
    let program = "1 + 1".makeProgram()
    check(program.findStr("( 1 + 1 )"))
  test "1 + -1 * 2":
    initTables()
    let program = "1 + -1 * 2".makeProgram()
    check(program.findStr("( 1 + ( -1 * 2 ) )"))
  test "(1 + 1) * 2":
    initTables()
    let program = "(1 + 1) * 2".makeProgram()
    check(program.findStr("( ( 1 + 1 ) * 2 )"))
  test "1 + (1 * 2)":
    initTables()
    let program = "1 + (1 * 2)".makeProgram()
    check(program.findStr("( 1 + ( 1 * 2 ) )"))
  test "\"Hello\" == \"Hello\"":
    initTables()
    let program = "\"Hello\" == \"Hello\"".makeProgram()
    check(program.findStr("( \"Hello\" == \"Hello\" )"))

suite "plus":
  test "plus(1, 3)":
    initTables()
    let program = "plus(1, 3)".makeProgram()
    check(program.findStr("plus ( 1 , 3 )"))
  
suite "minu":
  test "minu(4, plus(3, 2))":
    initTables()
    let program = "minu(1, 3)".makeProgram()
    check(program.findStr("minu ( 1 , 3 )"))

suite "mult":
  test "mult(4, plus(3, 2))":
    initTables()
    let program = "mult(1, 3)".makeProgram()
    check(program.findStr("mult ( 1 , 3 )"))

suite "divi":
  test "divi(4, plus(3, 2))":
    initTables()
    let program = "divi(1, 3)".makeProgram()
    check(program.findStr("divi ( 1 , 3 )"))

suite "|>":
  test "\"Hello\" |> print()":
    initTables()
    let program = "\"Hello\" |> print()".makeProgram()
    check(program.findStr("print ( \"Hello\" )"))
  test "1 |> plus(2) |> plus(3) |> divi(6)":
    initTables()
    let program = "1 |> plus(2) |> plus(3) |> divi(6)".makeProgram()
    check(program.findStr("ka23::divi ( ka23::plus ( ka23::plus ( 1 , 2 ) , 3 ) , 6 ) ;"))
  test "(3 |> plus(10)) + (1 |> plus(1)) |> toString() |> print()":
    initTables()
    let program = "(3 |> plus(10)) + (1 |> plus(1)) |> toString() |> print()".makeProgram()
    check(program.findStr("ka23::print ( ka23::toString ( ( ka23::plus ( 3 , 10 ) + ka23::plus ( 1 , 1 ) ) ) ) ;"))

suite "let":
  test "let int a = 10":
    initTables()
    let program = "let int a = 10".makeProgram()
    check(program.findStr("int * a = new int ;"))
    check(program.findStr("* a = 10 ;"))
    check(program.findStr("delete a ;"))
  test "let int a = 10 + 10":
    initTables()
    let program = "let int a = 10 + 10".makeProgram()
    check(program.findStr("int * a = new int ;"))
    check(program.findStr("* a = ( 10 + 10 ) ;"))
    check(program.findStr("delete a ;"))
  test "let float a = 1.5":
    initTables()
    let program = "let float a = 1.5".makeProgram()
    check(program.findStr("float * a = new float ;"))
    check(program.findStr("* a = 1.5f ;"))
    check(program.findStr("delete a ;"))
  test "let char a = \'A\'":
    initTables()
    let program = "let char a = \'A\'".makeProgram()
    check(program.findStr("char * a = new char ;"))
    check(program.findStr("* a = \'A\' ;"))
    check(program.findStr("delete a ;"))
  test "let string a = \"Hello\"":
    initTables()
    let program = "let string a = \"Hello\"".makeProgram()
    check(program.findStr("std::string * a = new std::string ;"))
    check(program.findStr("* a = \"Hello\" ;"))
    check(program.findStr("delete a ;"))
  test "let bool a = True":
    initTables()
    let program = "let bool a = True".makeProgram()
    check(program.findStr("bool * a = new bool ;"))
    check(program.findStr("* a = true ;"))
    check(program.findStr("delete a ;"))
  test "let bool a = 1 >= 10":
    initTables()
    let program = "let bool a = 1 >= 10".makeProgram()
    check(program.findStr("bool * a = new bool ;"))
    check(program.findStr("* a = ( 1 >= 10 ) ;"))
    check(program.findStr("delete a ;"))

suite "var":
  test "var int a = 10":
    initTables()
    let program = "var int a = 10".makeProgram()
    check(program.findStr("int a = 10 ;"))
  test "var int a = 10 + 10":
    initTables()
    let program = "var int a = 10 + 10".makeProgram()
    check(program.findStr("int a = ( 10 + 10 ) ;"))
  test "var float a = 1.5":
    initTables()
    let program = "var float a = 1.5".makeProgram()
    check(program.findStr("float a = 1.5f ;"))
  test "var char a = \'A\'":
    initTables()
    let program = "var char a = \'A\'".makeProgram()
    check(program.findStr("char a = \'A\' ;"))
  test "var string a = \"Hello\"":
    initTables()
    let program = "var string a = \"Hello\"".makeProgram()
    check(program.findStr("std::string a = \"Hello\" ;"))
  test "var bool a = True":
    initTables()
    let program = "var bool a = True".makeProgram()
    check(program.findStr("bool a = true ;"))
  test "var bool a = 1 >= 10":
    initTables()
    let program = "var bool a = 1 >= 10".makeProgram()
    check(program.findStr("bool a = ( 1 >= 10 ) ;"))

suite ":=":
  test "var int a = 10 a := 20":
    initTables()
    let program = "var int a = 10 a := 20".makeProgram()
    check(program.findStr("int a = 10 ;"))
    check(program.findStr("a = 20 ;"))
  test "var int a = 10 var int b = 20 a := b := 20":
    initTables()
    let program = "var int a = 10 var int b = 20 a := b := 20".makeProgram()
    check(program.findStr("int a = 10 ;"))
    check(program.findStr("int b = 20 ;"))
    check(program.findStr("a = b = 20 ;"))
  test "var int a = 10 var int b = 20 var int c = 30 a := b := c := 20":
    initTables()
    let program = "var int a = 10 var int b = 20 var int c = 30 a := b := c := 20".makeProgram()
    check(program.findStr("int a = 10 ;"))
    check(program.findStr("int b = 20 ;"))
    check(program.findStr("int c = 30 ;"))
    check(program.findStr("a = b = c = 20 ;"))

suite "def":
  test "def int a(int b) do return b * 2 end":
    initTables()
    let program = "def int a(int b) do return b * 2 end".makeProgram()
    check(program.findStr("int a ( int b ) {"))
    check(program.findStr("return ( ( b * 2 ) ) ;"))
    check(program.findStr("}"))
  test "def int a(int b, int c) do return b / c end":
    initTables()
    let program = "def int a(int b, int c) do return b / c end".makeProgram()
    check(program.findStr("int a ( int b , int c ) {"))
    check(program.findStr("return ( ( b / c ) ) ;"))
    check(program.findStr("}"))
  test "def bool a(int b, bool c) do let bool d = b == 10 return c == d end":
    initTables()
    let program = "def bool a(int b, bool c) do let bool d = b == 10 return c == d end".makeProgram()
    check(program.findStr("bool a ( int b , bool c ) {"))
    check(program.findStr("bool * d = new bool ;"))
    check(program.findStr("* d = ( b == 10 ) ;"))
    check(program.findStr("return ( ( c == * d ) ) ;"))
    check(program.findStr("delete d ;"))
    check(program.findStr("}"))

suite "if":
  test "if 1 + 1 <= 3 do print(\"OK\") end":
    initTables()
    let program = "if 1 + 1 <= 3 do print(\"OK\") end".makeProgram()
    check(program.findStr("if ( ( ( 1 + 1 ) <= 3 ) ) {"))
    check(program.findStr("ka23::print ( \"OK\" ) ;"))
    check(program.findStr("}"))
  test "if 5 + 5 == 10 do print(\"5 + 5 = 10\") else print(\"?\") end":
    initTables()
    let program = "if 5 + 5 == 10 do print(\"5 + 5 = 10\") else print(\"?\") end".makeProgram()
    check(program.findStr("if ( ( ( 5 + 5 ) == 10 ) ) {"))
    check(program.findStr("ka23::print ( \"5 + 5 = 10\" ) ;"))
    check(program.findStr("}"))
    check(program.findStr("else {"))
    check(program.findStr("ka23::print ( \"?\" ) ;"))
    check(program.findStr("}"))
  test "if True do return \"1\" elif True do return \"2\" else return \"3\" end":
    initTables()
    let program = "if True do return \"1\" elif True do return \"2\" else return \"3\" end".makeProgram()
    check(program.findStr("if ( true ) {"))
    check(program.findStr("return ( \"1\" ) ;"))
    check(program.findStr("}"))
    check(program.findStr("else if ( true ) {"))
    check(program.findStr("return ( \"2\" ) ;"))
    check(program.findStr("}"))
    check(program.findStr("else {"))
    check(program.findStr("return ( \"3\" ) ;"))
    check(program.findStr("}"))
  test "if 1 == 3 do print(\"ok\") elif 4 != 5 do print(True) elif False do print(\"違う\") else print(\"else\") end":
    initTables()
    let program = "if 1 == 3 do print(\"ok\") elif 4 != 5 do print(toString(True)) elif False do print(\"違う\") else print(\"else\") end".makeProgram()
    check(program.findStr("if ( ( 1 == 3 ) ) {"))
    check(program.findStr("ka23::print ( \"ok\" ) ;"))
    check(program.findStr("}"))
    check(program.findStr("else if ( ( 4 != 5 ) ) {"))
    check(program.findStr("ka23::print ( ka23::toString ( true ) ) ;"))
    check(program.findStr("}"))
    check(program.findStr("else if ( false ) {"))
    check(program.findStr("ka23::print ( \"違う\" ) ;"))
    check(program.findStr("}"))
    check(program.findStr("else {"))
    check(program.findStr("ka23::print ( \"else\" ) ;"))
    check(program.findStr("}"))

suite "ifex":
  test "ifex 5 + 5 == 10 : \"5 + 5 = 10\" : \"?\"":
    initTables()
    let program = "ifex 5 + 5 == 10 : \"5 + 5 = 10\" : \"?\"".makeProgram()
    check(program.findStr("( ( ( 5 + 5 ) == 10 ) ? \"5 + 5 = 10\" : \"?\" ) ;"))
  test "ifex True : \"1\" : ifex True : \"2\" : \"3\"":
    initTables()
    let program = "ifex True : \"1\" : ifex True : \"2\" : \"3\"".makeProgram()
    check(program.findStr("( true ? \"1\" : ( true ? \"2\" : \"3\" ) ) ;"))

  test "ifex True : ifex False : \"1\" : \"4\" : ifex True : \"2\" : \"3\"":
    initTables()
    let program = "ifex True : ifex False : \"1\" : \"4\" : ifex True : \"2\" : \"3\"".makeProgram()
    check(program.findStr("( true ? ( false ? \"1\" : \"4\" ) : ( true ? \"2\" : \"3\" ) ) ;"))
  test "let int a = ifex 2 + 2 == 5 : 1984 : ifex 2 + 2 == 4 : 2020 : 0":
    initTables()
    let program = "let int a = ifex 2 + 2 == 5 : 1984 : ifex 2 + 2 == 4 : 2020 : 0".makeProgram()
    check(program.findStr("int * a = new int ;"))
    check(program.findStr("* a = ( ( ( 2 + 2 ) == 5 ) ? 1984 : ( ( ( 2 + 2 ) == 4 ) ? 2020 : 0 ) ) ;"))
    check(program.findStr("delete a"))

suite "print":
  test "print(\"Hello\")":
    initTables()
    let program = "print(\"Hello\")".makeProgram()
    check(program.findStr("ka23::print ( \"Hello\" ) ;"))
  test "print(toString(2005))":
    initTables()
    let program = "print(toString(2005))".makeProgram()
    check(program.findStr("ka23::print ( ka23::toString ( 2005 ) ) ;"))
  test "let char ch = \'Q\' print(toString(ch))":
    initTables()
    let program = "let char ch = \'Q\' print(toString(ch))".makeProgram()
    check(program.findStr("char * ch = new char ;"))
    check(program.findStr("* ch = \'Q\' ;"))
    check(program.findStr("ka23::print ( ka23::toString ( * ch ) ) ;"))

suite "array":
  test "let array string a = {\"Hello\", \"World\"}":
    initTables()
    let program = "let array string a = {\"Hello\", \"World\"}".makeProgram()
    check(program.findStr("std::vector<std::string> * a = new std::vector<std::string> ;"))
    check(program.findStr("* a = { \"Hello\" , \"World\" } ;"))
  test "let array array int a = {{1, 2}, {1}}":
    initTables()
    let program = "let array array int a = {{1, 2}, {1}}".makeProgram()
    check(program.findStr("std::vector<std::vector<int>> * a = new std::vector<std::vector<int>> ;"))
    check(program.findStr("* a = { { 1 , 2 } , { 1 } } ;"))
  test "var array array int a = {{2, 5, 6}, {4, 5}}":
    initTables()
    let program = "var array array int a = {{2, 5, 6}, {4, 5}}".makeProgram()
    check(program.findStr("std::vector<std::vector<int>> a = { { 2 , 5 , 6 } , { 4 , 5 } } ;"))
  test "var array array array int a = {{{2}, {5, 6}}, {{4, 1}, {5}}}":
    initTables()
    let program = "var array array array int a = {{{2}, {5, 6}}, {{4, 1}, {5}}}".makeProgram()
    check(program.findStr("std::vector<std::vector<std::vector<int>>> a = { { { 2 } , { 5 , 6 } } , { { 4 , 1 } , { 5 } } } ;"))

suite "[]":
  test "let array int a = {1, 2} a!!1":
    initTables()
    let program = "let array int a = {1, 2} a!!1".makeProgram()
    check(program.findStr("std::vector<int> * a = new std::vector<int> ;"))
    check(program.findStr("* a = { 1 , 2 } ;"))
    check(program.findStr("* a [ 1 ] ;"))
  test "let array array int a = {{1, 2}, {3, 4}} print(toString(a!!1!!0))":
    initTables()
    let program = "let array array int a = {{1, 2}, {3, 4}} print(toString(a!!1!!0))".makeProgram()
    check(program.findStr("std::vector<std::vector<int>> * a = new std::vector<std::vector<int>> ;"))
    check(program.findStr("* a = { { 1 , 2 } , { 3 , 4 } } ;"))
    check(program.findStr("ka23::print ( ka23::toString ( * a [ 1 ] [ 0 ] ) ) ;"))
  
suite "for":
  test "for string a <- {\"a\", \"b\", \"c\"} do print(a) end":
    initTables()
    let program = "for string a <- {\"a\", \"b\", \"c\"} do print(a) end".makeProgram()
    check(program.findStr("for ( std::string a : { \"a\" , \"b\" , \"c\" } ) {"))
    check(program.findStr("ka23::print ( a ) ;"))
    check(program.findStr("}"))
  test "for string a <- {\"a\", \"b\", \"c\"} do for string b <- {\"a\", \"b\", \"c\"} do for string c <- {\"a\", \"b\", \"c\"} do print(c) end end end":
    initTables()
    let program = "for string a <- {\"a\", \"b\", \"c\"} do for string b <- {\"a\", \"b\", \"c\"} do for string c <- {\"a\", \"b\", \"c\"} do print(c) end end end".makeProgram()
    check(program.findStr("for ( std::string a : { \"a\" , \"b\" , \"c\" } ) {"))
    check(program.findStr("for ( std::string b : { \"a\" , \"b\" , \"c\" } ) {"))
    check(program.findStr("for ( std::string c : { \"a\" , \"b\" , \"c\" } ) {"))
    check(program.findStr("ka23::print ( c ) ;"))
    check(program.findStr("}"))
    check(program.findStr("}"))
    check(program.findStr("}"))
  test "var int x = 0 for int a <- {1, 2, 3} do x := x + a end":
    initTables()
    let program = "var int x = 0 for int a <- {1, 2, 3} do x := x + a end".makeProgram()
    check(program.findStr("int x = 0 ;"))
    check(program.findStr("for ( int a : { 1 , 2 , 3 } ) {"))
    check(program.findStr("x = ( x + a ) ;"))
    check(program.findStr("}"))

suite "len":
  test "var array int a = {1, 2} len(a)":
    initTables()
    let program = "var array int a = {1, 2} len(a)".makeProgram()
    check(program.findStr("std::vector<int> a = { 1 , 2 } ;"))
    check(program.findStr("ka23::len ( a ) ;"))

  test "var array int a = {1, 2} a |> len()":
    initTables()
    let program = "var array int a = {1, 2} a |> len()".makeProgram()
    check(program.findStr("std::vector<int> a = { 1 , 2 } ;"))
    check(program.findStr("ka23::len ( a ) ;"))

suite "head":
  test "let array int x = {1, 2} print(x |> head()|> toString())":
    initTables()
    let program = "let array int x = {1, 2} print(x |> head() |> toString())".makeProgram()
    check(program.findStr("std::vector<int> * x = new std::vector<int> ;"))
    check(program.findStr("* x = { 1 , 2 } ;"))
    check(program.findStr("ka23::print ( ka23::toString ( ka23::head ( * x ) ) ) ;"))

suite "tail":
  test "let array int x = {1, 2, -3} x |> tail()":
    initTables()
    let program = "let array int x = {1, 2, -3} x |> tail()".makeProgram()
    check(program.findStr("std::vector<int> * x = new std::vector<int> ;"))
    check(program.findStr("* x = { 1 , 2 , -3 } ;"))
    check(program.findStr("ka23::tail ( * x ) ;"))

suite "last":
  test "let array int x = {1, 2} print(x |> last())":
    initTables()
    let program = "let array int x = {1, 2} x |> last()".makeProgram()
    check(program.findStr("std::vector<int> * x = new std::vector<int> ;"))
    check(program.findStr("* x = { 1 , 2 } ;"))
    check(program.findStr("ka23::last ( * x ) ;"))

suite "init":
  test "let array int x = {1, 2, -3} x |> init()":
    initTables()
    let program = "let array int x = {1, 2, -3} x |> init()".makeProgram()
    check(program.findStr("std::vector<int> * x = new std::vector<int> ;"))
    check(program.findStr("* x = { 1 , 2 , -3 } ;"))
    check(program.findStr("ka23::init ( * x ) ;"))

suite "toString":
  test "let string a = toString(10)":
    initTables()
    let program = "let string a = toString(10)".makeProgram()
    check(program.findStr("std::string * a = new std::string ;"))
    check(program.findStr("* a = ka23::toString ( 10 ) ;"))
    check(program.findStr("delete a ;"))
  test "let string a = toString(True)":
    initTables()
    let program = "let string a = toString(True)".makeProgram()
    check(program.findStr("std::string * a = new std::string ;"))
    check(program.findStr("* a = ka23::toString ( true ) ;"))

suite "map":
  test "map({1, 2, 3}, plus(1))":
    initTables()
    let program = "map({1, 2, 3}, plus(1))".makeProgram()
    check(program.findStr("ka23::map ( { 1 , 2 , 3 } , [] ( int i ) { return ka23::plus ( i , 1 ) ; } ) ;"))
  test "let array int a = {1, 2, 3} map(a, plus(1))":
    initTables()
    let program = "let array int a = {1, 2, 3} map(a, plus(1))".makeProgram()
    check(program.findStr("std::vector<int> * a = new std::vector<int> ;"))
    check(program.findStr("* a = { 1 , 2 , 3 } ;"))
    check(program.findStr("ka23::map ( * a , [] ( int i ) { return ka23::plus ( i , 1 ) ; } ) ;"))
    check(program.findStr("delete a ;"))