# The Xenos Language Specification

Xenos is *the stranger language* intended to enable programmers to write software via the literate programming paradigm and enable non-programmers to author documents using a friendly yet customizable markup language. Xenos programs are documents first, programs second. This core philosophy allows Xenos to meet the needs of both programmers and writers by inverting the conventional paradigms of each craft. The remainder of this document describes the Xenos language for implementation by compiler writers. 

## Program Structure

The structure of Xenos programs consists of two parts: physical structure and logical structure. The physical structure requirements describe how the arrangement of source files on the native file system forms the physical structure. The logical structure requirements describe how the contents of physical elements, such as source files, form the logical structure. These two parts work together to maintain consistency through all editing, compiling, debugging, and reflecting done on Xenos programs.

### Physical Structure

Xenos programs maintain consistency between the native file system representation and physical structure by deriving their physical structures from the presence or arrangement of source files and directories. This consistency ensures that programs will not accidentally create a physical or logical structure vastly different from how a complex Xenos program is viewed from within source code management solutions like Git.

#### Source Files

Source files are UTF-8 text files (without the byte order mark), containing Xenos source code, that have the `.xns` file extension. Implementations must accept source file names as the default argument to compiler invocation from the command line, and they may provide additional input paths. When processing the given source files, implementations must error when they encounter any of the following conditions:

* One or more source inputs contain byte order marks.
* One or more source inputs use non-UTF-8 encoding schemes.
* One or more source inputs lack the `.xns` file extension.
* One or more related failures as determined by the implementation.

#### Modules

Modules group related code and data as determined by programmers or writers. Modules are not source files; source files *describe* modules. Modules are primarily logical but derive their identifiers from the physical source files: Implementations must derive module identifiers by stripping the file system path, stripping the file extension, and replacing all lexically invalid identifier characters with underscores. For example, given the source file `My File.xdoc.xns`, implementations will derive `My_File_xdoc` as the module identifier.

#### Namespaces

Namespaces, like file system directories, group things. As such, implementations must treat directories as namespaces. The root directories of projects represent the global namespace for each project. Directories within the root directories form the physical namespace hierarchies for projects. Implementations must derive namespace identifiers from directory names by stripping the file system path relative to the current directory and replacing all lexically invalid identifier characters with underscores. For example, given the source file `./Frost Test/Shaping.xns`, implementations will determine that the `Shaping` module resides within the `Frost_Test` namespace.

#### Libraries

Libraries are .NET assemblies, which may be provided to implementations via a command line switch. Implementations should first check provided assemblies before looking in the global assembly cache. Implementations must expose all provided library members through the use of logical namespaces.

### Logical Structure

The dependencies between modules, namespaces, and libraries form the logical structure of Xenos programs.

#### Modules

Modules are named scopes that list available code and data items. Every Xenos program has one master module that serves as the starting point to compilation, and every module thereafter must be processed only once, regardless of how many modules import each module. By recursively following import declarations, implementations build acyclic dependency trees for Xenos programs. Implementations must detect and emit errors when they encounter cycles between modules.

#### Namespaces

Namespaces are a logical abstraction for grouping available data and code into hierarchies. By this definition, the specification treats modules as namespaces in addition to physical directories and available library data. The dot is used to separate namespaces. For example, given the source file `./Frost Test/Shaping.xns`, implementations will determine that the Shaping module resides within the `Frost_Test.Shaping` namespace. Implementations must maintain lists of all namespaces available in referenced libraries and in the physical structure of the current project.

## Syntax

The Xenos syntax follows a tree hierarchy: If text documents are sequences of paragraphs, Xenos source files are nested sequences of code and text blocks. To distinguish between these two types of blocks, implementations must implement the following section on blocks.

### Blocks

Blocks are collections of content delimited by blank lines in Xenos source files. Implementations must implement the two block types: text and code. The type of a block is determined by its content after leading attribute expressions if any leading attribute expressions are present.

#### Text Block

Text blocks are collections of nested text expressions. Implementations must assume that all blocks contain text expressions unless a code expression occurs first after any attribute expressions. The content of a text block must descend as children of an implicit `paragraph` markup object. All embedded code expressions must evaluate down to text instead of their respective object representations.

