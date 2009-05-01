PARSER_SRC=DependParser.java DependLexer.java
PARSER_CLASS=DependParser.class DependLexer.class

run: $(PARSER_CLASS) Main.class
	java -cp $(shell java-config -dp antlr-3):. Main $(ATOM)

depend-run: Depend.g
	antlr3 Depend.g
	touch $@

javac-run: $(PARSER_SRC)
	javac -cp $(shell java-config -dp antlr-3):. $(PARSER_SRC)
	touch $@

$(PARSER_SRC): depend-run

$(PARSER_CLASS): javac-run

Main.class: Main.java
	javac  -implicit:none -cp $(shell java-config -dp antlr-3):. Main.java

test: $(PARSER_CLASS)
	gunit Depend.testsuite

clean:
	rm -v antlr-run depend-run *.class $(PARSER_SRC)
