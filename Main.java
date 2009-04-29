import org.antlr.runtime.*;
//import java.util.regex.*;

class Main {
    public static void main(String[] args) throws Exception {
        String source = args.length > 0 ? args[0] : "-3";
        DependLexer lex = new DependLexer(new ANTLRStringStream(source));
        /*
		Pattern p = Pattern.compile(".*-\\d+$");
		System.out.println(p.matcher("foo-123").matches());
*/
       	CommonTokenStream tokens = new CommonTokenStream(lex);

        DependParser parser = new DependParser(tokens);

        try {
            parser.depend();
        } catch (RecognitionException e)  {
            e.printStackTrace();
			System.exit(1);
        }
    }
}

