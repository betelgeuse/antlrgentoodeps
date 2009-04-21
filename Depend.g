grammar Depend;

options {
	backtrack=true;
}

scope VersionScope {
	boolean needs_version;
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
	private List<String> states = java.util.Arrays.asList("alpha","beta","pre","rc","p");
	private java.util.regex.Pattern pn_end = java.util.regex.Pattern.compile(".*-\\d+");
	public DependParser(TokenStream input, EAPIFeatures features) {
		this(input);
		this.features = features;
	}
}

depend: expr;

expr	:	WS | expr_type (WS expr_type)*;

expr_type:
	any_of | use_conditional | pkg_dep;

any_of	
	:	'||' WS '(' WS (expr WS)* ')';
		
use_conditional
	:	use_flag '?' WS '(' WS (expr WS)* ')';

pkg_dep
scope VersionScope;
	:	block_oper? (OPERATOR {$VersionScope::needs_version = true;} qpn version_spec | qpn);

block_oper	:	'!' ({features.STRONG_BLOCK}?=> '!'?);

version_spec
options {
	backtrack=true;
}
	:	'-' eapi0_version_spec ( {features.SLOT_DEPENDS}?=> slot_dep? ) ( {features.USE_DEPENDS}?=> use_dep? );

use_dep	:	'[' use_dep_atom (',' use_dep_atom)* ']';

use_dep_atom
	:	('!'|'-')? use_flag ('='|'?')?;
	
slot_dep:	
	':' slot_name;
	
slot_name
	:	(alphanum|'+'|'_') (alphanum|'+'|'_'|DOT|'-')*;
	
eapi0_version_spec
	: integer (DOT integer)* LOWER? state_suffix* revision?;

state_suffix
	: '_' (word {states.contains($word.text)}?) integer?;
	
revision: '-' (LOWER {"r".equals($LOWER.text)}?) integer;

qpn	:	 category '/' pn;

use_flag:	alphanum (alphanum|'+'|'_'|'@'|'-')*;

category:	(alphanum|'+'|'_'|DOT) (alphanum|'+'|'_'|DOT|'-')*;

pn	:	(alphanum|'+'|'_') (options { greedy=false; } : pn_char)* (pn_char pn_follows)=>pn_char {!pn_end.matcher($pn.text).matches()}?;

pn_char:  alphanum|'+'|'_'|'-';

pn_follows
scope VersionScope;
:
	( {$VersionScope::needs_version}?=>version_spec ) (WS|EOF);

integer	:	DIGIT+;

word: (LOWER|UPPER)+;

alphanum:	LOWER|UPPER|DIGIT;

OPERATOR:	'<' | '<=' | '=' | '~' | '>=' | '>'; 

WS  : (' '|'\r'|'\t'|'\u000C'|'\n')+; //There are places of mandatory ws so don't hide it

DOT 	: '.';

DIGIT	:	'0'..'9';
LOWER	:	'a'..'z';
UPPER	:	'A'..'Z';
