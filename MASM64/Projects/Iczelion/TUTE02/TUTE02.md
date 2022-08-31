# Tutorial 2: MessageBox

In this tutorial, we will create a fully functional Windows program that displays a message box saying "Win64 assembly is great!".

Download the example file here. 

##  Theory:

Windows prepares a wealth of resources for Windows programs. Central to this is the Windows API (Application Programming Interface). Windows API is a huge collection of very useful functions that reside in Windows itself, ready for use by any Windows programs. These functions are stored in several dynamic-linked libraries (DLLs) such as kernel32.dll, user32.dll and gdi32.dll. Kernel32.dll contains API functions that deal with memory and process management. User32.dll controls the user interface aspects of your program. Gdi32.dll is responsible for graphics operations. Other than "the main three", there are other DLLs that your program can use, provided you have enough information about the desired API functions.

Windows programs dynamically link to these DLLs, ie. the codes of API functions are not included in the Windows program executable file. In order for your program to know where to find the desired API functions at runtime, you have to embed that information into the executable file. The information is in import libraries. You must link your programs with the correct import libraries or they will not be able to locate API functions.

When a Windows program is loaded into memory, Windows reads the information stored in the program. That information includes the names of functions the program uses and the DLLs those functions reside in. When Windows finds such info in the program, it'll load the DLLs and perform function address fixups in the program so the calls will transfer control to the right function.
There are two categoriesof API functions: One for ANSI and the other for Unicode. The names of API functions for ANSI are postfixed with "A", eg. MessageBoxA. Those for Unicode are postfixed with "W" (for Wide Char, I think). Windows 95 natively supports ANSI and Windows NT Unicode.

We are usually familiar with ANSI strings, which are arrays of characters terminated by NULL. ANSI character is 1 byte in size. While ANSI code is sufficient for European languages, it cannot handle several oriental languages which have several thousands of unique characters. That's why UNICODE comes in. A UNICODE character is 2 bytes in size, making it possible to have 65536 unique characters in the strings.

But most of the time, you will use an include file which can determine and select the appropriate API functions for your platform. Just refer to API function names without the postfix.

##  Example:

I'll present the bare program skeleton below. We will flesh it out later.

```
.386
.model flat, stdcall
.data
.code
start:
end start
```

The execution starts from the first instruction immediately below the label specified after `end` directive. In the above skeleton, the execution will start at the first instruction immediately below `start` label. The execution will proceed instruction by instruction until some flow-control instructions such as `jmp`, `jne`, `je`, `ret` etc is found. Those instructions redirect the flow of execution to some other instructions. When the program needs to exit to Windows, it should call an API function, `ExitProcess`.

```
ExitProcess proto uExitCode:DWORD
```

The above line is called a function prototype. A function prototype defines the attributes of a function to the assembler/linker so it can do type-checking for you. The format of a function prototype is like this:

```
FunctionName PROTO [ParameterName]:DataType,[ParameterName]:DataType,...
```

In short, the name of the function followed by the keyword PROTO and then by the list of data types of the parameters,separated by commas. In the ExitProcess example above, it defines ExitProcess as a function which takes only one parameter of type DWORD. Functions prototypes are very useful when you use the high-level call syntax, invoke. You can think of invoke as a simple call with type-checking. For example, if you do:

```
call ExitProcess
```

without pushing a dword onto the stack, the assembler/linker will not be able to catch that error for you. You'll notice it later when your program crashes. But if you use:

```
invoke ExitProcess
```

The linker will inform you that you forgot to push a dword on the stack thus avoiding error. I recommend you use invoke instead of simple call. The syntax of invoke is as follows:

```
INVOKE  expression [,arguments]
```

expression can be the name of a function or it can be a function pointer. The function parameters are separated by commas.

Most of function prototypes for API functions are kept in include files. If you use hutch's MASM32, they will be in MASM32/include folder. The include files have .inc extension and the function prototypes for functions in a DLL is stored in .inc file with the same name as the DLL. For example, ExitProcess is exported by kernel32.lib so the function prototype for ExitProcess is stored in kernel32.inc.
You can also create function prototypes for your own functions.
Throughout my examples, I'll use hutch's windows.inc which you can download from http://win32asm.cjb.net

Now back to ExitProcess, uExitCode parameter is the value you want the program to return to Windows after the program terminates. You can call ExitProcess like this:

```
invoke ExitProcess, 0
```

Put that line immediately below start label, you will get a win32 program which immediately exits to Windows, but it's a valid program nonetheless. 

```
.386
.model flat, stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
.data
.code
start:
        invoke ExitProcess,0
end start
```

`option casemap:none` tells MASM to make labels case-sensitive so ExitProcess and exitprocess are different. Note a new directive, `include`. This directive is followed by the name of a file you want to insert at the place the directive is. In the above example, when MASM processes the line `include \masm32\include\windows.inc`, it will open windows.inc which is in \MASM32\include folder and process the content of windows.inc as if you paste the content of windows.inc there. hutch's windows.inc contains definitions of constants and structures you need in win32 programming. It doesn't contain any function prototype. windows.inc is by no means comprehensive. hutch and I try to put as many constants and structures into it as possible but there are still many left to be included. It'll be constantly updated. Check out hutch's and my homepage for updates.

