grammar Depend;

options {
	backtrack=true;
	output=AST;
	language=Python;
}
tokens {
	ALL_OF;
	ANY_OF;
	CATEGORY;
	NEGATIVE;
	PKG_DEP;
	PN;
	POSITIVE;
	SLOT;
	USE_CONDITIONAL;
	USE_FLAG;
}
@header {
import re

}

@init {
default = True;
self.features = {'STRONG_BLOCK':default,'SLOT_DEPENDS':default,'USE_DEPENDS':default}
self.pn_end = re.compile('.*-\d+')
self.needs_version = False
self.accept_asterisk = False
}


depend: WS? expr? WS? -> expr?;

expr	:	expr_type (WS expr_type)* -> expr_type+;

expr_type:
	any_of | use_conditional | all_of | pkg_dep;

all_of
	: '(' WS expr WS ')' -> ^(ALL_OF expr);
any_of
	:	'||' WS '(' WS (expr WS)* ')' -> ^(ANY_OF expr+);

use_conditional
	:	use_conditional_start '?' WS '(' WS (expr WS)* ')' -> ^(USE_CONDITIONAL use_conditional_start expr+);

use_conditional_start:
	NOT use_flag -> ^(use_flag NEGATIVE)
	| use_flag -> ^(use_flag POSITIVE);

pkg_dep
	:	block_oper? (versioned_dep | qpn) slot_dep? use_dep? -> ^(PKG_DEP );

versioned_dep
@init {
	self.needs_version = true;
}
@after {
	self.needs_version = false;
	self.accept_asterisk = false;
}
:	OPERATOR qpn version_spec
	| EQUALS {self.accept_asterisk=True} qpn version_spec;

block_oper	:	'!' ({self.features['STRONG_BLOCK']}?=> '!'?);

version_spec
	:	EAPI0_VERSION_SPEC  asterisk?;

asterisk:
	{self.accept_asterisk}?=> '*'
	| {not self.accept_asterisk}?=>;

use_dep	:
	{self.features['USE_DEPENDS']}?=> '[' use_dep_atom (',' use_dep_atom)* ']'
	| {not self.features['USE_DEPENDS']}?=> ;

use_dep_atom
	:	('!'|HYPHEN)? use_flag (EQUALS|'?')?;

slot_dep:
	{self.features['SLOT_DEPENDS']}?=> ':' slot_name
	| {not self.features['SLOT_DEPENDS']}?=>;


qpn	:	 category '/' pn -> category PN[$pn.text];

pn	:	pn_start
	|	pn_start pn_end;

pn_end
	:	(options { greedy=false;} : pn_part)* (pn_part pn_follows)=> pn_part {not pn_end.match($pn_end.text)}?;

pn_start : INTEGER|ALPHA|'+'|'_';
pn_part:  INTEGER|ALPHA|'+'|'_'|HYPHEN;

pn_follows
:
	 {self.needs_version}?=> version_spec (WS|EOF)
	 | {not self.needs_version}?=> (WS|EOF);

slot_name
	:	name[True,True,True,False] -> SLOT[$slot_name.text];

// must begin with alphanumerics
use_flag:	name[False,False,False,True] -> USE_FLAG[$use_flag.text];

category:	name[True,True,True,False] -> CATEGORY[$category.text];

name[start_plus,
     start_under,
     end_dot,
     end_at]:
	(
	name_part
	| {start_plus}? '+'
	| {start_under}? '_'
	)

	(
	name_part
	| '+'
	| '_'
	| HYPHEN
	| {end_dot}? '.'
	| {end_at}? '@'
	)*;

name_part:	INTEGER|ALPHA|EAPI0_VERSION_SPEC;

INTEGER	:	DIGIT+;

EAPI0_VERSION_SPEC
	: HYPHEN INTEGER ('.' INTEGER)* (LOWER)? STATE_SUFFIX* REVISION?;


fragment STATE_SUFFIX
	: '_' STATE INTEGER?;

fragment STATE: 'alpha'|'beta'|'pre'|'rc'|'p';

fragment REVISION: REVISION_START INTEGER;
fragment REVISION_START: '-r';

ALPHA: (LOWER|UPPER)+;

HYPHEN: '-';
NOT:	'!';
OPERATOR:	'<' | '<=' | '~' | '>=' | '>';
EQUALS:	'=';

WS  : (' '|'\r'|'\t'|'\u000C'|'\n')+; //There are places of mandatory ws so don't hide it

fragment DIGIT	:	'0'..'9';
fragment LOWER	:	'a'..'z';
fragment UPPER	:	'A'..'Z';
