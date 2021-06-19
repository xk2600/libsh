# heredoc

A compilation of notes and functions around novel ways to use heredocs

# Functions

1. [read_heredoc()](read_heredoc.md) - uses the builtin read to populate a 
   variable with the contents of a heredoc.

# Notes

###### Indented heredoc

The `<<-` redirection strips leading tabs from a heredoc, allowing
indention in a heredoc. Note: tab is denoted '\t' in the example.

> VIM: Within `vim`, insert a real tab (if expandtabs is enabled) with the
> `ctrl`+`shift`+`V` key combination followed by the `TAB` key.

```sh
usage () {
\t# Lines between EOF are each indented with the same number of tabs
\t# Spaces can follow the tabs for in-document indentation
\tcat <<-EOF
\t⟶Hello, this is a cool program.
\t⟶This should get unindented.
\t⟶This code should stay indented:
\t⟶    something() {
\t⟶        echo It works, yo!;
\t⟶    }
\t⟶That's all.
\tEOF
}
```