From windows.inc, your program got constant and structure definitions. Now for function prototypes, you need to include other include files. They are all stored in \masm32\include folder.

In our example above, we call a function exported by kernel32.dll, so we need to include the function prototypes from kernel32.dll. That file is kernel32.inc. If you open it with a text editor, you will see that it's full of function prototypes for kernel32.dll. If you don't include kernel32.inc, you can still call ExitProcess but only with simple call syntax. You won't be able to invoke the function. The point here is that: in order to invoke a function, you have to put its function prototype somewhere in the source code. In the above example, if you don't include kernel32.inc, you can define the function prototype for ExitProcess anywhere in the source code above the invoke command and it will work. The include files are there to save you the work of typing out the prototypes yourself so use them whenever you can.

Now we encounter a new directive, includelib. includelib doesn't work like include. It 's only a way to tell the assembler what import library your program uses. When the assembler sees an includelib directive, it puts a linker command into the object file so that the linker knows what import libraries your program needs to link with. You're not forced to use includelib though. You can specify the names of the import libraries in the command line of the linker but believe me, it's tedious and the command line can hold only 128 characters.

Now save the example under the name msgbox.asm. Assuming that ml.exe is in your path, assemble msgbox.asm with:

`ml  /c  /coff  /Cp msgbox.asm`
* `/c` tells MASM to assemble only. Do not invoke link.exe. Most of the time, you would not want to call link.exe automatically since you may have to perform some other tasks prior to calling link.exe.
* `/coff` tells MASM to create .obj file in COFF format. MASM uses a variation of COFF (Common Object File Format) which is used under Unix as its own object and executable file format.
* `/Cp` tells MASM to preserve case of user identifiers. If you use hutch's MASM32 package, you may put "option casemap:none" at the head of your source code, just below .model directive to achieve the same effect.

After you successfully assemble msgbox.asm, you will get msgbox.obj. msgbox.obj is an object file. An object file is only one step away from an executable file. It contains the instructions/data in binary form. What is lacking is some fixups of addresses by the linker.

Then go on with link: 

`link /SUBSYSTEM:WINDOWS  /LIBPATH:c:\masm32\lib  msgbox.obj`
* `/SUBSYSTEM:WINDOWS`  informs Link what sort of executable this program is
* `/LIBPATH:<path to import library>` tells Link where the import libraries are. If you use MASM32, they will be in MASM32\lib folder.

Link reads in the object file and fixes it with addresses from the import libraries. When the process is finished you get msgbox.exe.

Now you get msgbox.exe. Go on, run it. You'll find that it does nothing. Well, we haven't put anything interesting into it yet. But it's a Windows program nonetheless. And look at its size! In my PC, it is 1,536 bytes.

Next we're going to put in a message box. Its function prototype is: 

`MessageBox PROTO hwnd:DWORD, lpText:DWORD, lpCaption:DWORD, uType:DWORD`
* hwnd is the handle to parent window. You can think of a handle as a number that represents the window you're referrring to. Its value is not important to you. You only remember that it represents the window. When you want to do anything with the window, you must refer to it by its handle.
* lpText is a pointer to the text you want to display in the client area of the message box. A pointer is really an address of something. A pointer to text string==The address of that string.
* lpCaption is a pointer to the caption of the message box
* uType specifies the icon and the number and type of buttons on the message box

Let's modify msgbox.asm to include the message box.

``````
.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

.data
MsgBoxCaption  db "Iczelion Tutorial No.2",0
MsgBoxText       db "Win32 Assembly is Great!",0

.code
start:
invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK
invoke ExitProcess, NULL
end start
```

Assemble and run it. You will see a message box displaying the text "Win32 Assembly is Great!".

Let's look again at the source code.
We define two zero-terminated strings in .data section. Remember that every ANSI string in Windows must be terminated by NULL (0 hexadecimal).
We use two constants, NULL and MB_OK. Those constants are documented in windows.inc. So you can refer to them by name instead of the values. This improves readability of your source code.
The addr operator is used to pass the address of a label to the function. It's valid only in the context of invoke directive. You can't use it to assign the address of a label to a register/variable, for example. You can use offset instead of addr in the above example. However, there are some differences between the two:

1. addr cannot handle forward reference while offset can. For example, if the label is defined somewhere further in the source code than the invoke line, addr will not work.
```
    invoke MessageBox,NULL, addr MsgBoxText,addr MsgBoxCaption,MB_OK
    ......
    MsgBoxCaption  db "Iczelion Tutorial No.2",0
    MsgBoxText       db "Win32 Assembly is Great!",0
```
MASM will report error. If you use offset instead of addr in the above code snippet, MASM will assemble it happily.
2. addr can handle local variables while offset cannot. A local variable is only some reserved space in the stack. You will only know its address during runtime. offset is interpreted during assembly time by the assembler. So it's natural that offset won't work for local variables. addr is able to handle local variables because of the fact that the assembler checks first whether the variable referred to by addr is a global or local one. If it's a global variable, it puts the address of that variable into the object file. In this regard, it works like offset. If it's a local variable, it generates an instruction sequence like this before it actually calls the function:
```
    lea eax, LocalVar
    push eax
```

Since lea can determine the address of a label at runtime, this works fine.