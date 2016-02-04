# Chopin

Generate a static web site from a series of EEX templates and Markdown files.

## Installation

## How to use

    chopin <source-directory> <destination-directory>

There are five rules to determine what Chopin does with each file in the source directory:
1. A file beginning with `.` is ignored.
2. A file named `layout.eex` is used as a template for sibling and child directories.
3. Any `.eex` or `.md` file is parsed and rendered inside the closest `layout.eex` template, within `<%= yield %>`.
4. A directory is copied over to the destination, then its contents are parsed recursively.
5. Any other file is copied over as-is.
