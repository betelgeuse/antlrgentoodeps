tree grammar UseFlatten;

options {
	tokenVocab=Depend;
	ASTLabelType=CommonTree;
	output=AST;
}
tokens {
	FLATTEN;
}
@header {
	import java.util.List;
	import java.util.Arrays;
}
@members {
	List<String> flags = Arrays.asList("test");
}

use_conditional: ^(USE_CONDITIONAL ^(use=USE_FLAG POSITIVE) PKG_DEP )
	-> {flags.contains($use.text)}? ^(FLATTEN PKG_DEP)
	-> ;
	
use_conditional_not: ^(USE_CONDITIONAL ^(use=USE_FLAG NEGATIVE) PKG_DEP)
	-> {!flags.contains($use.text)}? ^(FLATTEN PKG_DEP)
	-> ;
