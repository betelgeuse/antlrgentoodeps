import org.antlr.runtime.*;
import java.util.regex.*;

class Main {
    public static void main(String[] args) throws Exception {
        DependLexer lex = new DependLexer(new ANTLRStringStream("foo-12"));
		Pattern p = Pattern.compile(".*-\\d+$");
		System.out.println(p.matcher("foo-123").matches());

       	CommonTokenStream tokens = new CommonTokenStream(lex);

        DependParser parser = new DependParser(tokens);

        try {
            parser.pn();
        } catch (RecognitionException e)  {
            e.printStackTrace();
        }
    }
}

