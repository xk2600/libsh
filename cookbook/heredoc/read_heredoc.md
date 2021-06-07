# read_heredoc

## Summary

reads a heredoc into a variable maintaining all whitespace

## Implementation

```sh
read_heredoc() {
  # ARG: VARNAME
  VARNAME=$1

  # LOCAL ARGUMENTS
  local LINE
  local LAMBDA

  while IFS="\n" read -r LINE
   do 
    # setvar $VARNAME `printf '\"\${%s}%s\n\"' ${VARNAME} "$LINE"`
    # ^^^ DOESN'T WORK ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    
    # ?
    # eval ${VARNAME}=\$${VARNAME}\${LINE}

    # WORKS
    eval `printf '%s=\"\${%s}%s\n\"' ${VARNAME} ${VARNAME} "${LINE}"`
   done
}
```

## Example

```sh
read_heredoc VAR <<EOF
  ...   some   ...
  ... contents ...
EOF
printf "$VAR\n"
```

###### Results

```
  ...   some   ...
  ... contents ...
```

## Reference

 1. 
