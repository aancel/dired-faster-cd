# `dired-faster-cd`

## Description

`dired-fasted-cd` is an elisp package allowing the use of fast navigation commands, like z or z.lua from within emacs.    
It was only tested with z.lua, but should work with any jumper application provided that they provide:
- A shell-command to add (or update) a browsed directory
- A shell-command to query the list of already browsed directories

## Installation

- Via quelpa (or other package managers that handle github urls) or load-path

- Example using use-package, quelpa and z.lua:

``` emacs-lisp
(use-package dired-faster-cd
    :after dired
    :quelpa (dired-faster-cd :fetcher url :url "https://github.com/aancel/dired-faster-cd")
    :custom
        ;; Setup the command used to update the jumper application with a new directory entry
        (dired-faster-cd-command-add "/usr/bin/lua ~/git/z.lua/z.lua --add")
        ;; Setup the command used to query the paths recorded by the jumper application for parsing
        (dired-faster-cd-command-query "/usr/bin/lua ~/git/z.lua/z.lua -l  | tr -s \" \" | cut -d\" \" -f2")
    :config
        ;; Setup an advice on `find-alternate-file` to update the jumper application
        ;; when browsing with this function (and dired)
        (dired-faster-cd-setup-advice 'find-alternate-file t)
)
```

## Usage

- Once configured, each time you will used the function setup in `dired-faster-cd-setup-advice`, an update will be
triggered on the jumper application side to increase the weight of a directory.
- You can then use the `dired-faster-cd` interactive function to jump to a directory.
This function currently uses ivy to parse the frequently browsed directories.
