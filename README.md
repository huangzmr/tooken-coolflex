
我需要写的是 词法分析器规范cool.flex
下面是大体框架
%{
 /* 第一部分：定义段 - C 代码块 */
 #include <stdio.h>
 int line_number = 1;
 %}
 /* 第一部分：定义段 - Flex 定义 */
 %option noyywrap
 %x COMMENT
 DIGIT    [0-9]
 %%
 /* 第二部分：规则段 - 词法规则 */
 "class"     { return CLASS; }
 [0-9]+      { yylval.symbol = stringtable.add_string(yytext); return INT_CONST; }
 %%
 /* 第三部分：用户代码段 - 辅助函数 */

写完在终端根据make写
make clean
make lexer
./lexer test.cl
make dotest
检验有没有错

如果系统崩溃
gdb ./lexer
(gdb) run test.cl
会自动帮你找到卡在哪一行
如果运行成功就会解释test.cl里面的内容
