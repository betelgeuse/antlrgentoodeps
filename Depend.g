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
	private boolean needs_version;
	private boolean accept_asterisk;
	public DependParser(TokenStream input, EAPIFeatures features) {
		this(input);
		this.features = features;
	}
}


depend: WS? (expr WS?)?;

expr	:	expr_type (WS expr_type)*;

expr_type:
	any_of | use_conditional | pkg_dep;

any_of
	:	'||' WS '(' WS (expr WS)* ')';

use_conditional
	:	use_flag '?' WS '(' WS (expr WS)* ')';

pkg_dep
	:	block_oper? (versioned_dep | qpn);

versioned_dep
@init {
	needs_version = true;
}
@after {
	needs_version = false;
	accept_asterisk = false;
}
:	OPERATOR qpn version_spec
	| EQUALS {accept_asterisk=true;} qpn version_spec;

block_oper	:	'!' ({features.STRONG_BLOCK}?=> '!'?);

version_spec
	:	EAPI0_VERSION_SPEC  asterisk? ({features.SLOT_DEPENDS}?=> slot_dep?) ({features.USE_DEPENDS}?=> use_dep? );

asterisk:
	{accept_asterisk}?=> '*'
	| {!accept_asterisk}?=>;
use_dep	:	'[' use_dep_atom (',' use_dep_atom)* ']';

use_dep_atom
	:	('!'|HYPHEN)? use_flag (EQUALS|'?')?;

slot_dep:
	':' slot_name;


qpn	:	 category '/' pn;

//pn	:	pn_start ((options { greedy=false; } : pn_char)* (pn_char pn_follows)=>pn_char)? {!pn_end.matcher($pn.text).matches()}?;
pn	:	pn_start 
	|	pn_start pn_end;

pn_end
	:	(options { greedy=false;} : pn_part)* (pn_part pn_follows)=> pn_part {!pn_end.matcher($pn_end.text).matches()}?;

// https://wincent.com/wiki/PEG-style_predicates_in_ANTLR
pn_middle:
	(pn_part (pn_follows| ) )=> pn_part;
pn_start : INTEGER|ALPHA|'+'|'_';
pn_part:  INTEGER|ALPHA|'+'|'_'|HYPHEN;

//pn_follows: version_spec? WS|EOF;

pn_follows
:
	 {needs_version}?=> version_spec (WS|EOF) 
	 | {!needs_version}?=> (WS|EOF);

//(alphanum|'+'|'_') (alphanum|'+'|'_'|DOT|'-')*
slot_name
	:	name[true,true,true,false];

// must begin with alphanumerics
use_flag:	name[false,false,false,true];

category:	name[true,true,true,false];

name[boolean start_plus,
     boolean start_under,
     boolean end_dot,
     boolean end_at]:
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
OPERATOR:	'<' | '<=' | '~' | '>=' | '>';
EQUALS:	'=';

WS  : (' '|'\r'|'\t'|'\u000C'|'\n')+; //There are places of mandatory ws so don't hide it

fragment DIGIT	:	'0'..'9';
fragment LOWER	:	'a'..'z';
fragment UPPER	:	'A'..'Z';