#### Code Block

Code blocks are collections of nested code expressions, which the compiler must evaluate. Implementations must evaluate blocks as code blocks if a code expression occurs first after any attribute expressions. All embedded text expressions must evaluate down to objects instead of their respective textual representations.

### Everything is a Function Call

All Xenos syntax transforms down into built-in and user-defined function or method calls. These calls may occur at compile time or at runtime in the executable program. 

#### Code Expression

	(<function identifier>: <function argument>*)

The basic form of all function and method calls, which are code expressions, consists of an opening parenthesis, the _function identifier_, a colon, zero or more position-dependent _function arguments_, and a closing parenthesis. When a code expression is embedded in a text expression, the code is evaluated to its textual representation.

> & Allow _function identifier_ to be an expression that resolves to an method or function name?

##### Function Identifier

	<typename or namespace>.*<method or function name>

The function identifier consists of zero or more typenames or namespaces or combinations of both denoted by the dot separator and the method or function name to call.

##### Function Arguments

	<expression> *

The positional arguments provided to a function or method must consist of zero or more _expressions_ delimited by one or more whitespace characters. 

#### Attribute Expression

	[<attribute typename>: <construction argument>*]

Every code or text expression in Xenos can have zero or more attributes, which may change compile time or runtime behavior or tag data to an expression. Every attribute expression consists of a opening square bracket, the _attribute typename_, a colon, zero or more _construction arguments_, and a closing square bracket. If a block contains only attribute expressions, these expressions apply to the module. If a block begins with attribute expressions, these expressions apply to the block. In all other cases, the attribute expression applies to the following code or text expression.

> & Allow _attribute typename_ to be an expression that resolves to an attribute typename?

##### Transformation to Code

	(new: <attribute typename> <construction argument>*)

After being transformed into a code expression, the transformed attribute expression can be evaluated like any other code expression.

#### Text Expression

	{<text typename>: <text content>}

The text expression consists of an opening curly brace, the _text typename_, a colon, zero or more items of _text content_, and a closing curly brace. When a text expression is embedded in a code expression, the text expression is evaluated into its object representation.

> & Allow _text typename_ to be an expression that resolves to the typename of a text object?

##### Text Content

All text content consists of plain UTF-8 text that may contain evaluatable Xenos code or text expressions. 

> & Should this implement a very simply markup language? Changing three dashes to a em-dash for instance?

##### Transformation to Code

	(new: <text typename> <text content>)

Consider the following example of nested markup content:

	{paragraph: Hello, this is a paragraph of {emphasize: nested markup} text.}

Aside from evaluatable Xenos code and text expressions, the text expression treats all other content as plain text, so as a code expression, the above example transforms to what follows:

	(new: paragraph "Hello, this is a paragraph of "
		(new: emphasize "nested markup") "text.")

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

#### Syntactic Sugar

Some common operations in Xenos have syntactic sugar to shorten the amount of code required to complete an operation.

##### Inferred Instance Constructor

	(<construction arguments>*)

The above syntactic sugar transforms into basic call form as follows:

	(new: <inferred type> <construction arguments>)
	
#### Character Escaping

Characters recognized as part of Xenos syntax can be escaped by prefixing them with a single backslash. Examples: `\{`, `\\`, `\(`. 

---------------------------------------------------------------

> Consider just adopting the .NET type system verbatim?

// We begin with the metadata for the module. Attributes apply to the next non-attribute s-expression within the block, but if no non-attribute s-expression exists in the block, the attribute applies to the module itself.

---------------

Shortcuts: `(<function name>)`, ``<paragraph text>``, `[@<attribute>]`

consider using backticks or quotation marks instead of `{}` for textual content

use attributes for textual environments? end environments with an "end" attribute

https://gist.github.com/fealty/1b8345fb8fcb1e2c3161

if attributes begin a block, they apply at the block level?

https://gist.github.com/fealty/29c3d553cd7c1c1cd931

((use .NET attributes in assemblies compiled from Xenos code to assign the Xenos-only name to classes and modules and functions))