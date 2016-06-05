%lex
%%

\s+                         /* skip whitespace */
\r+                         /* skip linebreak */
\n+                         /* skip linebreak */
[0-9]+("."[0-9]+)?\b        return 'NUMCONST'
"using namespace std;"      return 'usingnamespacestd;'
"true"                      return 'true'
"false"                     return 'false'
"if"                        return 'if'
"else"                      return 'else'
"switch"                    return 'switch'
"case"                      return 'case'
"default"                   return 'default'
"while"                     return 'while'
"for"                       return 'for'
"break"                     return 'break'
"return"                    return 'return'
"int"                       return 'int'
"float"                     return 'float'
"char*"                     return 'char*'
"char"                      return 'char'
"bool"                      return 'bool'
"gets"                      return 'gets'
"puts"                      return 'puts'
"strlen"                    return 'strlen'
"printf"                    return 'printf'
"main"                      return 'main'
"void"                      return 'void'
"string"                    return 'string'
"push"                      return 'push'
"pop"                       return 'pop'
"top"                       return 'top'
[a-zA-Z]?\"(\\.|[^\\"])*\"  return 'STRINGCONST'
"<"[a-zA-Z]+("."h)?">"      return 'INCLUDESTRING'
[a-zA-Z]+                   return 'ID'
[a-zA-Z]?\'(\\.|[^\\'])*\'  return 'CHARCONST'
\"                          return '"'
"."                         return '.'
"+="                        return '+='
"-="                        return '-='
"*="                        return '*='
"/="                        return '/='
"++"                        return '++'
"--"                        return '--'
"<="                        return '<='
">="                        return '>='
"=="                        return '=='
"!="                        return '!='
"="                         return '='
","                         return ','
"*"                         return '*'
"/"                         return '/'
"-"                         return '-'
"+"                         return '+'
"{"                         return '{'
"}"                         return '}'
";"                         return ';'
"!"                         return '!'
"["                         return '['
"]"                         return ']'
"<"                         return '<'
">"                         return '>'
"%"                         return '%'
"("                         return '('
")"                         return ')'
"||"                        return '||'
"&&"                        return '&&'
"|"                         return '|'
"?"                         return '?'
"!"                         return '!'
":"                         return ':'
"#include"                  return '#include'
">"                         return '>'
<<EOF>>                     return 'EOF'
.                           return 'INVALID'

/lex

%start p
%%

p
    : program EOF
        { var fs = require('fs');
          var beautify = require('js-beautify').js_beautify;
          var out = beautify($1);
          fs.writeFile('out.js', out);
          typeof console !== 'undefined' ? console.log(out) : print(out);
          return out; }
    ;

program
    : incList decls
        { $$ = $2; }
    | decls
        { $$ = $1; }
    ;

incList
    : incList include
        { $$ = ""; }
    | include
        { $$ = ""; }
    ;

include
    : '#include' INCLUDESTRING
        { $$ = ""; }
    | 'usingnamespacestd;'
        { $$ = ""; }
    ;

decls
    : decls decl
        { $$ = $1 + $2; }
    | decl
        { $$ = $1; }
    ;

decl
    : varDecl
        { $$ = $1; }
    | funcDecl
        { $$ = $1; }
    ;

varDecl
    : type varDeclId ';'
        { $$ = "var " + $2 + ";"; }
    | type ID '=' immutable ';'
        { $$ = "var " + $2 + "=" + $4 + ";"; }
    | type ID '[' NUMCONST ']' '=' immutable ';'
        { $$ = "var " + $2 + "=" + $7 + ';'; }
    ;

type
    : 'int'
        { $$ = "int"; }
    | 'char'
        { $$ = "char"; }
    | 'bool'
        { $$ = "bool"; }
    | 'char*'
        { $$ = "char*"; }
    | 'void'
        { $$ = "void"; }
    | 'string'
        { $$ = "string"; }
    | 'float'
        { $$ = "float"; }
    ;

varDeclId
    : ID
        { $$ = $1; }
    | ID '[' NUMCONST ']'
        { $$ = $1 + " = Array(" + $3 + ")";}
    ;

funcDecl
    : type ID '(' params ')' statement
        { $$ = "function " + $2 + "(" + $4 + ")" + $6; }
    | type main '(' ')' statement
        { $$ = "(function(){" + $5 + "}())" ; }
    ;

params
    : paramList
        { $$ = $1; }
    |
        { $$ = ""; }
    ;

paramList
    : paramList ',' paramTypeList
        { $$ = $1 + ", " + $3; }
    | paramTypeList
        { $$ = $1; }
    ;

paramTypeList
    : type paramId
        { $$ = $2; }
    ;

paramId
    : ID
        { $$ = $1; }
    ;

statement
    : expressionStmt
        { $$ = $1; }
    | compoundStmt
        { $$ = $1; }
    | selectionStmt
        { $$ = $1; }
    | iterationStmt
        { $$ = $1; }
    | returnStmt
        { $$ = $1; }
    | breakStmt
        { $$ = $1; }
    | labeledStmt
        { $$ = $1; }
    ;

getsStmt
    : 'gets' '(' ID ')'
        { $$ = "jsGets(" + $3 + ")" }
    ;

putsStmt
    : 'puts' '(' immutable ')'
        { $$ = "console.log(" + $3 + ")" }
    ;

printStmt 
    : 'printf' '(' args ')'
        { $$ = "console.log(" + $3 + ")" }
    ;

