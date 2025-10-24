%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>
#define yylval cool_yylval
#define yylex  cool_yylex
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT
extern FILE *fin;
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
  if ((result = fread((char*)buf, sizeof(char), max_size, fin)) < 0) \
    YY_FATAL_ERROR("read() in flex scanner failed");
char string_buf[MAX_STR_CONST];
char *string_buf_ptr;
extern int curr_lineno;
extern YYSTYPE cool_yylval;
static int comment_level;
#define CHECK_STRING_OVERFLOW() \
  if (string_buf_ptr - string_buf >= MAX_STR_CONST - 1) { \
    cool_yylval.error_msg = "String constant too long"; \
    BEGIN(INITIAL); \
    return ERROR; \
  }
%}

%x COMMENT
%x STRING

DARROW       =>
ASSIGN       <-
LE           <=
DIGIT        [0-9]
LOWER        [a-z]
UPPER        [A-Z]
LETTER       [a-zA-Z]
ALNUM        [a-zA-Z0-9]

%%

[cC][lL][aA][sS][sS]                  { return CLASS; }
[eE][lL][sS][eE]                      { return ELSE; }
[fF][iI]                              { return FI; }
[iI][fF]                              { return IF; }
[iI][nN]                              { return IN; }
[iI][nN][hH][eE][rR][iI][tT][sS]      { return INHERITS; }
[iI][sS][vV][oO][iI][dD]              { return ISVOID; }
[lL][eE][tT]                           { return LET; }
[lL][oO][oO][pP]                       { return LOOP; }
[pP][oO][oO][lL]                       { return POOL; }
[tT][hH][eE][nN]                       { return THEN; }
[wW][hH][iI][lL][eE]                   { return WHILE; }
[cC][aA][sS][eE]                       { return CASE; }
[eE][sS][aA][cC]                       { return ESAC; }
[nN][eE][wW]                           { return NEW; }
[oO][fF]                               { return OF; }
[nN][oO][tT]                           { return NOT; }

t[rR][uU][eE]        { cool_yylval.boolean = 1; return BOOL_CONST; }
f[aA][lL][sS][eE]    { cool_yylval.boolean = 0; return BOOL_CONST; }

{UPPER}({LETTER}|{DIGIT}|_)* {
  cool_yylval.symbol = stringtable.add_string(yytext);
  return TYPEID;
}
{LOWER}({LETTER}|{DIGIT}|_)* {
  cool_yylval.symbol = stringtable.add_string(yytext);
  return OBJECTID;
}

{DIGIT}+ {
  cool_yylval.symbol = stringtable.add_string(yytext);
  return INT_CONST;
}

{DARROW}    { return DARROW; }
{ASSIGN}    { return ASSIGN; }
{LE}        { return LE; }

"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
"~"         { return '~'; }
"<"         { return '<'; }
"="         { return '='; }
"."         { return '.'; }
"@"         { return '@'; }
","         { return ','; }
":"         { return ':'; }
";"         { return ';'; }
"("         { return '('; }
")"         { return ')'; }
"{"         { return '{'; }
"}"         { return '}'; }

\" {
  BEGIN(STRING);
  string_buf_ptr = string_buf;
}

<STRING>\" {
  BEGIN(INITIAL);
  *string_buf_ptr = '\0';
  cool_yylval.symbol = stringtable.add_string(string_buf);
  return STR_CONST;
}

<STRING>\n {
  curr_lineno++;
  BEGIN(INITIAL);
  cool_yylval.error_msg = "Unterminated string constant";
  return ERROR;
}

<STRING><<EOF>> {
  BEGIN(INITIAL);
  cool_yylval.error_msg = "EOF in string constant";
  return ERROR;
}

<STRING>\0 {
  cool_yylval.error_msg = "String contains null character.";
  BEGIN(INITIAL);
  return ERROR;
}

<STRING>\\n { CHECK_STRING_OVERFLOW(); *string_buf_ptr++ = '\n'; }
<STRING>\\t { CHECK_STRING_OVERFLOW(); *string_buf_ptr++ = '\t'; }
<STRING>\\b { CHECK_STRING_OVERFLOW(); *string_buf_ptr++ = '\b'; }
<STRING>\\f { CHECK_STRING_OVERFLOW(); *string_buf_ptr++ = '\f'; }
<STRING>\\. { CHECK_STRING_OVERFLOW(); *string_buf_ptr++ = yytext[1]; }
<STRING>.  {
  if (yytext[0] == '\0') {
    BEGIN(INITIAL);
    cool_yylval.error_msg = "String contains null character.";
    return ERROR;
  }
  CHECK_STRING_OVERFLOW();
  *string_buf_ptr++ = yytext[0];
}

"--".*                          { }

"(*"                            { BEGIN(COMMENT); comment_level = 1; }
<COMMENT>"(*"                   { comment_level++; }
<COMMENT>"*)"                   { if (--comment_level == 0) BEGIN(INITIAL); }
<COMMENT><<EOF>>                { cool_yylval.error_msg = "EOF in comment"; BEGIN(INITIAL); return ERROR; }
<COMMENT>\n                     { curr_lineno++; }
<COMMENT>.                      { }

"*)"                            { cool_yylval.error_msg = "Unmatched *)"; return ERROR; }

[ \f\r\t\v]+                    { }
\n                              { curr_lineno++; }

.                               { cool_yylval.error_msg = yytext; return ERROR; }

%%
\end{lstlisting}

\end{document}
