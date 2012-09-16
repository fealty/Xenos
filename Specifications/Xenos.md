# The Xenos Language Specification

Xenos is *the stranger language* intended to enable programmers to write software via the literate programming paradigm and enable non-programmers to author documents using a friendly yet customizable markup language. Xenos programs are documents first, programs second. This core philosophy allows Xenos to meet the needs of both programmers and writers by inverting the conventional paradigms of each craft. The remainder of this document describes the Xenos language for implementation by compiler writers. Newbies to the language should read the introductory tutorials first.

## Program Structure

The structure of Xenos programs consists of two parts: physical structure and logical structure. The physical structure requirements describe how the arrangement of source files on the native file system forms the physical structure. The logical structure requirements describe how the contents of physical elements, such as source files, form the logical structure. These two parts work together to maintain consistency through all editing, compiling, debugging, and reflecting done on Xenos programs.

### Physical Structure

Xenos programs maintain consistency between the native file system representation and physical structure by deriving their physical structures from the presence or arrangement of source files and directories. This consistency ensures that programs will not accidentally create a physical or logical structure vastly different from how a complex Xenos program is viewed from within source code management solutions like Git.

#### Source Files

Source files are UTF-8 text files (without the byte order mark), containing Xenos source code, that have the `.xs` file extension. Implementations must accept source file names as the default argument to compiler invocation from the command line, and they may provide additional input paths. When processing the given source files, implementations must error when they encounter any of the following conditions:

* One or more source inputs contain byte order marks.
* One or more source inputs use non-UTF-8 encoding schemes.
* One or more source inputs lack the `.xs` file extension.
* One or more related failures as determined by the implementation.

#### Modules

Modules group related code and data as determined by programmers or writers. Modules are not source files; source files *describe* modules. Modules are primarily logical but derive their identifiers from the physical source files: Implementations must derive module identifiers by stripping the file system path, stripping the file extension, and replacing all lexically invalid identifier characters with underscores. For example, given the source file `My File.xdoc.xs`, implementations will derive `My_File_xdoc` as the module identifier.

#### Namespaces

Namespaces, like file system directories, group things. As such, implementations must treat directories as namespaces. The root directories of projects represent the global namespace for each project. Directories within the root directories form the physical namespace hierarchies for projects. Implementations must derive namespace identifiers from directory names by stripping the file system path relative to the current directory and replacing all lexically invalid identifier characters with underscores. For example, give the source file `./Frost Test/Shaping.xs`, implementations will determine that the `Shaping` module resides within the `Frost_Test` namespace.

#### Libraries

Libraries are .NET assemblies, which may be provided to implementations via a command line switch. Implementations should first check provided assemblies before looking in the global assembly cache. Implementations must expose all provided library members through the use of logical namespaces.

### Logical Structure

The dependencies between modules, namespaces, and libraries form the logical structure of Xenos programs.

#### Modules

Modules are named scopes that list available code and data items. Every Xenos program has one master module that serves as the starting point to compilation, and every module thereafter must be processed only once, regardless of how many modules import each module. By recursively following import declarations, implementations build acyclic dependency trees for Xenos programs. Implementations must detect and emit errors when they encounter cycles between modules.

#### Namespaces

Namespaces are a logical abstraction for grouping available data and code into hierarchies. By this definition, the specification treats modules as namespaces in addition to physical directories and available library data. The dot is used to separate namespaces. For example, given the source file `./Frost Test/Shaping.xs`, implementations will determine that the Shaping module resides within the `Frost_Test.Shaping` namespace. Implementations must maintain lists of all namespaces available in referenced libraries and in the physical structure of the current project.

## Syntax

The Xenos syntax follows a simple hierarchy: higher level structure followed by content. If text documents are sequences of paragraphs, Xenos source files are sequences of code and data blocks. In the case of literate programming, Xenos source files are paired sequences of one data block, consisting of markup content, followed immediately by one code block. To distinguish between these two types of blocks, implementations must implement the following section on interpretative modes.

### Interpretative Modes

Implementations must implement the two interpretative modes: data and code, which form the basis for all possible content interpretation in Xenos program code. Specialized attributes are used to switch between modes. Modes are terminated by a sequence of two blank lines or the end of file, which instructs the compiler to return to previous mode.

#### Data Mode

All interpretation of program code begins in text mode, which is a built-in specialization of data mode designed to handle markup content. Data mode enables the compiler to interpret data content within Xenos source files. Users may implement custom data modes by reimplementing `DataModeAttribute` and `DataModeProvider`.

