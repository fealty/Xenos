# Xenos

*the stranger language...*

## Program Structure

### Physical Structure

The layout of source files and dependencies in projects on the native file system forms the physical structure of Xenos programs.

#### Source Files

Source files are UTF-8 text files (without the byte order mark) having the `.xs` file extension. Implementations must emit errors when they encounter byte order marks in source files, non-UTF-8 encoding schemes, or files lacking the `.xs` file extension.

> We chose UTF-8 because it is popular and interoperable with legacy encodings. Specifications should not require implementations to support multiple text encodings when one encoding---UTF-8---will work just fine. That said, byte order marks in UTF-8 are silly; implementations should not have to define their own behavior for that silly thing, so we mandate its omission from source files. We do not like the C++ litany of source file extension confusion: .hpp, .c, .h, .cxx, .cpp, etc. The specification should enable tools to identify source files by their file extension.

#### Modules

Modules group code and data Source files and modules have a relationship, but source files are not modules: Source files *describe* modules. Only module identifiers derive from the physical source files. Implementations must derive module identifiers as follows: strip the file system path; strip the file extension as denoted by the final dot; and replace all lexically invalid identifier characters with hyphens. For example, given the source file My `File.xdoc.xs`, implementations will produce `My-File-xdoc` as the module identifier.

> Editors should display filenames with sub-extensions, such as the one in our example above, as children of the main .xs file. These files may be generated from the main .xs file, but they always indicate that the child file depends upon the parent.

#### Namespaces

Namespaces, like file system directories, group things (see [sub:Namespaces] for the comprehensive definition.) As such, implementations must treat directories as namespaces. The root directories of projects represent the global namespace. Directories within the root directories form the physical namespace hierarchies for projects. Implementations must derive namespace identifiers from directory names as follows: strip the file system path relative to the current directory and replace all lexically invalid identifier characters with hyphens. For example, given the source file `./Frost Test/Shaping.xs`, implementations will determine that `Shaping.xs` resides within the `Frost-Test` namespace.

> We chose to use directories as namespaces to guarantee consistency between the physical and logical structures of Xenos programs. This consistency eases navigation and understanding when viewing source files through version control systems. This approach also makes it impossible to pollute the global namespace, which we reserve for specification and implementation use only. 

