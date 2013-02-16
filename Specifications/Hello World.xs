[author: "Fealty"]
[date: "12/17/2012"]
[title: ``speech: Hello World!` in Xenos`]

[section{
	level = one}: `The `speech: Hello World!` Program`]

Our goal in this program is to print the text `speech: Hello World!` to the console. We need to use the console I/O functionality in the core .NET library to accomplish this task. We have to declare our dependencies for the module, so the Xenos compiler can use the proper `method: Console.WriteLine` method. We accomplish this by importing the logical `namespace: System` namespace.

(import{
	type = namespace,
	assembly = "mscorlib.dll"}: System)

The master module of every Xenos program must define the entry point for the application. The Xenos compiler looks for the existence of a private and static function called `emphasize: Main` that returns an integer within the module. We must define this function by calling the `function: def-function` function.

(def-function: private static int Main
	(in-param: list<string> args)
	(get-chunk: "output and return"))

[section: `Breaking Down the Body`]

We call the `method: Console.WriteLine` to output our desired text to the console output stream. Then we return from our function, ending the program.

(def-chunk: "output and return"
	(Console.WriteLine: "Hello World!")
	(return: 0))

[section: `Conclusion`]

You should now understand how to write the classic `speech: Hello World!` program in Xenos.