lensStmt
    : 'strlen' '(' ID ')'
        { $$ = $3 + ".length" }
    ;

compoundStmt
    : '{' localDecls stmtList '}'
        { $$ = "{" + $2 + $3 + "}"; }
    ;

localDecls
    : localDecls varDecl
        { $$ = $1 + $2; }
    |
        { $$ = ""; }
    ;

stmtList
    : stmtList statement
        { $$ = $1 + $2; }
    |
        { $$ = ""; }
    ;

labeledStmt
    : 'case' expression ':' statement
        { $$ = "case " + $2 + ":" + $4; }
    | 'default' ':' statement
        { $$ = "default" + ":" + $3; }
    ;

expressionStmt
    : expression ';'
        { $$ = $1 + ";"; }
    | ';'
        { $$ = ";"; }
    ;

selectionStmt
    : 'if' '(' simpleExpression ')' compoundStmt 'else' compoundStmt
        { $$ = "if(" + $3 + ")" + $5 + "else" + $7; }
    | 'if' '(' simpleExpression ')' compoundStmt
        { $$ = "if(" + $3 + ")" + $5; }
    | 'switch' '(' expression ')' compoundStmt
        { $$ = "switch(" + $3 +")" + $5; }
    ;

iterationStmt
    : 'while' '(' simpleExpression ')' statement
        { $$ = "while(" + $3 + ")" + $5; }
    | 'for' '(' expression ';' expression ';' expression ')' statement
        { $$ = "for(" + $3 + ";" + $5 + ";" + $7 + ")" + $9; }
    ;

returnStmt
    : 'return' ';'
        { $$ = "return;"; }
    | 'return' expression ';'
        { $$ = "return " + $2 + ";"; }
    ;

breakStmt
    : 'break' ';'
        { $$ = "break;"; }
    ;

expression
    : mutable '=' expression
        { $$ = $1 + "=" + $3; }
    | mutable '+=' expression
        { $$ = $1 + "+=" + $3; }
    | mutable '-=' expression
        { $$ = $1 + "-=" + $3; }
    | mutable '*=' expression
        { $$ = $1 + "*=" + $3; }
    | mutable '/=' expression
        { $$ = $1 + "/=" + $3; }
    | mutable '++'
        { $$ = $1 + "++"; }
    | '++' mutable
        { $$ = "++" + $2; }
    | mutable '--'
        { $$ = $1 + "--"; }
    | simpleExpression
        { $$ = $1; }
    ;

simpleExpression
    : simpleExpression '||' andExpression
        { $$ = $1 + "||" + $3; }
    | andExpression
        { $$ = $1; }
    ;

andExpression
    : andExpression '&&' unaryRelExpression
        { $$ = $1 + "&&" + $3; }
    | unaryRelExpression
        { $$ = $1; }
    ;

unaryRelExpression
    : '!' unaryRelExpression
        { $$ = "!" + $2; }
    | relExpression
        { $$ = $1; }
    ;

relExpression
    : sumExpression relop sumExpression
        { $$ = $1 + $2 + $3; }
    | sumExpression
        { $$ = $1; }
    ;

relop
    : '<='
        { $$ = "<="; }
    | '<'
        { $$ = "<"; }
    | '>'
        { $$ = ">"; }
    | '>='
        { $$ = ">="; }
    | '=='
        { $$ = "=="; }
    | '!='
        { $$ = "!="; }
    ;

sumExpression
    : sumExpression sumop term
        { $$ = $1 + $2 + $3; }
    | term
        { $$ = $1; }
    ;

sumop
    : '+'
        { $$ = "+"; }
    | '-'
        { $$ = "-"; }
    ;

term
    : term mulop unaryExpression
        { $$ = $1 + $2 + $3; }
    | unaryExpression
        { $$ = $1; }
    ;

mulop
    : '*'
        { $$ = "*"; }
    | '/'
        { $$ = "/"; }
    | '%'
        { $$ = "%"; }
    ;

unaryExpression
    : unaryop unaryExpression
        { $$ = $1 + $2; }
    | factor
        { $$ = $1; }
    ;

unaryop
    : '-'
        { $$ = "-"; }
    | '*'
        { $$ = "*"; }
    | '?'
        { $$ = "?"; }
    ;

factor
    : immutable
        { $$ = $1; }
    | mutable
        { $$ = $1; }
    ;

mutable
    : ID
        { $$ = $1; }
    | ID '[' expression ']'
        { $$ = $1 + "[" + $3 + "]"; }
    ;

immutable
    : '(' expression ')'
        { $$ = "(" + $2 + ")"; }
    | call
        { $$ = $1; }
    | constant
        { $$ = $1; }
    ;

call
    : ID '(' args ')'
        { $$ = $1 + "(" + $3 + ")"; }
    | lensStmt
        { $$ = $1; }
    | putsStmt
        { $$ = $1; }
    | printStmt 
        { $$ = $1; }
    | getsStmt
        { $$ = $1; }
    ;

args
    : argList
        { $$ = $1; }
    |
        { $$ = ""; }
    ;

argList
    : argList ',' expression
        { $$ = $1 + "," + $3; }
    | expression
        { $$ = $1; }
    ;

constant
    : NUMCONST
        { $$ = $1; }
    | CHARCONST
        { $$ = $1; }
    | STRINGCONST
        { $$ = $1; }
    | 'true'
        { $$ = "true"; }
    | 'false'
        { $$ = "false"; }
    ;
