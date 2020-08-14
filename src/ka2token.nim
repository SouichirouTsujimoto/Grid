import tables

type Token* = ref object of RootObj
  Type*: string
  Literal*: string

const
  ILLEGAL*      = "ILLEGAL"
  EOF*          = "EOF"
  # リテラル
  IDENT*        = "IDENT"
  INT*          = "INT"
  FLOAT*        = "FLOAT"
  CHAR*         = "CHAR"
  STRING*       = "STRING"
  # 演算子
  ASSIGN*       = "="
  PLUS*         = "+"
  MINUS*        = "-"
  ASTERISC*     = "*"
  SLASH*        = "/"
  # 比較演算子
  LT*           = "<"
  GT*           = ">"
  LE*           = "<="
  GE*           = ">="
  EQ*           = "=="
  NE*           = "!="
  NOT*          = "!"
  PIPE*         = "|>"
  # デリミタ
  COMMA*        = ","
  # 括弧
  LPAREN*       = "("
  RPAREN*       = ")"
  # キーワード
  TRUE*         = "TRUE"
  FALSE*        = "FALSE"
  LET*          = "LET"
  DEFINE*       = "DEFINE"
  RETURN*       = "RETURN"
  IF*           = "IF"
  ELIF*         = "ELIF"
  ELSE*         = "ELSE"
  DO*           = "DO"
  END*          = "END"

let keywords = {
  "True"   : TRUE,
  "False"  : FALSE,
  "let"    : LET,
  "def"    : DEFINE,
  "return" : RETURN,
  "if"     : IF,
  "elif"   : ELIF,
  "else"   : ELSE,
  "do"     : DO,
  "end"    : END,
}.newTable

proc LookupIdent*(ident: string): string =
  if keywords.hasKey(ident):
    return keywords[ident]
  return IDENT
