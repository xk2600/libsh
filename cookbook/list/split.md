# split

splits a string into a list of variables, wrapping them in quotes as required.

## Summary

After initializing our local variables, we test to make sure the number of
arguments (`$#`) is exactly `2` to validate the function was called with
a string and delimiter to process. 

Next we store the contents of the `IFS` (Internal Field Separator) variable, 
in 'OFS'. And change `IFS` to our delimiter.

> While `IFS` is a builtin of the shell, `OFS` could be any variable name, we
> just used `OFS` as an acronym for 'Old Field Separator'. For further detail
> on `IFS`, see [*Special Variables* in **sh(1)**](#reference).

The guts of this function

The variable expansion syntax ${var:+repl} is used here to test 

## Implementation

```sh
split() {
  USAGE="$0: usage: split string delim"

  # argument storage
  local STRING=${1:?${USAGE}}
  local DELIM=${2:?${USAGE}}

  # general local variables
  local LIST
  local ATOM

  # validate inputs
  [ ! $# -eq 2 ] && printf "usage: split string delim" >2 && return 1

  OFS="$IFS"
  IFS="$DELIM"
  for ATOM in ${STRING}; do 
    LIST="${LIST:+${LIST} }\"${ATOM}\""
  done
  IFS=$OFS
  printf "$LIST\n"
}
```

## Example

```sh
split 'a:b:c:d:e:f' :
```

###### Results

```
"a" "b" "c" "d" "e" "f"
```

## Reference

1. `IFS`, *Special Variables* section in **sh(1)** -- `/usr/bin/man 1 sh`
