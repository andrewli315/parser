/*
	Topic: Homework2 for Compiler Course
	Deadline: xxx.xx.xxxx
*/

%{

/*	Definition section */
/*	insert the C library and variables you need */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

/*Extern variables that communicate with lex*/

extern int yylineno;


typedef struct SYMBOL{
    char *id;
    char *type;
    int index;
    union DATA{
        int ival;
        double fval;
    }data;
}symbol;

typedef struct TNODE{
    symbol* data;
    struct TNODE* left;
    struct TNODE* right;
}Tnode;
/*	Symbol table function

	TAs create the basic function which you have to fill.
	We encourage you define new function to make the program work better.
	However, the five basic functions must be finished.
*/
extern int yylex();

void yyerror(char *);
void create_symbol();								/*establish the symbol table structure*/
void insert_symbol(char* id, char* type, int data);	/*Insert an undeclared ID in symbol table*/
void symbol_assign(char* id, double data);				/*Assign value to a declared ID in symbol table*/
symbol* lookup_symbol(char* id);						/*Confirm the ID exists in the symbol table*/
void dump_symbol();									/*List the ids and values of all data*/
symbol* new_symbol (char* id,char* type);
Tnode* new_node(symbol* n);
void insert_node(Tnode*,symbol*);
int weight(char* str1,char* str2);
int lookup_index(char* id);

int symnum;											/*The number of the symbol*/

Tnode* root;
symbol *buffer[100];
int node_index = 0;
char id[100];
char type[10];
union NUM{
    int inum;
    double fnum;
}num;
/* Note that you should define the data structure of the symbol table yourself by any form */

%}

/* Token definition */
%token SEM PRINT WHILE INT DOUBLE LB RB
%token STRING ADD SUB MUL DIV
%token ASSIGN NUMBER FLOATNUM ID 

/* Type definition : 

	Define the type by %union{} to specify the type of token

*/
%union{
    int intval;
    double floatval;
    char str[100];
    char token[100];
    char type[20];
};

/* Type declaration : 
	
	Use %type to specify the type of token within < > 
	if the token or name of grammar rule will return value($$) 
*/
%type <floatval> Arith Term Factor Group NUMBER FLOATNUM
%type <str>  STRING
%type <token> ID
%type <type> Type INT DOUBLE
%%

/* Define your parser grammar rule and the rule action */

lines
    : 
    | lines Stmt
    ;

// define statement type Declaration, Assign, Print, Arithmetic and Branch

/* Read in sequence */
Stmt
    : Decl SEM                          {printf("Decl\n" );memset(&yylval,0,sizeof(yylval));num.fnum =0.0;}
    | Print SEM                         {memset(&yylval,0,sizeof(yylval));num.fnum =0.0;}/* Print */
    | Assign SEM                        {printf("Assign\n");memset(&yylval,0,sizeof(yylval));num.fnum =0.0;}/* Assignment (e.g. a = 5; ) */
    | Arith SEM                         {memset(&yylval,0,sizeof(yylval));num.fnum =0.0; }/* Arithmetic */
    ;
Decl
    : Type ID                           {insert_symbol(id,type,0); memset(yylval.token,'\0',strlen(yylval.token)) ;}
    | Type ID ASSIGN Arith              {insert_symbol(id,type,0);symbol_assign(id,$4);}
    ;
Type
    :INT                                {strcpy(type,"int");}
    |DOUBLE                             {strcpy(type,"double");}
    ;
Assign
    :ID ASSIGN Arith                    {symbol_assign(id,$3);}
    ;
Arith
    : Term                              { $$ = $1;}
    | Arith ADD Term                    { $$ = $1+$3; printf("ADD\n");}/*print operator when you meet */
    | Arith SUB Term                    { $$ = $1-$3; printf("SUB\n");}/*print operator when you meet */
    ;
Term
    :Factor                             { symbol* temp = lookup_symbol(id); $$ = temp->data.fval;}
    |Term MUL Factor                    { $$ = $1*$3;printf("MUL\n");}/*print operator when you meet */
    |Term DIV Factor                    { $$ = $1/$3;printf("DIV\n");}
    ;
Factor
    : Group
    | NUMBER                            { $$ = $1;}
    | FLOATNUM                          { $$ = $1;}
    | ID                                { strcpy(id,yylval.token);}
    ;
