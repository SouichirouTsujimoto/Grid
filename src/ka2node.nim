import ka2token

type Precedence* = enum
  Lowest = 0
  Equals = 1
  Lg
  Sum
  Product
  Prefix
  Call

type NodeKind* = enum
  nkNil
  nkIdent
  nkIntLiteral
  nkFloatLiteral
  nkBoolLiteral
  nkCharLiteral
  nkStringLiteral
  nkPrefixExpression
  nkInfixExpression
  nkLetStatement
  nkDefineStatement
  nkReturnStatement
  nkRetrunExpression
  nkExpressionStatement
  nkCallExpression
  nkIfExpression
  nkIfAndElseExpression

proc tokenPrecedence*(tok: Token): Precedence =
  case tok.Type
  of LPAREN:          return Call
  of SLASH, ASTERISC: return Product
  of PLUS, MINUS:     return Sum
  of LT, GT:          return Lg
  of EQ:              return Equals
  else:               return Lowest

type 
  # ノードクラス
  Node* = ref object of RootObj
    kind*:              NodeKind
    token*:             Token
    operator*:          string
    left*:              Node
    right*:             Node
    function*:          Node
    args*:              seq[Node]
    intValue*:          int
    floatValue*:        float
    identValue*:        string
    boolValue*:         bool
    charValue*:         char
    stringValue*:       string
    let_name*:          Node
    let_value*:         Node
    define_name*:       Node
    define_args*:       seq[Node]
    define_block*:      BlockStatement
    condition*:         Node
    consequence*:       BlockStatement
    alternative*:       BlockStatement
    return_statement*: Node 
    return_expression*: Node
  # ブロック文クラス
  BlockStatement* = ref object of RootObj
    token*: Token
    statements*: seq[Node]