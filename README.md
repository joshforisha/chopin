# Chopin

Chopin is used to generate a static web site from a series of ERB and Markdown files, allowing full control over directory structure. Static files are simply copied over to the site output.

## Install

    gem install chopin

## How to use

    chopin <source-directory> <destination-directory>

There are five rules to determine what Chopin does with each file in the source directory.

- Any directory/file beginning with "." is ignored by Chopin, and is not copied over to the destination.
- A file named `layout.erb` determines the layout base for the files in the current folder, and should contain a *yield* to output the sibling ERB/Markdown files. A folder that does not contain a `layout.erb` will use its parent folder's layout.
- Any `*.erb` and `*.md` files are parsed and injected into the current context's `layout.erb`, then saved as `*.html` in the same structure.
- A directory itself is copied over to the destination, then its contents are parsed by these same rules.
- Any other file is copied over to the destination in the same structure as it exists.

## Example

### Source directory structure

- about.md
- index.md
- layout.erb
- styles/
    - main.css
- test/
    - sub-one.md
    - sub-two.erb

### Destination directory structure

- about.html
- index.html
- styles/
    - main.css
- test/
    - sub-one.html
    - sub-two.html

Note that all of the `.html` files in this example use the single source `/layout.erb` as their layout file.
