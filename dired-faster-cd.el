;;; dired-faster-cd.el --- A package for jumping to directories using external jump applications

;; Copyright (C) 2019 Alexandre Ancel

;; Author: Alexandre Ancel
;; Maintainer: Alexandre Ancel
;; URL: https://github.com/aancel/dired-faster-cd
;; Created: 01/06/2019
;; Version: 0.1
;; Keywords:
;; Package-Requires:

;; This file is not part of GNU Emacs.

;;; Commentary:
;;
;; This packages allows to integrate jumping command-line applications in dired.

;;; Code:

;; * Requires
(if (not (featurep 'ivy))
    (error "Package ivy not present")
    (require 'ivy)
)

;; * Customization
(defcustom dired-faster-cd-command-add ""
    "Shell command run to update a directory entry in the jumper application.
The directory will be concatenated to the command."
    :group 'dired-faster-cd
    :type 'string)

(defcustom dired-faster-cd-command-query ""
    "Shell command run to query the list of directories recorded by the jumper application."
    :group 'dired-faster-cd
    :type 'string)

(defcustom dired-faster-cd-debug nil
    "Debug mode toggle."
    :group 'dired-faster-cd
    :type 'boolean)

;; * Functions

(defun dired-faster-cd--advice (orig-fun &rest args)
    "Advice set around dired function to update external jumper application.
ORIG-FUN is the dired function be advised.  ARGS are the arguments of the initial dired function call."
    (if dired-faster-cd-debug
        (message "[dfc] intercepted command with arguments: %S" args)
    )
    (let* (
            (path (expand-file-name (nth 0 args)))
            (command (concat dired-faster-cd-command-add " " path))
        )
        (if (file-directory-p path)
            (progn
                (if dired-faster-cd-debug
                    (message "[dfc] updating jump program with: %S" command)
                )
                ;; To add a new entry to the current jumper
                (shell-command command)
            )
        )
    )
    ;; Finally apply the function
    (apply orig-fun args)
)

(defun dired-faster-cd-setup-advice (fun state)
    "Setup advice adding a new directory to the jumper application.
FUN is the function to be advised, e.g. 'find-alternate-file'.
STATE indicate whether the advice must be added (t) or removed (nil)."
    ;; (add-hook 'dired-mode-hook 'my/dired-faster-cd)
    (if (not (= (length dired-faster-cd-command-add) 0))
        (if state
            (advice-add fun :around #'dired-faster-cd--advice)
            (advice-remove fun #'dired-faster-cd--advice)
        )
        (message "[dfc] cannot setup advice, dired-faster-cd-command-add is empty.")
    )
)

(defun dired-faster-cd ()
    "Entry point function parsing the output of the jumper application.
This output is the passed to ivy-read for processing by the user."
    (interactive)
    (if (not (= (length dired-faster-cd-command-query) 0))
        (let*
            ( (faster-cd-output (shell-command-to-string dired-faster-cd-command-query))
                (path (ivy-read "Select path: "
                    (reverse (split-string faster-cd-output))
                    ;; Make sure that the list stay ordered in the initial way
                    ;; So we get the pertinent candidates first
                    :re-builder 'ivy--regex-plus
                )
            ) )
            (if dired-faster-cd-debug
                (message "[dfc] Selecting %S" path)
            )
            (find-alternate-file path)
        )
        (message "[dfc] cannot use cd function, because dired-faster-cd-command-query is empty.")
    )
)

(provide 'dired-faster-cd)
;;; dired-faster-cd ends here
