# libsh -- lappend


###### UNIMPLEMENTED

```sh

# 
__bad_varname() {
  local RETURN
  if [ ! $# -eq 1 ] ; then
      printf "%s\n" "list.lappend[$LINENO].__varname: requires a single argument" >&2 
      return 0
  fi
  case ${1:?} in
      (*[!a-zA-Z0-9_]*) 
          printf "malformed variable name: \"%s\"" "$VARNAME" 
          return 0 
          ;;
  esac
  return 1
}

lappend() {
  local VARNAME
  local VARVALUE
  local VALUE
  if [ -z "$VARNAME" ] || __bad_varname "$VARNAME" ; then return 1; fi
  if   [ $# -lt 2 ] ; then
    set "${VARNAME}"        ; # return the contents
    return $?
  elif [ $# -eq 2 ] ; then 
    set VARVALUE `set "$VARNAME"`
    set "$VARNAME" "${VARVALUE} ${VALUE}" ; # return the contents
  fi
}
```