Print    
    : PRINT Group                       {printf("Print : %d\n",(int)$2);}
    | PRINT LB STRING RB                {printf("Print : %s\n",$3);}
    ;
Group
    :LB Arith RB                        {$$ = $2;}
    ;
%%

int main(int argc, char** argv)
{
    yylineno = 0;
    symnum = 0;
    create_symbol();   
    yyparse();

	printf("\n\nTotal Lines : %d \n\n",yylineno+1);
	dump_symbol();
    return 0;
}

void yyerror(char *s) {
    printf("<ERROR> %s ------ on %d line \n", s , yylineno+1);
}


/*symbol create function*/
void create_symbol() {
    printf("Create symbol table\n\n");
    root = new_node(new_symbol("",""));
}

/*symbol insert function*/
void insert_symbol(char* id, char* type, int data) {
	printf("Insert symbol : %s\n",id);
    if(lookup_symbol(id) != NULL)
    {
        yyerror(strcat("re-declaration for variable ",id));
        return;
    }
    symbol *temp = new_symbol(id,type);
    insert_node(root,temp);
}


/*symbol value lookup and check exist function*/
symbol* lookup_symbol(char* id){
	Tnode* node = root->right;
    while(node != NULL)
    {
        if(strcmp(id,node->data->id) == 0)
        {
            return node->data;
        }
        else
        {
            if(weight(id,node->data->id) == 0)
                node = node->left;
            else
                node = node->right;
        }
    }
    return NULL;
}

/*symbol value assign function*/
void symbol_assign(char* id, double data) {
    
    symbol *node = lookup_symbol(id);
    int index = lookup_index(id);
    if(node != NULL && index != -1)
    {
        node->data.fval = data;
        buffer[index]->data.fval = data;
    }
    return;
}   

/*symbol dump function*/
void dump_symbol(){
	int i;
    printf("The symbol table : \n\n");
    printf("ID \t Type \t Data\n");
    for(i=1;i<node_index;i++)
    {
        if(strcmp(buffer[i]->type,"int")==0)
            printf("%s \t %s \t %d\n",buffer[i]->id,buffer[i]->type,(int)buffer[i]->data.fval);
        else
            printf("%s \t %s \t %lf\n",buffer[i]->id,buffer[i]->type,buffer[i]->data.fval);
    }
}
symbol* new_symbol(char* id,char* type)
{
    symbol* new = (symbol*)malloc(sizeof(symbol));
    new->id = (char*)malloc(strlen(id)*sizeof(char));
    strcpy(new->id,id);
    new->type = (char*)malloc(strlen(type)*sizeof(char));
    strcpy(new->type,type);
    new->index = node_index;
    node_index++;
    return new;

}
Tnode* new_node(symbol* n)
{
    Tnode* new;
    new = (Tnode*)malloc(sizeof(Tnode));
    new->data = (symbol*)malloc(sizeof(symbol));
    new->data->id = (char*)malloc(strlen(n->id)*sizeof(char));
    strcpy(new->data->id,n->id);
    new->data->type = (char*)malloc(strlen(n->type)*sizeof(char));
    strcpy(new->data->type,n->type);
    new->data->index = n->index;
    new->left = NULL;
    new->right = NULL;
    
    buffer[n->index] = n;
    return new;
}
void insert_node(Tnode* t,symbol* n)
{
    
    if( weight(n->id ,t->data->id) == 1)
    {
        if( t->right == NULL)
        {
            t->right = new_node(n);
            return;
        }
        insert_node(t->right,n);
    }

    else if( weight(n->id ,t->data->id) == 0)
    {
        if( t->left == NULL)
        {
            t->left = new_node(n);
            return;
        }
        insert_node(t->left,n);
    }
}

int weight(char* str1,char* str2)
{
    int i;
    int length = strlen(str1)<strlen(str2)?strlen(str1):strlen(str2);
    for(i = 0 ; i<length;i++)
    {
        if(str1[i]<str2[i])
            return 0;
        else if(str1[i] == str2[i])
            continue;
        else
            return 1;
    }
    return strlen(str1)<strlen(str2)?0:1;
}
int lookup_index(char* id){
    Tnode* node = root->right;
    while(node != NULL)
    {
        if(strcmp(id,node->data->id) == 0)
        {
            return node->data->index;
        }
        else
        {
            if(weight(id,node->data->id) == 0)
                node = node->left;
            else
                node = node->right;
        }
    }
    return -1;
}