# Eval

This is a curated reference of information related to `eval` in posix compatible shells, mostly focused on Bash. 

## Summary

The penultimate question of 'Why and when should `eval` use be avoided in shell scripts?' is broke down into the following questions of which a large swath of answers have accumulated in the nethers of the interwebs.

> What is `eval`?
  
 1. The command `eval` a builtin in most interpreters (shells included), allows parsing a command-line twice. [1](#reference)
  
 2. In POSIX it is listed as part of "2.14. Special Built-In Utilities" at 
    the entry "eval". Where builtin means:
    
    > The term "built-in" implies that the shell can execute the utility 
    directly and does not need to search for it. [2](#reference)

> What does `eval` do?

 1. Parses an input line twice.

> How does it do this?

Command-line processing from POSIX section 2.1 [ [3](#reference) ]

    1. The shell reads its input ....
    2. The shell breaks the input into tokens: words and operators
    3. The shell parses the input into simple and compound commands.
    4. The shell performs various expansions (separately) ...
    5. The shell performs redirection and removes redirection operators 
       and their operands from the parameter list.
    6. The shell executes a function, built-in, executable file, or script ...
    7. The shell optionally waits for the command to complete and collects the exit status.

At step 6 a built-in will be executed. At step 6 `eval` causes the processed 
line to be sent back to step 1. It is the only condition under which the 
execution sequence goes back. 

> Why is using `eval` a bad idea?

 1. When the arguments to `eval` are properly quoted (two levels) and the 
    values of variables expanded by `eval` in first parsing would not become 
    executed commands in the second parsing. [1](#reference)

> When would it be appropriate to use?

 1. Never, *if* possible. By most measure, nearly all uses of eval have
    alternatives. However, should you find yourself in need of `eval`,
    first do your best to find an alternative and then only when all
    options have been exausted use the following steps to validate behavior: 
    [1](#reference)
       
    1. Check that *(the eval of)* what you *wrote* is what you *expect* by
       replacing `eval` by `echo`
    
    2. Pontificate over  which variables are locally set and what values 
       they may have. Sanitize any input from userland. 

> Are there any guidelines by which it can be used with complete and total
  safety, or is it always and inevitably a security hole?

 1. There are some conditions in which it could be used in complete and 
    total safety, **yes**. But it is ***ALWAYS*** a risk (like it is a risk
    to write an incorrect script). It just happens that `eval` raises the 
    risk exponentially. [1](#reference)


## Effects of parsing twice

 1. First and most important effect to understand, is that one consequence 
    of the first time a line is subject to the seven shell steps shown 
    above, is quoting. Inside step 4 (expansions), there is also a sequence 
    of steps to perform all expansions, the last of which is Quote Removal:

    > Quote removal shall always be performed last.

    So, always, there is one level of quoting removed.
    
 2. Second, as consequence of that first effect, additional/different parts
    of the line become exposed to the shell parsing and all the other steps.

## Problem in Detail

`eval` is not *more* or *less* dangerous than any other command (ex: 
`rm -rf /`) in principle. It will be executed with the present user 
permissions, so think twice before using it while being root. But that 
is also true of the `rm` command shown above. For a limited user `rm` 
will fail on most directories owned by root. But `rm` is still a 
***dangerous*** command.

## Safe executions of `eval`

The command `eval` is very useful (and perfectly safe) in known idioms.

### Indirect variable expansion

Indirect variable expansion provides a mechanism functionally similar to
utilization of pointers in system languages. It allows the creator the
ability to pass the name of a variable to expand as opposed to directly
expanding a variable. In programming this is often referred to as 
`pass by reference`.

##### Return the last positional argument

As a very handy and common example, the following expression prints the 
value of the last positional argument:

```sh
$ set -- "ls -l" "*" "c;date"
$ eval echo \"\$\{$#\}\"          ### command under test
c;date
```

The command is un-conditionally safe (as it is) because the only 
possible result from `$#` is a number. And the only possible result 
of `$n` (with `n` being a number) is the contents of such positional 
variable.

If you want to see what the command does, replace `eval` with `echo`:

```sh
$ set -- "ls -l" "*" "c; date"
$ echo echo \"\$\{$#\}\"          ### command under test
echo "${3}"
```

And `echo ${3}` is very common (and safe) idiom.

We can still change some of the quoting and get the same result:

```sh
$ echo echo '"${'$#\}\"
echo "${3}"

$ eval echo '"${'$#\}\"
c;date
```

### Pass by reference on POSIX

The following code demonstrates how to correctly pass a scalar variable name into a function by reference for the purpose of "returning" a value: 

```sh
f() {
    # Code goes here that eventually sets the variable "x"
    ${1:+:} return 1
    eval "${1}=\$x"
}
```

## Unsafe uses of `eval`

### Attack Vector 1: Quoting (or the lack therof)

> **ALWAYS** wrap variables with "double" or 'single' quotes. It takes
> very little effort to take advantage of a script that includes raw
> variable expansion in a command-line.

Wow! So Indirection is quite amazing. We can make our scripts far more
dynamic. One might even say this tromps into metaprogramming territory.
So lets expand our example to see where this gets awkward and dangerous.

```sh
$ b=book
$ book="A Tale of Two Cities"
$ eval 'a=$'"$b"               ### safe for SOME values of $b.
$ echo "$a"
A Tale of Two Cities
```

And here we find the first (of two) and main problem with `eval`:

###### Insufficient Quoting

```sh
$ b='book;date'
$ eval 'a=$'"$b"               ### safe for SOME values of $b.
Fri Apr 22 22:03:09 UTC 2016
```

The command date got executed (which we didn't intend to).

So now for this example, this should not execute date (or so I thought...
thanks @Wildcard). A correct solution to this command is to sanitize the 
input, but I will delay talking about this until the second problem with 
`eval` has been defined.

```sh
$ eval 'a="$'"$b"\"
$ echo "$a"
A Tale of Two Cities;date
```

Lets validate the result. Replace `eval` by `echo` and evaluate if the 
printed command-line is safe. Compare the insecure and secure command:

```sh
$ echo 'a=$'"$b"
a=$book;date
$ echo 'a="$'"$b"\"
a="$book;date"
```

The double quotes intend to keep the string as an string and preventing 
conversion to a command executed by the shell. It may be easier to 
understand the logic of quoting as we place "external quotes" and 
"internal quotes" (spaces added for legibility):

```
$ echo a\=\"\$    "$b"   \"
          ||      |  |   ||
          |'------|--|---|+-{ internal quotes }
          |       |  |   |
          '-------|--|---+--{ escape quotes to retain quotes in
                  |  |        first round of parsing/variable expansion. }
                  |  |
                  '--+------{ external quotes stripped in 1st round of
                              command parsing }
```

The internal quotes are the ones around `$b` which provide the bare minimum protection
against command execution. The external quotes are the quotes which are escaped to
prevent the interpreter from expanding them in the first round of parsing/variable
expansion.

The command without spaces (as should be used):

```sh
$ echo a\=\"\$"$b"\"
a="$book;date"

$ eval a\=\"\$"$b"\"
$ echo "$a"
A Tale of Two Cities;date
```

But even this example was very quickly broken by StackExchange user @Wildcard:

```sh
$ b='";date;:"'
$ eval a\=\"\$"$b"\"
Fri Apr 22 23:25:43 UTC 2016
```

The command executed by eval was thwarted to become malicious, lets use `echo`:

```sh
$ echo a\=\"\$"$b"\"
a="$";date;:""
```

Trying to envision ahead of time what all the possible ways malicous input could
take advantage of eval in a script can be daunting. The results of quoting twice
is ***NEVER*** simple.

### Attack Vector 2: Quote insertion

This is even more convoluted than the first. In some cases we do not want 
the result of the first expansion of parameters of `eval` to remain quoted. In 
many cases we need to execute a command inside a variable.

Or, an attacker (as already shown above), crafts an string that match the quotes
and then places a command outside the quotes. The command will get executed and
(if we are lucky) a bug will be reported.

This poses a much bigger problem as the ability for the attacker to insert quotes
breaks the thin veil of protection alloted by quoting, and leaves the values of 
variables completely open to execution.

In this case, it is imperative that we limit the input from the user to include
only values (or ranges of values) that have been determined prior. Keep in mind,
if a variable value is controlled by some user, we are telling that user:

> Give me any command, I will execute it with my permissions.

That is always a dangerous bet, a sure bug, and as root: a compromised system.

### Sanitizing External Data

Having said all the above, this is perfectly safe:

```sh
#!/bin/bash
a=${1//[^0-9]}       ### Only leave a number (one or many digits) ... BASHISM
eval echo $(( a + 1 ))
```

No matter what an external user place in positional parameter, it will 
become a number, it may be a big number for which `$(( ... ))` will fail, 
but that input will not trigger the execution of any command.

It is now that we can talk about sanitizing variable `b` from the command 
above. The command was:

```sh
$ b='";date;:"'
$ eval a\=\"\$"$b"\"
Sat Apr 23 01:56:30 UTC 2016
```

Because `b` contained several characters that were used to change the line.

```sh
$ echo a\=\"\$"$b"\"
a="$";date;:""
```

Changing to single quotes will not work, some other value of b could match 
them also. We need to "sanitize" `b` by removing (at least) the quotes. We 
could replace `$b` by `${b//\"}`:

```sh
$ eval a\=\"\$"${b//\"}"\"
$ echo "$a"
$;date;:
```

### Robust indirect variable-name sanitization

But we can make it even better by acknowledging that a variable name in 
shell could only have `[0-9a-zA_Z]` and `[_]`(underscores). We can remove 
all others with this:

```sh
$ c="$( LC_COLLATE=C; echo "${b//[^0-9A-Za-z_]}" )"    # BASHISM
```

This will clean the variable `b` to a valid variable name. And then, we 
can add an even more strict check by actually checking that the variable 
name inside `$b` (using the cleaned `c`) exists:

```sh
$ if declare -p "$c" &>/dev/null; then   eval a\=\"\$"$c"\" ; fi
```


### Reference

 1. Why and when should `eval` use be avoided in shell scripts? -- 
    [ [stackexchange](https://unix.stackexchange.com/a/278456) ]

 2. What the `eval` command *is* and how to use it -- 
    [ [stackexchange](https://unix.stackexchange.com/a/250345) ]
    
 3. `eval` command and security issues -- 
    [ [BashFAQ](http://mywiki.wooledge.org/BashFAQ/048) ]
    
 4. Why should `eval` be avoided in Bash, and what should I use instead? --
    [ [stackoverflow](https://stackoverflow.com/questions/17529220/why-should-eval-be-avoided-in-bash-and-what-should-i-use-instead) ]
    
 5. What is the `eval` command in `bash`? --
    [ [stackexchange](https://unix.stackexchange.com/a/250345) ]
   
 6. The Open Group Base Specifications Issue 6 --
    [ [POSIX](http://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html) ]
 
 7. Unix/Linux `bash`: Critical security hole uncovered --
    [ [zdnet](http://www.zdnet.com/article/unixlinux-bash-critical-security-hole-uncovered/) ]
 
 8. Writing Better Shell Scripts - Part 3 (see example with `eval`) --
    [ [innovationsts](http://innovationsts.com/?p=2363) ]
 
 9. Shell Script Security (see example with `eval`) --
    [ [dev apple](https://developer.apple.com/library/mac/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html) ]
