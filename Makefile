PARSER_SRC=DependParser.java DependLexer.java
PARSER_CLASS=DependParser.class DependLexer.class

run: $(PARSER_CLASS) Main.class
	java -cp $(shell java-config -dp antlr-3):. Main $(ATOM)

%.run: %.g
	antlr3 $<
	touch $@

javac.run: $(PARSER_SRC)
	javac -cp $(shell java-config -dp antlr-3):. $(PARSER_SRC)
	touch $@

$(PARSER_SRC): Depend.run

$(PARSER_CLASS): javac.run

%.class: %.java
	javac  -implicit:none -cp $(shell java-config -dp antlr-3):. $<

UseFlatten.java: UseFlatten.run

test: $(PARSER_CLASS) UseFlatten.class
	gunit Depend.testsuite
	gunit UseFlatten.testsuite

clean:
	rm -v *.run *.class $(PARSER_SRC)
