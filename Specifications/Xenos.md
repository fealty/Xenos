# Xenos: Language Specification

*the stranger language...*

This document describes the Xenos language for implementation by compiler writers.

## Program Structure

The structure of Xenos programs consists of two parts: physical structure and logical structure. The physical structure requirements describe the arrangement of program sources on the native file system. The logical structure requirements describe the program structure built internally by an implementation.

### Physical Structure

The layout of source files and dependencies in projects on the native file system forms the physical structure of Xenos programs.

#### Source Files

Source files are UTF-8 text files (without the byte order mark) having the `.xs` file extension. Implementations must emit errors when they encounter byte order marks in source files, non-UTF-8 encoding schemes, or files lacking the `.xs` file extension.

> We chose UTF-8 because it is popular and interoperable with legacy encodings. Specifications should not require implementations to support multiple text encodings when one encoding--UTF-8--will work just fine. That said, byte order marks in UTF-8 are silly; implementations should not have to define their own behavior for that silly thing, so we mandate its omission from source files. We do not like the C++ litany of source file extension confusion: .hpp, .c, .h, .cxx, .cpp, etc. The specification should enable tools to identify source files by their file extension.

#### Modules

Modules group code and data. Source files and modules have a relationship, but source files are not modules: Source files *describe* modules. Only module identifiers derive from the physical source files. Implementations must derive module identifiers as follows: strip the file system path; strip the file extension as denoted by the final dot; and replace all lexically invalid identifier characters with hyphens. For example, given the source file My `File.xdoc.xs`, implementations will produce `My-File-xdoc` as the module identifier.

> Editors should display filenames with sub-extensions, such as the one in our example above, as children of the main .xs file. These files may be generated from the main .xs file, but they always indicate that the child file depends upon the parent.

#### Namespaces

Namespaces, like file system directories, group things (see [sub:Namespaces] for the comprehensive definition.) As such, implementations must treat directories as namespaces. The root directories of projects represent the global namespace. Directories within the root directories form the physical namespace hierarchies for projects. Implementations must derive namespace identifiers from directory names as follows: strip the file system path relative to the current directory and replace all lexically invalid identifier characters with hyphens. For example, given the source file `./Frost Test/Shaping.xs`, implementations will determine that `Shaping.xs` resides within the `Frost-Test` namespace.

> We chose to use directories as namespaces to guarantee consistency between the physical and logical structures of Xenos programs. This consistency eases navigation and understanding when viewing source files through version control systems. This approach also makes it impossible to pollute the global namespace, which we reserve for specification and implementation use only.

#### Libraries

Libraries are implementation dependent collections of data and code that Xenos sources can interoperate with through the implementation. The use of such libraries necessarily ties source files to particular implementations. Implementations must expose library members through the use of logical namespaces.

> For now, we leave the majority of this functionality up to the implementation. In later revisions, we may require a platform such as LLVM, .NET, or Parrot, which would necessitate further definition.

### Logical Structure

The dependencies between modules, namespaces, and libraries form the logical structure of Xenos programs.

#### Modules

Modules are named scopes that list available code and data items. Every Xenos program has one master module that serves as the starting point to compilation. By recursively following import declarations, implementations build acyclic dependency trees for Xenos programs. Implementations must detect and emit errors when they encounter cycles between modules. 

> We understand that we can safely allow cyclic dependencies in certain common situations, but we chose to ban them in total for the following reasons: to force better encapsulation, to make dependency resolution easier to implement, to encourage better API design, and to fit with our linear processing model. Resolve cycle problems by creating modules that depend upon otherwise cyclic dependencies, and implement the functionality within these new modules. If struct A depends on struct B and struct B depends upon struct A for the implementation of method X on both structures, simply create a new module that depends on both and add the methods as extensions to each structure. 

#### Namespaces

Namespaces are a logical abstraction for grouping available data and code into hierarchies. By this definition, the specification treats modules as namespaces in addition to physical directories and available library data. The dot is used to separate namespaces. For example, given the source file `./Frost Test/Shaping.xs`, implementations will determine that the Shaping module resides within the `Frost-Test.Shaping` namespace. Implementations must maintain lists of all namespaces available in referenced libraries and the physical structure of the current project.

> In later revisions, we may require non-Xenos code interoperation to generate compile time wrapper modules, which by their physical nature prevent namespace conflicts. This may also be required to transform external identifiers into the format appropriate for use in Xenos source files, which we are considering forcing to all lowercase.

## Syntax

### Definition Modes

Xenos source files are lists of items delimited by blank lines. The types of these items, excepting attributes, depends not only on the code used to create them, but the current definition mode of the implementation.

#### Text Mode

By default, all source files begin in text mode. They are given an implicit **TextModeAttribute** at the beginning of the file. This mode treats all items as implicit textual markup paragraphs, wrapping them with `\paragraph{<item data>}`. Any embedded code expressions, as denoted by unescaped `()`, will evaluate down to text instead of their object representations.

> We have two broad goals in mind for Xenos: you can write a novel in it; you can write a video game in it. By choosing text mode as the default, we enable not only writing novels but encourage programmers to use literate programming to write their software. We allow embedded code expressions to allow for REPL and any kind of advanced text generation like a unit test report.

#### Code Mode

When implementations encounter an attribute derived from **CodeModeAttribute**, implementations will switch to code mode. This mode treats all items exactly as they appear. Unlike text mode, code mode does not wrap items in any implicit context. This forbids writing paragraphs unless they are enclosed by an explicit `\paragraph{}`, but it allows code objects to evaluate to their object representations. When implementations encounter two or more consecutive blank lines, implementations must switch back to text mode. The end of files may also end the mode.

> Text mode alone doesn't allow us to create programs because everything evaluates to text, not executable code. Code mode allows us to define functions on modules, types on modules, in addition to data like lists and hash tables. You know, the stuff that should actually get compiled.

#### Data Mode

When implementations encounter an attribute derived from **DataModeAttribute**, implementations will switch to data mode. This mode treats all of the content as a verbatim string by default, but users can supply a **DataModeProvider** that provides an interface to the data. This interface can be accessed elsewhere in the source files. When implementations encounter three or more consecutive blank lines, implementations must switch back to text mode. The end of files may also end the mode.

> We intend to allow the embedding of any textual content within source files. Users can embed XML data or code from another language if they wish. Our **DataModeProvider** enables code to access non-Xenos data at compile time through Xenos interfaces. We believe this is a very useful feature. This may be a generalization of text mode. If possible, we should look into implementing text mode through the use of data mode.

### Everything is a Function Call

All Xenos syntax transforms down into built-in and user-defined function calls. 

#### Basic Function Form

The basic form of all function calls is defined as follows within opening and closing parentheses: zero or more *attributes*, each enclosed by a set of brackets; one or more characters of white space if attributes are given; the *function identifier* for the function being called; one or more characters of white space; zero or more *optional arguments*, each enclosed by a set of brackets; one or more characters of white space if optional arguments are given; and zero or more *required arguments*.

```
([<attribute>]* <function-identifier> [<optional-argument>]* <required-arguments>*)
```

> We chose s-expressions because they are easy to parse. In order to support assigning attributes to arbitrary data structures---methods, parameters, member variables, etc.---we have chosen to allow attributes to be given in the s-expression and passed along to the function when evaluation occurs. This allows attributes to be used on s-expressions at compile time and pass through to arbitrary objects for application to compilation.

#### Attribute Form

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

