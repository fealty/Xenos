# Xenos

*The Stranger Language*

## Program Structure

### Physical Structure

The layout of source files and dependencies in projects on the native file system forms the physical structure of Xenos programs.

#### Source Files

Source files are UTF-8 text files (without the byte order mark) having the `.xs` file extension. Implementations must emit errors when they encounter byte order marks in source files, non-UTF-8 encoding schemes, or files lacking the `.xs` file extension.