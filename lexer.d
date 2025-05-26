import std.stdio;
import std.format;
import std.array;
import std.ascii;
import std.conv;

enum TokenType
{
    // Keywords
    KW_INT,
    KW_FLOAT,
    KW_UINT,
    KW_UFLOAT,
    KW_VOID,
    KW_IF,
    KW_ELSE,
    KW_GRAB,
    KW_ASYNC,
    KW_RETURN,

    // Identifiers
    IDENTIFIER,

    // Literals
    INTEGER_LITERAL,
    STRING_LITERAL,

    // Operators
    OP_PLUS,
    OP_MINUS,
    OP_MULTIPLY,
    OP_DIVIDE,
    OP_MODULO,
    OP_ASSIGN,
    OP_EQUALS,
    OP_REF,

    // Punctuation / Separators
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    SEMICOLON,
    COMMA,

    EOF,

    // Unknown token (for errors)
    UNKNOWN,
}

// Struct to represent a token
struct Token
{
    TokenType type; // The type of the token
    string lexeme; // The actual text of the token (e.g., "if", "myVar", "123")
    int line; // Line number where the token starts
    int column; // Column number where the token starts

    // A simple toString for easy printing
    string toString() const
    {
        return format("Token(Type: %s, Lexeme: \"%s\", Line: %d, Col: %d)", type, lexeme, line, column);
    }
}

struct Lexer
{
    string source;
    int currIndex;
    int line;
    int column;

    this(string sourceCode)
    {
        this.source = sourceCode;
        this.currIndex = 0;
        this.line = 1;
        this.column = 1;
    }

    /** 
        Checks if the end of source has been reached.
        @return bool 
     */
    bool atEnd()
    {
        return currIndex >= source.length;
    }

    char nextChar()
    {
        if (!atEnd())
        {
            char currChar = source[currIndex];
            currIndex++;

            if (currChar == '\n')
            {
                line++;
                column = 1;
            }
            else
            {
                column++;
            }
            return currChar;
        }

        return '\0';
    }

    /** 
     * View, don't consume.
     */
    char viewDc()
    {
        if (atEnd())
            return '\0';
        return source[currIndex];
    }

    void skipWS()
    {
        while (!atEnd())
        {
            char c = viewDc();

            if (isWhite(c))
                nextChar();
            else
                break;
        }
    }

    Token nextTok()
    {
        skipWS();

        int tokenStartln = line;
        int tokenStartcol = column;

        if (atEnd())
            return Token(TokenType.EOF, "", tokenStartln, tokenStartcol);

        char currTokStartchar = nextChar();

        if (isAlpha(currTokStartchar))
        {
            string lexeme = "";
            lexeme ~= currTokStartchar;

            while (!atEnd() && isAlphaNum(viewDc()))
                lexeme ~= nextChar();

            // For now, return as IDENTIFIER. We'll add keyword checking soon.
            return Token(TokenType.IDENTIFIER, lexeme, tokenStartln, tokenStartcol);
        }
        else
        {
            switch (currTokStartchar)
            {
            case '(':
                return Token(TokenType.LPAREN, "(", tokenStartln, tokenStartcol);
            case ')':
                return Token(TokenType.RPAREN, ")", tokenStartln, tokenStartcol);
            case '{':
                return Token(TokenType.LBRACE, "{", tokenStartln, tokenStartcol);
            case '}':
                return Token(TokenType.RBRACE, "}", tokenStartln, tokenStartcol);
            case ';':
                return Token(TokenType.SEMICOLON, ";", tokenStartln, tokenStartcol);
            case ',':
                return Token(TokenType.COMMA, ",", tokenStartln, tokenStartcol);
            case '+':
                return Token(TokenType.OP_PLUS, "+", tokenStartln, tokenStartcol);
            case '-':
                return Token(TokenType.OP_MINUS, "-", tokenStartln, tokenStartcol);
            case '*':
                return Token(TokenType.OP_MULTIPLY, "*", tokenStartln, tokenStartcol);
            case '/':
                return Token(TokenType.OP_DIVIDE, "/", tokenStartln, tokenStartcol);
            case '%':
                return Token(TokenType.OP_MODULO, "%", tokenStartln, tokenStartcol);
            case '&':
                return Token(TokenType.OP_REF, "&", tokenStartln, tokenStartcol);
            case '=':
                return Token(TokenType.OP_ASSIGN, "=", tokenStartln, tokenStartcol);
            default:
                return Token(TokenType.UNKNOWN, currTokStartchar.to!string, tokenStartln, tokenStartcol);
            }
        }

    }
}

void main()
{
    string codeToToken = "{\n variableName & + -;\n}";
    Lexer lex = Lexer(codeToToken);

    writeln("Tokenizing: \"", codeToToken.replace("\n", "\\n"), "\"");

    Token token;

    do
    {
        token = lex.nextTok();
        writeln(token);
    }
    while (token.type != TokenType.EOF);
}
