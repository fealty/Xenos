// We begin with the metadata for the module. Attributes apply to the next non-attribute s-expression within the block, but if no non-attribute s-expression exists in the block, the attribute applies to the module itself.

[@author: "Fealty"]
[@date: "12/17/2012"]

{section: The Setup}

First, we need to declare our dependencies to enable the compiler to find the {method: Console.WriteLine} method.

(import: System)

Next, we need to define an entry point for our application. We do this by invoking {function: def-function} at compile time. Essentially, we are writing code that generates code. 

// Note: The import-chunk function executes once the s-expression is understood, so the 'import-chunk' function s-expression replaces itself with the s-expressions in the chunk.

(def-function: int main
  (import-chunk: "define parameters")
  (import-chunk: "output and return"))
  
{section: The Chunks}
  
Then we define the single {type: list<T>} of parameters to take in our command line arguments.

(def-chunk: "define parameters"
  (in: list<string> args))
  
Finally, we output the "Hello World" message to the console and return.

(def-chunk: "output and return"
	(Console.WriteLine: "Hello World")
	(return: 0))

{section: Conclusion}

You should now understand how to write "Hello World" in xenos.