# Xenos

*the stranger language...*

## Program Structure

### Physical Structure

The layout of source files and dependencies in projects on the native file system forms the physical structure of Xenos programs.

#### Source Files

Source files are UTF-8 text files (without the byte order mark) having the `.xs` file extension. Implementations must emit errors when they encounter byte order marks in source files, non-UTF-8 encoding schemes, or files lacking the `.xs` file extension.

> We chose UTF-8 because it is popular and interoperable with legacy encodings. Specifications should not require implementations to support multiple text encodings when one encoding--UTF-8--will work just fine. That said, byte order marks in UTF-8 are silly; implementations should not have to define their own behavior for that silly thing, so we mandate its omission from source files. We do not like the C++ litany of source file extension confusion: .hpp, .c, .h, .cxx, .cpp, etc. The specification should enable tools to identify source files by their file extension.

#### Modules

Modules group code and data Source files and modules have a relationship, but source files are not modules: Source files *describe* modules. Only module identifiers derive from the physical source files. Implementations must derive module identifiers as follows: strip the file system path; strip the file extension as denoted by the final dot; and replace all lexically invalid identifier characters with hyphens. For example, given the source file My `File.xdoc.xs`, implementations will produce `My-File-xdoc` as the module identifier.

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

By default, all source files begin in text mode. They are given an implicit **TextModeAttribute** at the beginning of the file. This mode treats all items as implicit textual markup paragraphs, wrapping them with `\paragraph{<item data>}`. Any embedded code expressions, as denoted by unescaped (), will evaluate down to text instead of their object representations.