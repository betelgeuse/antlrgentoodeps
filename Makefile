PARSER_SRC=DependParser.java DependLexer.java
PARSER_CLASS=DependParser.class DependLexer.class

run: $(PARSER_CLASS) Main.class
	java -cp $(shell java-config -dp antlr-3):. Main $(ATOM)

antlr-run: Depend.g
	antlr3 Depend.g
	touch $@

$(PARSER_SRC): antlr-run

%.class: %.java
	javac  -implicit:none -cp $(shell java-config -dp antlr-3):. $<

test: $(PARSER_CLASS)
	gunit Depend.testsuite

clean:
	rm -v antlr-run *.class Depend*.java
