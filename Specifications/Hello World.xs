The master module of a Xenos program should apply document attributes to the module, which are used when generating literature from the source code. Attributes may be applied to a module by specifying the attributes in a block that contains nothing other than attributes.

[author: "Fealty"]
[date: "12/17/2012"]
[title: ``speech: Hello World!` in Xenos`]

Our goal in this program is to print the text `speech: Hello World!` to the console. We need to use the console I/O functionality in the core .NET library to accomplish this task. We have to declare our dependencies for the module, so the Xenos compiler can use the proper `method: Console.WriteLine` method. We accomplish this by importing the logical `namespace: System` namespace.

(import{
	type = ImportTypes.Namespace,
	assembly = "mscorlib.dll"}: System)

Notice that we have specified optional parameters to the `function: import` function. These are shown for illustration purposes only, but within braces every function call may take optional parameters specified in a key-value format delimited by commas, assuming the function or method specifies optional parameters.

The master module of every Xenos program must define the entry point for the application. The Xenos compiler looks for the existence of a private function called `emphasize: main` that returns an integer within the master module. We must define this function by calling the `function: def-function` function.

(defun: private int main
	(defparam: list<string> args)
	(autochunk))

[chunk: `output and return`]

We call the `method: Console.WriteLine` to output our desired text to the console output stream. Then we return from our function, ending the program.

(Console.WriteLine: "Hello World!")
(return: 0)

[section: `Conclusion`]

You should now understand how to write the classic `speech: Hello World!` program in Xenos.