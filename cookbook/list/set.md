
# set

## indirection notes

Areas where shell is defficient (short of the use of eval):

 - `VARNAME=value`--requires *VARNAME* to be a known value prior to script execution, 
   resulting in a user provided variable name **CAN NOT** be assigned a value.
   
   This is only a minor shortcoming as nearly all modern shells support `setvar`, 
   though posix does not require or include this functioanlity.
   
 - There exists no way to expand a user provided variable name into it's value.
 
 - Distinguishing separate elements of a command line is tedious:
   
   - A command is all characters from the beginning of the line to the end of the 
     line.
 
   - Though Field separators (`IFS`) can be leveraged, but it may be difficult
     to keep track of and require a FORKING SUBSHELL in order to provide general
     user comfort.
     
   - Simulation of higher-level structures are shoddy at best due to the lack of
     hash tables, arrays, lists, etc.
     
Most of these defficiencies stem from the ideology that shell varaibles are there to
assist the script writer in creation of command lines, not to provide containment,
context, and organization of data.

Solution

The simple solution most high-level scripting languages have taken is one of two
options: 

1. **Command lists**--where a command is organized into a list of elements which
   when evaluated are joined into the final command post resolution as follows:
   
   - The 
   
   list_set CMDLINE `function` ARGV
   
   ... or ...
   
   list_set CMDLINE `/path/to/executable` ARGV
   
   ... or ...
   
   list_set CMDLINE `[builtin]` ARGV
   
   > **`NOTE`** the following special-exec fleshes out the process such that when
   > executed all of the components in the array are 
   
   `special-exec` list_expand $CMDLINE
   
1. **structure/object**--where a command is broken into the path, command, an 
   array of arguments, file descriptors, etc

###### NOT YET IMPLEMENTED

## __set_shopt --

This allows processing of `sh`'s set options so set and setvar can consolidate to
a single command `set`.

In actuality, this probably shouldn't be used, and instead we should opt for a
`safe-intereter`. In the interim this allows the the ability to retain use of the
builtin `set` in the current shell.

```sh
__set_shopt() {
  # PROCESS ENVIRONMENT OPTIONS
  while [ $# -gt 0 ] ; do
    case "$1" in
         ([-+]o)   SHOPTS="$SHOPTS $1 $2" ; shift 2         ;; # long options
         ([-+]?)   SHOPTS="$SHOPTS $1"    ; shift           ;; # short options
         (--)      SHOPTS="$SHOPTS" "$@"    shift   ; break ;; # positional parameters
         (-)       
         (*)       ARGS="$*"                      break ;; # 
    esac
  done
         
  command set -- $ARGS
  command set "$@"
}
```
## set --

wrapper for setvar that allows for `safe` indirection and setting of
a variable post expansion of it's name.

#### Example

```sh
$ set VARNAME          ;# variable VARNAME is not instanciated
can't read "VARNAME": no such variable
$ set VARNAME myvar    ;# set variable VARNAME's value to 'MYVAR'
MYVAR
$ set VARNAME          ;# get variable VARNAME's value
MYVAR
$ set $VARNAME         ;# check indirect variable is not assigned
can't read "MYVAR": no such variable
$ set $VARNAME value   ;# set variable MYVAR's value to 'value' via
value                  ;#   variable name stored in value of VARNAME
$ set $VARNAME         ;# PROOF: MYVAR value indirect set via $VARAME
value
$ set VARNAME          ;# check VARNAME's value
MYVAR
```




```sh
set() {
  local ITER
  local NUMBER
  local DECIMAL
  local OPTS
  local ARGS
        
  if   [ $# -eq 0 ]; then
    printf "%s\n" "$1"
    return $?
  else
    __set_env "$@"
  fi
        elif [ $# -eq 2 ]; 
        case {$1}
        
            NUMBER="${1%%.*}" ; DECIMAL="${1##*.}"
            case "${NUMBER#[-+]}" in
                  ({*})      printf ""
                  (*[!0-9]*) printf "'%s' "  "$1" ;; # string
                  (*)
                    case "${DECIMAL}" in
                          (*[!0-9]*) printf "'%s' " "$1" ;; # string
                          (*)        printf '%s '   "$1" ;; # number
                    esac
                    ;;
            esac
                shift
        ITER=$(( "$ITER" + 1 ))
        done
        return $ITER
}
```
