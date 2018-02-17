%option noyywrap
/** Code to Beautify **/
%{
      #include<stdio.h>
      #include<stdlib.h>
      #include<assert.h>
      #include<string.h>
      #define INDENT (4)
      #define MAXSYMBOLS 200
      int line = 1;
      int column = 4;
      int paren = 0;

      void write_string();
      void write_char();
      void write_oct();
      void write_hex();
      void write_int();
      void write_fp();
      void write_id();
      void write_begin();
      void write_end();
      void write_open();
      void write_close();
      void write_bopen();
      void write_bclose();
      void write_sep();
      void write_op();
      void write_inline();
      void write_comment();
      void write_directive();
      void error();

      void indent();
      void write_html();
      void write_html_char(char);

      int lookup(char*);
      int insert(char*,int);
      void init();

      int insertIndex = 0;

%}
quote '
ditto \"
back \\
digit [0-9]
exp [eE]([+-]?)({digit}+)
hex [0-9a-fA-F]
alpha [a-zA-Z]
ch [^\\'\"\n]
%%
{ditto}({back}{ch}|{back}{back}|{back}{quote}|{back}{ditto}|{ch}|{ditto})+{ditto} {write_string();}
{quote}({back}{ch}|{back}{back}|{back}{quote}|{back}{ditto}|{ch}|{ditto}){quote} {write_char();}
0([0-7]+) {write_oct();}
0[xX]({hex})+ {write_hex();}
{digit}+ {write_int();}
{digit}+"."({digit}*)({exp}?) {write_fp();}
{alpha}({alpha}|{digit})*(" "|"\n")? {write_id();}
"{" {write_begin();}
"}" {write_end();}
"(" {write_open();}
")" {write_close();}
"[" {write_bopen();}
"]" {write_bclose();}
";" {write_sep();}
(\.|\-\>|\+\+|\-\-|\%|\<\<|\>\>|\>\>=|&=|\^=|\|=|,|\<=|\>=|!=|\^\||&&|\|\|\?|\*=|\/=|\<|\>|=|==|"||"|"|"|\%=|\+=|\-=|\<\<=|&|\*|\+|\-|~|!|\/|#|##|;|:|\"|\.\.\.) {write_op();}
"\/\/"[^\n]* {write_inline();}
"/*" {write_comment();}
#[^\n]* {write_directive();}
[ \t\v\n\r\f] ;
{ch} {error();}
%%

/** Symbol Table Definition **/
struct entry
{
  char *lexptr;
  int token;
};
struct entry symtable[MAXSYMBOLS];

void write_string() {
  printf("<font color='#DD2C00'>");
  write_html(0);
  printf("</font>");
}
void write_char() {
  printf("<font color='#26C6DA'><u>");
  write_html(0);
  printf("</u></font>");
}
void write_oct() {
  printf("<font color='#26C6DA'><i>");
  write_html(0);
  printf("</i></font>");
}
void write_hex() {
  printf("<font color='#26C6DA'><i>");
  write_html(0);
  printf("</i></font>");
}
void write_int() {
  printf("<font color='#26C6DA'><i>");
  write_html(0);
  printf("</i></font>");
}
void write_fp() {
  printf("<font color='#26C6DA'>");
  write_html(0);
  printf("</font>");
}

void write_id() {

  char *text = yytext;
  int length = strlen(text);
  int spaceOrNewLine = 0;

  if(text[length-1] == ' ' || text[length-1] == '\n') {
    spaceOrNewLine = 1;
    text[length-1] = '\0';
  }

  int symIndex = lookup(text);

  // Symbol Not found
  if(symIndex == -1) {
    insert(text,1);
    if(spaceOrNewLine)
      printf("<font color='#0000FF'><a name=\"%s\">%s</a> ",text,text);
    else
      printf("<font color='#0000FF'><a name=\"%s\">%s</a>",text,text);
    printf("</font>");
  } else if(symtable[symIndex].token == 0){
    printf("<font color='#0000FF'><strong>");
    write_html(spaceOrNewLine);
    printf("</strong></font>");
  } else if(symtable[symIndex].token == 1) {
      if(spaceOrNewLine)
        printf("<font color='#0000FF'><a href=\"#%s\">%s</a> ",text,text);
      else
        printf("<font color='#0000FF'><a href=\"#%s\">%s</a>",text,text);
      printf("</font>");
  }
}
void write_begin() {
  indent();
  write_html(0);
  column+= INDENT;
  indent();
}
void write_end() {
  column -= INDENT;
  indent();
  write_html(0);
  indent();
}
void write_open() {
  write_html(0);
  putchar(' ');
  paren++;
}
void write_close() {
  write_html(0);
  putchar(' ');
  paren--;
}
void write_bopen() {
  printf("<font color='#000000'><strong>");
  write_html(0);
  printf("</strong></font>");
}
void write_bclose() {
  printf("<font color='#000000'><strong>");
  write_html(1);
  printf("</strong></font>");
}
void write_sep() {
  write_html(0);
  if(!paren)
    indent();
  else
    putchar(' ');
}
void write_op(){
  printf("<font color='#000000'><strong>");
  write_html(1);
  printf("</strong></font>");
}
void write_directive(){
  printf("<font color='#E91E63'><strong>");
  write_html(0);
  printf("</strong></font>");
  indent();
}
void write_inline(){
  printf("<font color='#66BB6A'>");
  write_html(0);
  printf("</font>");
  indent();
}
void write_comment(){
  char c,c1;
  printf("<font color='#66BB6A'>/*");

  loop:
    while ((c = input()) != '*' && c != 0)
    write_html_char(c);
    write_html_char('*');
    if ((c1 = input()) != '/' && c != 0) {
        unput(c1);
        goto loop;
    }
    if (c != 0)
	     write_html_char(c1);
    printf("</font>");
    indent();
}

void write_html_char(char c) {
  switch(c) {
    case '<': printf("&lt;");break;
    case '>': printf("&gt;");break;
    case '"': printf("&quot;");break;
    case '&': printf("&amp;");break;
    default: putchar(c);
  }
}

void write_html(int flag){
  char *s = yytext;
  while(*s)
    write_html_char(*s++);
  if(flag)
      write_html_char(' ');
}

void error(){
  printf("err ");
}

void indent() {
  printf("\n%-*d",column,line++);
}

int lookup(char* lexeme) {
  for(int i = 0; i < insertIndex; i++){
    if(strcmp(symtable[i].lexptr,lexeme) == 0)
      return i;
  }

  // Error
  return -1;
}

int insert(char* a, int token) {
  // Add tokens according to insertIndex
  symtable[insertIndex].lexptr = (char *)malloc(10);
  strcpy(symtable[insertIndex].lexptr,a);
  symtable[insertIndex].token = token;
  insertIndex++;
  return insertIndex - 1;
}

void init() {
  char keywordList[32][10] = {
    "auto",
    "const",
    "double",
    "float",
    "int",
    "short",
    "struct",
    "unsigned",
    "break",
    "continue",
    "else",
    "for",
    "long",
    "signed",
    "switch",
    "void",
    "case",
    "default",
    "enum",
    "goto",
    "register",
    "sizeof",
    "typedef",
    "volatile",
    "char",
    "do",
    "extern",
    "if",
    "return",
    "static",
    "union",
    "while"
  };

  for(int i = 0 ; i < 32; i++ ){
    insert(keywordList[i],0);
  }
}

int main(){
  init();
  FILE *fp;
  fp = freopen("output.html","w",stdout);
  printf("<html><pre>\n");
  indent();
  yyin = fopen("input.c","r");
  yylex();
  printf("</pre></html>\n");
  fclose(yyin);
  fclose(fp);
  return 0;
}
