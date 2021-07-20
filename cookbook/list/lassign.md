# assign -- INCOMPLETE

Assigns a variadic number of a list in one variable to variables. 

## Summary

## Implementation

```sh
assign() {
  local VARNAME
  while [ $# -gt 0 ]; do
    
  done
  echo "${ARGS%?}"
}
debug func $LINENO function 'assign() defined.'
```

## Example

```sh
TESTLIST='"a" "b" "c" "d" "e" "f"'
assign TESTLIST VAR1 VAR2 VAR3
printf '  VAR1=%s\n  VAR2=%s\n  VAR3=%s\n  TESTLIST=%s\n' $VAR1 $VAR2 $VAR3 $TESTLIST
```

###### returns

```
  VAR1="a"
  VAR2="b"
  VAR3="c"
  TESTLIST="d" "e" "f"
```

## Reference
