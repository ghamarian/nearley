main -> name (__ name):* {% d => { 
	let result = d[1].map(e => e[1])
	return `${d[0]}-${result}` 
} %}
#main ->  simple_stmt 

simple_stmt -> expr_stmt _ (";" _ expr_stmt):* _ ";":? {% d => { console.log('last step'); console.dir(d[0]); return d[0]} %}
expr_stmt -> testlist_star_expr _ (annassign | augassign testlist | ("=" _ testlist_star_expr):*) {% id %}
annassign -> ":"  _ test _ ("=" _ test):? {% id %}
testlist_star_expr -> (test|star_expr) _ ("," _ (test|star_expr)):* _ ",":? {% id %}
augassign -> ("+=" | "-=" | "*=" | "@=" | "/=" | "%=" | "&=" | "|=" | "^=" |
            "<<=" | ">>=" | "**=" | "//=") {% id %}

test -> or_test _ ("if" _  or_test _ "else" _ test):? {% d => {console.log(`inja ${d[0].length} ${d[0]}`); return d;} %}
test_nocond -> or_test {% id %}
or_test -> and_test _ ("or" _ and_test):* {% d => `${d[0]} ${d[2]}` %}
and_test -> not_test _ ("and" _ not_test):* {% d => `${d[0]} ${d[2]}` %}
not_test -> "not" _ not_test {% d => `not ${d[2]}`%} | 
            comparison {% id %}
comparison -> expr _ (comp_op expr):* {% d => d[0] %}
comp_op -> ("<" |
           ">" |
           "=="|
           ">="|
           "<="|
           "<>"|
           "!="|
           "in"|
           "not" "in"|
           "is"|
           "is" "not") {% id %}
star_expr -> "*" _ expr {% d => `* ${d[2]}` %}
expr -> xor_expr _ ("|" xor_expr):* {% id %}
xor_expr -> and_expr _ ("^" and_expr):* {% id %}
and_expr -> shift_expr _ ("&" shift_expr):* {% id %}
shift_expr -> arith_expr _ (("<<"|">>") _ arith_expr):* {% id %}
arith_expr -> term _ (("+"|"-") _ term):* {% id %}
term -> factor _ (("*"|"@"|"/"|"%"|"//") _ factor):* {% id %}
factor -> ("+"|"-"|"~") _ factor | power {% id %}
power -> atom_expr _ ("**" factor):? {% id %}
atom_expr -> ("await"):? _ atom _ trailer:* {% d => {console.log(`amir`); JSON.stringify(d); return d} %}
atom -> ( "[" _ testlist_comp:? _ "]" |
       name | number | string:+ | "..." | "None" | "True" | "False") {% id %}

testlist_comp -> (test|star_expr) _ ( comp_for | ("," _ (test|star_expr)):* _ ",":? ) {% id %}
trailer -> "(" _ arglist:? _ ")" | "[" _ subscriptlist _ "]" | "." _ name {% id %}
subscriptlist -> subscript _ ("," _ subscript):* _ ",":? {% id %}
subscript -> test {% id %}
       | test:? _ ":" _ test:? _ sliceop:? {% d => `${d[0]} : ${d[4]} ${d[6]}` %}
sliceop -> ":" _ test:? {% d => `: ${d[2]}` %}
exprlist -> (expr|star_expr) _ ("," _ (expr|star_expr)):* _ ",":? {% id %}
testlist -> test _ ("," test):* _ ",":? {% id %}
arglist -> argument _ ("," argument):* _ ",":? {% id %}

argument -> ( test _ comp_for:? {% d => {console.log('test'); return d;} %} 
           | test _ "="  _ test {% d => `${d[0]} = ${d[4]}`%} 
           | "**" _ test  {% d => `^ ${d[2]}`%}
           | "*" _ test {% d => `* ${d[2]}`%}) 

comp_iter -> comp_for {% id %} | 
             comp_if {% id %}
#sync_comp_for -> "for" _ exprlist _ "in" _ or_test _ comp_iter:? {% d => `for ${d[2]} in ${d[6]}` %}
sync_comp_for -> "for" _ exprlist _ "in" _ or_test _ comp_iter:? {% d => flatten(d) %}
comp_for -> "async":? _ sync_comp_for {% d => `${d[2]}` %}
comp_if -> "if" _ test_nocond _ comp_iter:? {% d => `if (${d[2]}) ${d[4]}` %}

number -> "-":? [0-9]:+ ("." [0-9]:+):? {% d => d[0]+d[1].join("") %}
name -> ([a-zA-Z_]):+ {% d =>  d[0].join("")  %}
dqstring -> "\"" dstrchar:* "\"" {% d => d[1].join("") %}
dstrchar -> [^\\"\n] {% id %}
string -> dqstring {% d => d.join("") %}

# Whitespace: `_` is optional, `__` is mandatory.
_  -> wschar:* {% function(d) {return null;} %}
__ -> wschar:+ {% function(d) {return null;} %} 

wschar -> [ \t\n\v\f] {% id %}

@{%
   function flatten(d) {
	return d.concat.apply([], a);	
   }
%}
