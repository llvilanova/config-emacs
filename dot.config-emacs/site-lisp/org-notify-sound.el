;;; org-notify-sound.el --- Sound notifications for Org-mode

;; Copyright (C) 2012  Lluís Vilanova

;; Author: Lluís Vilanova <vilanova@ac.upc.edu>
;; Keywords: notification, todo-list, alarm, reminder, pop-up

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Extends `org-notify' with the `-sound' action.

;;; Code:

(require 'simple)

(defvar org-notify-sound-file
  "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
  "File to play.")

(defvar org-notify-sound-player
  "mplayer"
  "Application to use for playing the sound.")

(defun org-notify-action-sound (plist)
  "Play a sound."
  (when (and (file-exists-p org-notify-sound-file)
           (executable-find org-notify-sound-player))
    (start-process "org-notify-sound" nil
                   org-notify-sound-player org-notify-sound-file)))

(provide 'org-notify-sound)
;;; org-notify.el ends here