##### Text Mode

This built-in mode treats all items as implicit textual markup, implicitly wrapping them in `{paragraph: <textual content>}` blocks. Any embedded code expressions, as denoted by unescaped parentheses, will evaluate down to text content instead of their respective object representations.

#### Code Mode

This built-in mode treats all items as Xenos source code. It does not implicitly wrap anything. All expressions will evaluate down to their object representations.

##### Relationship to Text Mode

For convenience, Xenos treats text markup as a first class feature of the language. Textual markup can be included within code by explicitly placing textual content within a `paragraph` or other markup construct: `{paragraph: <content>}`.

### Everything is a Function Call

All Xenos syntax transforms down into built-in and user-defined function or method calls. 

#### Basic Call Form

	[<optional attribute>]* (<function identifier> [<optional parameter>]*: <function arguments>*)

The basic form of all function and method calls consists of zero or more *optional attributes*, an opening parenthesis, the *function identifier* identifier, zero or more *optional parameters*, a terminating colon, zero or more position-dependent *function arguments*, and a closing parenthesis.

##### Optional Attributes

Every expression in Xenos can have zero or more attributes applied, which may take effect at compile time or runtime depending on the attribute. See also: *Attribute Form*.

##### Function Identifier

	<optional module or type name>.*<method or function name>

The function identifier consists of zero or more typenames denoted by the dot separator and the method or function name to call on the module or type.

##### Optional Parameters

	[<parameter identifier> <expression>]

Functions and methods may define parameters with default values. To call the function or method with a value other than the default, one must provide an optional parameter. This consists of the *parameter identifier*, one or more whitespace characters, and the *expression* to assign to the parameter as its new value. All of this must be enclosed within square brackets. 

##### Function Arguments

	<expression> *

The positional arguments provided to a function or method must consist of zero or more *expression*s delimited by one or more whitespace characters. 

#### Attribute Form

	[@<attribute type> [<optional parameter>]*: <args>*]



To make attributes distinct from normal function calls, implementations must implement the attribute form in addition to the basic form as follows: the *at-sign* followed immediately by the *attribute type*; one or more white space characters; zero or more *optional arguments*; one or more white space characters if optional arguments are given; zero or one parenthetical set enclosing zero or more *required arguments*.

```
@<attribute-type> [<optional-arguments>]* (<required-arguments>*)?
```

The attribute form transforms into the basic construction form as follows:

```
(new <attribute-type> <optional-arguments> <required-arguments>)
```

> We wanted attributes to stand out in both code and text. They also needed a unique syntactic sugar to avoid having to new them manually.

#### Text Markup Form

Xenos programs require large amounts of text. For this purpose, implementations must implement the text markup form as follows: a single backslash followed by the *markup type*; zero or more spaces; zero or more *optional arguments*, each enclosed by a set of brackets; zero or more spaces; a set of braces if *nested markup* is given.

```
\<markup-type> [<optional-arguments>]* {<nested-markup>}?
```

The text markup form itself transforms down into the following:

```
(new <markup-type> <optional-arguments> <required arguments>)
```

For example, consider the following line of nested markup:

```
\paragraph{Hello, this is a paragraph of \emphasize{nested markup} text.}
```

The markup form treats everything aside from other forms as text, so in basic form, the above becomes as follows:

```
(new paragraph “Hello, this is a paragraph of ” 
  (new emphasize “nested markup”) “text.”)
```

> We needed a way to build trees of text markup. The text markup form easily enables this, solving the problem of including large amounts of semantic text.

#### Replacement Form

To enable literate programming within modules, implementations must provide the s-expression replacement form, which is defined as follows: the dollar sign followed by a *function* that returns an s-expression; zero or more spaces; zero or more *optional arguments*, each enclosed in a set of brackets; zero or more spaces; zero or one set of parentheses having zero or more *required arguments* enclosed. 

```
$<function> [<optional-arguments>]* (<required-arguments>)?
```

This form transforms down into the following immediately after the AST is built for its containing module item:

```
(<function> [<optional arguments>]* <required-arguments>)
```

> We need a way to include chunks of code by name, so we devised the replacement form as a special function call always evaluated immediately after an module item's AST is fully built. This enables users to include chunks of AST from within the module and from dependent modules.

> Consider just adopting the .NET type system verbatim?
