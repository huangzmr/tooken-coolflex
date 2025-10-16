%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */

#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */

#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */


#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* 缓冲区 */
char *string_buf_ptr; /* 缓冲区指针 */

extern char *yytext;        // 当前匹配的文本
extern int yyleng;          // 匹配文本的长度
extern FILE *yyin;          // 输入文件指针

extern int curr_lineno; /* 当前行号 */
extern int verbose_flag;

static int comment_level=0; /* 注释嵌套层数 */

extern YYSTYPE cool_yylval; 


%}


%option noyywrap

%x STRING 
%x COMMENT 

DIGIT      [0-9]
LOWER      [a-z]
UPPER      [A-Z]
LETTER     [a-zA-Z]
ALNUM      [a-zA-Z0-9]

DARROW          =>
ASSIGN          <-
LE              <=

%%

[cC][lL][aA][sS][sS]                { return CLASS; }
[eE][lL][sS][eE]                   { return ELSE; }
[fF][iI]                           { return FI; }
[iI][fF]                           { return IF; }
[iI][nN]                           { return IN; }
[iI][nN][hH][eE][rR][iI][tT][sS]   { return INHERITS; }
[iI][sS][vV][oO][iI][dD]           { return ISVOID; }
[lL][eE][tT]                       { return LET; }
[lL][oO][oO][pP]                   { return LOOP; }
[pP][oO][oO][lL]                   { return POOL; }
[tT][hH][eE][nN]                   { return THEN; }
[wW][hH][iI][lL][eE]               { return WHILE; }
[cC][aA][sS][eE]                   { return CASE; }
[eE][sS][aA][cC]                   { return ESAC; }
[nN][eE][wW]                       { return NEW; }
[oO][fF]                           { return OF; }
[nN][oO][tT]                       { return NOT; }


{DARROW}		{ return (DARROW); }
{ASSIGN}    { return ASSIGN; }
{LE}        { return LE; }
"+"     { return '+'; }
"-"     { return '-'; }
"*"     { return '*'; }
"/"     { return '/'; }
"~"     { return '~'; }
"<"     { return '<'; }
"="     { return '='; }
"."     { return '.'; }
"@"     { return '@'; }
","     { return ','; }
":"     { return ':'; }
";"     { return ';'; }
"("     { return '('; }
")"     { return ')'; }
"{"     { return '{'; }
"}"     { return '}'; }


t[rR][uU][eE]       { cool_yylval.boolean = 1; return BOOL_CONST; }
f[aA][lL][sS][eE]   { cool_yylval.boolean = 0; return BOOL_CONST; }


{UPPER}({ALNUM}|_)*  { cool_yylval.symbol = stringtable.add_string(yytext); return TYPEID; }

{LOWER}({ALNUM}|_)*  { cool_yylval.symbol = stringtable.add_string(yytext); return OBJECTID; }

{DIGIT}+             { cool_yylval.symbol = stringtable.add_string(yytext); return INT_CONST; }

\"                { BEGIN(STRING); string_buf_ptr = string_buf; } 
"(*"              { BEGIN(COMMENT); comment_level = 1; }

[ \f\r\t\v]+      { /* skip whitespace */ } 
\n                { curr_lineno++; }


<STRING>\"        {
                      BEGIN(INITIAL);
                      *string_buf_ptr = '\0';
                      if (string_buf_ptr - string_buf >= MAX_STR_CONST - 1) {
                         cool_yylval.error_msg = "String constant too long";
                         return ERROR;
                      }
                      cool_yylval.symbol = stringtable.add_string(string_buf);
                      return STR_CONST;
                  }
<STRING>\\n        { *string_buf_ptr++ = '\n'; }
<STRING>\\t        { *string_buf_ptr++ = '\t'; }
<STRING>\\b        { *string_buf_ptr++ = '\b'; }
<STRING>\\f        { *string_buf_ptr++ = '\f'; }
<STRING>\\.        { *string_buf_ptr++ = yytext[1]; } 
<STRING>\n         { curr_lineno++; BEGIN(INITIAL); cool_yylval.error_msg = "Unterminated string constant"; return ERROR; }
<STRING><<EOF>>    { BEGIN(INITIAL); cool_yylval.error_msg = "EOF in string constant"; return ERROR; }
<STRING>.          {
                      if (yytext[0] == '\0') {
                          cool_yylval.error_msg = "String contains null character.";
                          BEGIN(INITIAL); return ERROR;
                      }
                      if (string_buf_ptr - string_buf >= MAX_STR_CONST - 1) {
                          cool_yylval.error_msg = "String constant too long";
                          BEGIN(INITIAL); return ERROR;
                      }
                      *string_buf_ptr++ = yytext[0];
                  }



<COMMENT>"(*"      { comment_level++; }
<COMMENT>"*)"      { comment_level--; if (comment_level == 0) BEGIN(INITIAL); }
<COMMENT>\n        { curr_lineno++; /* 注释中允许换行 */ }
<COMMENT><<EOF>>   { BEGIN(INITIAL); cool_yylval.error_msg = "EOF in comment"; return ERROR; }
<COMMENT>.         { /* ignore comment content */ }

%%

