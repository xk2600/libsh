# chomp

This function returns the left-most (or right-most) match from the string, modifying
the original variable to include whats left.

## model behavior

```sh
printf '\n %-6s %6s\n%7s %6s\n\n'   ${B%%[X]*}  ${B#[^X]*}       ${B%[^X]*} ${B##*[X]}
```

###### results in

> a      XbXcXd
> aXbXcX      d

## Implementation

```sh
chomp() {
  # local PATTERN
  # global PIEVAR
  # global BITVAR

  local USAGE='usage: chomp -ir match pievar bitvar'

  local LBIT='$BITVAR=${$BITVAR%%[$PATTERN]*}'
  local LPIE='$PIEVAR=${$PIEVAR#[^$PATTERN]*}'
  local RBIT='$BITVAR=${$BITVAR##*[$PATTERN]}'
  local RPIE='$PIEVAR=${$PIEVAR%*[^$PATTERN]}'

  EXCLUSIVE=true
  LTOR=true
  while getopts 'ir' OPT; do
    case $OPT in
#     (i)   EXCLUSIVE=false ;;
      (r)   LTOR=false ;;
    esac
  done

  shift "$OPTIND"
  PATTERN=$1
  ARGNAME=$2
  ARGRESULT=$3
  shift 3

  # ASSERT: NO ARGS SHOULD BE LEFT!
  [ ! $# -gt 0 ] && echo too many args - $USAGE && return 1

  if $EXCLUSIVE; then
    if $LTOR ; then
      eval `printf '%s ; %s' $LBIT $LPIE` && printf 'BITE: %s PIE: %s' $LBIT $LPIE
    else
      eval `printf '%s ; %s' $RBIT $RPIE` && printf 'BITE: %s PIE: %s' $RBIT $RPIE
    fi
  else
    echo unimplemented
  fi
}
```

## Reference

