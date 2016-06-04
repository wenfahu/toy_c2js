%lex
%%

\s+                         /* skip whitespace */
\r+                         /* skip linebreak */
\n+                         /* skip linebreak */
[0-9]+("."[0-9]+)?\b        return 'NUMCONST'
"true"                      return 'true'
"false"                     return 'false'
"if"                        return 'if'
"else"                      return 'else'
"while"                     return 'while'
"for"                       return 'for'
"break"                     return 'break'
"return"                    return 'return'
"int"                       return 'int'
"char*"                     return 'char*'
"char"                      return 'char'
"bool"                      return 'bool'
"gets"                      return 'gets'
"puts"                      return 'puts'
"strlen"                    return 'strlen'
"main"                      return 'main'
[a-zA-Z]?\"(\\.|[^\\"])*\"  return 'STRINGCONST'
[a-zA-Z]+"."h               return 'INCLUDESTRING'
[a-zA-Z]+                   return 'ID'
[a-zA-Z]                    return 'CHARCONST'
\"                          return '"'
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
"|"                         return '|'
"?"                         return '?'
"#include <"                return '#include<'
">"                         return '>'
<<EOF>>                     return 'EOF'
.                           return 'INVALID'

/lex

%start p
%%

p
    : program EOF
        { var fs = require('fs');
          fs.writeFile('out.js', $1 );
		  var beautify = require('js-beautify').js_beautify;
		  fs.readFile('out.js', 'utf8', function(err, data){
		  	if(err) throw err;
			fs.writeFile('out.js', beautify(data));
		  });
          typeof console !== 'undefined' ? console.log($1) : print($1);
          return $1; }
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
    : '#include<' INCLUDESTRING '>'
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
        { $$ = $1 + ", " + $2; }
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
    ;

getsStmt
    : 'gets' '(' ID ')'
        { $$ = "jsGets(" + $3 + ")" }
    ;

putsStmt
    : 'puts' '(' STRINGCONST ')'
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

expressionStmt
    : expression ';'
        { $$ = $1 + ";"; }
    | ';'
        { $$ = ";"; }
    ;

selectionStmt
    : 'if' '(' simpleExpression ')' statement 'else' statement
        { $$ = "if(" + $3 + ")" + $5 + "else" + $7; }
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
    | mutable '--'
        { $$ = $1 + "--"; }
    | simpleExpression
        { $$ = $1; }
    ;

simpleExpression
    : simpleExpression '|' andExpression
        { $$ = $1 + "|" + $3; }
    | andExpression
        { $$ = $1; }
    ;

andExpression
    : andExpression '&' unaryRelExpression
        { $$ = $1 + "&" + $3; }
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
