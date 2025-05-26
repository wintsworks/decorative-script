import std.stdio;
import std.format;
import std.array;
import std.ascii;
import std.conv;

enum TokenType {
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
    OP_NOT,
    OP_NOT_EQUALS,
    OP_LESS_THAN,
    OP_LESS_THAN_OR_EQUAL,
    OP_GREATER_THAN,
    OP_GREATER_THAN_OR_EQUAL,
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
struct Token {
    TokenType type; // The type of the token
    string lexeme; // The actual text of the token (e.g., "if", "myVar", "123")
    int line; // Line number where the token starts
    int column; // Column number where the token starts

    // A simple toString for easy printing
    string toString() const {
        return format("Token(Type: %s, Lexeme: \"%s\", Line: %d, Col: %d)", type, lexeme, line, column);
    }
}

struct Lexer {
    static immutable TokenType[string] keywords;

    shared static this() {
        keywords = [
            "int": TokenType.KW_INT,
            "uint": TokenType.KW_UINT,
            "float": TokenType.KW_FLOAT,
            "ufloat": TokenType.KW_UFLOAT,
            "void": TokenType.KW_VOID,
            "if": TokenType.KW_IF,
            "else": TokenType.KW_ELSE,
            "grab": TokenType.KW_GRAB,
            "async": TokenType.KW_ASYNC,
            "return": TokenType.KW_RETURN,
        ];
    }

    string source;
    int currIndex;
    int line;
    int column;

    this(string sourceCode) {
        this.source = sourceCode;
        this.currIndex = 0;
        this.line = 1;
        this.column = 1;
    }

    /** 
            Checks if the end of source has been reached.
            @return bool 
        */
    bool atEnd() {
        return currIndex >= source.length;
    }

    char nextChar() {
        if (!atEnd()) {
            char currChar = source[currIndex];
            currIndex++;

            if (currChar == '\n') {
                line++;
                column = 1;
            } else {
                column++;
            }
            return currChar;
        }

        return '\0';
    }

    /** 
        * View, don't consume.
        */
    char viewDc() {
        if (atEnd())
            return '\0';
        return source[currIndex];
    }

    void skipWS() {
        while (!atEnd()) {
            char c = viewDc();

            if (isWhite(c))
                nextChar();
            else
                break;
        }
    }

    bool matchAndConsume(char expected) {
        if (atEnd())
            return false;
        if (viewDc() != expected)
            return false;

        nextChar();
        return true;
    }

    Token nextTok() {
        skipWS();

        int tokenStartln = line;
        int tokenStartcol = column;

        if (atEnd()) {
            return Token(TokenType.EOF, "", tokenStartln, tokenStartcol);
        }

        char currTokStartchar = nextChar();

        // 1. Check if it's an Identifier or Keyword
        if (isAlpha(currTokStartchar)) {
            string lexeme = ""; // Lexeme for the identifier/keyword
            lexeme ~= currTokStartchar;

            while (!atEnd() && isAlphaNum(viewDc())) {
                lexeme ~= nextChar();
            }

            // Check if the recognized identifier is a keyword
            if (auto tokenTypePtr = lexeme in keywords) {
                return Token(*tokenTypePtr, lexeme, tokenStartln, tokenStartcol);
            } else {
                // It's a regular identifier
                return Token(TokenType.IDENTIFIER, lexeme, tokenStartln, tokenStartcol);
            }

        } else if (isDigit(currTokStartchar)) {

            string numberLexeme = "";
            numberLexeme ~= currTokStartchar;

            while (!atEnd() && isDigit(viewDc())) {
                numberLexeme ~= nextChar();
            }
            return Token(TokenType.INTEGER_LITERAL, numberLexeme, tokenStartln, tokenStartcol);

        } else if (currTokStartchar == '"') {
            string stringLexeme = "";

            while (!atEnd() && viewDc() != '"') {
                char charInString = nextChar();

                if (charInString == '\\' && !atEnd()) {
                    char escapedChar = viewDc();

                    switch (escapedChar) {
                    case '"':
                        stringLexeme ~= nextChar();
                        break;
                    case '\\':
                        stringLexeme ~= nextChar();
                        break;
                    case 'n':
                        stringLexeme ~= '\n';
                        nextChar();
                        break;
                    case 't':
                        stringLexeme ~= '\t';
                        nextChar();
                        break;
                    default:
                        stringLexeme ~= charInString;
                        break;
                    }
                } else {
                    stringLexeme ~= charInString;
                }
            }
            if (atEnd()) {
                writeln("Error: Unterminated string literal at line ", tokenStartln, ", col ", tokenStartcol);
                return Token(TokenType.UNKNOWN, "\"" ~ stringLexeme, tokenStartln, tokenStartcol);
            }

            nextChar();

            return Token(TokenType.STRING_LITERAL, stringLexeme, tokenStartln, tokenStartcol);
        } else {

            switch (currTokStartchar) {
            case '=':
                if (matchAndConsume('=')) {
                    return Token(TokenType.OP_EQUALS, "==", tokenStartln, tokenStartcol);
                } else {
                    return Token(TokenType.OP_ASSIGN, "=", tokenStartln, tokenStartcol);
                }
            case '!':
                if (matchAndConsume('=')) {
                    return Token(TokenType.OP_NOT_EQUALS, "!=", tokenStartln, tokenStartcol);
                } else {
                    return Token(TokenType.OP_NOT, "!", tokenStartln, tokenStartcol);
                }
            case '<':
                if (matchAndConsume('=')) {
                    return Token(TokenType.OP_LESS_THAN_OR_EQUAL, "<=", tokenStartln, tokenStartcol);
                } else {
                    return Token(TokenType.OP_LESS_THAN, "<", tokenStartln, tokenStartcol);
                }
            case '>':
                if (matchAndConsume('=')) {
                    return Token(TokenType.OP_GREATER_THAN_OR_EQUAL, ">=", tokenStartln, tokenStartcol);
                } else {
                    return Token(TokenType.OP_GREATER_THAN, ">", tokenStartln, tokenStartcol);
                }

                // Ensure other single character tokens are here and NOT duplicated
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

            default:
                return Token(TokenType.UNKNOWN, currTokStartchar.to!string, tokenStartln, tokenStartcol);
            }

        }
    }
}

void main() {
    // Test string including various string literal cases
    string codeToToken = "{ \"hello world\" grab \"test\\n \\\"escapes\\\"\" \"unterminated";
    Lexer lex = Lexer(codeToToken);

    writeln("Tokenizing: \"", codeToToken.replace("\n", "\\n"), "\""); // Using replace for display

    Token token;
    do {
        token = lex.nextTok();
        writeln(token);
    }
    while (token.type != TokenType.EOF);
}