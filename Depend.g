grammar Depend;

options {
	backtrack=true;
}

@header {
	import java.util.regex.Pattern;
}

@members {
public class EAPIFeatures
{
	public static final boolean DEFAULT = true;
	public boolean STRONG_BLOCK = DEFAULT;
	public boolean SLOT_DEPENDS = DEFAULT;
	public boolean USE_DEPENDS = DEFAULT;
}

	private EAPIFeatures features = new EAPIFeatures();
	private Pattern pn_end = Pattern.compile(".*-\\d+");
	private Pattern version_char = Pattern.compile("[a-z]");
	public DependParser(TokenStream input, EAPIFeatures features) {
		this(input);
		this.features = features;
	}
}


depend: WS? expr WS?;

expr	:	expr_type (WS expr_type)*;

expr_type:
	any_of | use_conditional | pkg_dep;

any_of
	:	'||' WS '(' WS (expr WS)* ')';

use_conditional
	:	use_flag '?' WS '(' WS (expr WS)* ')';

pkg_dep
scope {
	boolean needs_version;
}
	:	block_oper? (OPERATOR {$pkg_dep::needs_version = true;} qpn version_spec | qpn);

block_oper	:	'!' ({features.STRONG_BLOCK}?=> '!'?);

version_spec
	:	'-' eapi0_version_spec ( {features.SLOT_DEPENDS}?=> slot_dep? ) ( {features.USE_DEPENDS}?=> use_dep? );

use_dep	:	'[' use_dep_atom (',' use_dep_atom)* ']';

use_dep_atom
	:	('!'|'-')? use_flag ('='|'?')?;

slot_dep:
	':' slot_name;


eapi0_version_spec
	: INTEGER ('.' INTEGER)* (ALPHA {version_char.matcher($ALPHA.text).matches()}?)? state_suffix* revision?;

state_suffix
	: '_' STATE INTEGER?;

revision: REVISION_START INTEGER;

qpn	:	 category '/' pn;

//pn	:	pn_start ((options { greedy=false; } : pn_char)* (pn_char pn_follows)=>pn_char)? {!pn_end.matcher($pn.text).matches()}?;
pn	:	pn_start
	|	pn_start pn_middle* pn_char {!pn_end.matcher($pn.text).matches()}?;

// https://wincent.com/wiki/PEG-style_predicates_in_ANTLR
pn_middle:
	(pn_char ((pn_follows)=>{false}?| ) )=> pn_char;
pn_start : name_part|'+'|'_';
pn_char:  name_part|'+'|'_'|'-';

//pn_follows: version_spec? WS|EOF;

pn_follows
:
	 {$pkg_dep.size() > 0 && $pkg_dep::needs_version}?=> version_spec (WS|EOF)
	 | {$pkg_dep.size() == 0 || $pkg_dep::needs_version}?=> (WS|EOF);

//(alphanum|'+'|'_') (alphanum|'+'|'_'|DOT|'-')*
slot_name
	:	name[true,true,false,true,false];

use_flag:	name[false,false,false,false,true];

category:	name[true,true,true,true,false];

name[boolean start_plus,
     boolean start_under,
     boolean start_dot,
     boolean end_dot,
     boolean end_at]:
	(
	name_part
	| {start_plus}? '+'
	| {start_under}? '_'
	| {start_dot}? '.'
	)

	(
	name_part
	| '+'
	| '_'
	| '-'
	| {end_dot}? '.'
	| {end_at}? '@'
	)*;

name_part:	INTEGER|ALPHA|STATE|REVISION_START;

REVISION_START: '-r';

INTEGER	:	DIGIT+;

STATE: 'alpha'|'beta'|'pre'|'rc'|'p';

ALPHA: (LOWER|UPPER)+;

OPERATOR:	'<' | '<=' | '=' | '~' | '>=' | '>';

WS  : (' '|'\r'|'\t'|'\u000C'|'\n')+; //There are places of mandatory ws so don't hide it

fragment DIGIT	:	'0'..'9';
fragment LOWER	:	'a'..'z';
fragment UPPER	:	'A'..'Z';
