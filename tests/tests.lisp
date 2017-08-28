;;;;  cl-esmtp-client
;;;;
;;;;  Copyright (C) 2017 Thomas Bakketun <thomas.bakketun@copyleft.no>
;;;;
;;;;  This library is free software: you can redistribute it and/or modify
;;;;  it under the terms of the GNU Lesser General Public License as published
;;;;  by the Free Software Foundation, either version 3 of the License, or
;;;;  (at your option) any later version.
;;;;
;;;;  This library is distributed in the hope that it will be useful,
;;;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;;  GNU General Public License for more details.
;;;;
;;;;  You should have received a copy of the GNU General Public License
;;;;  along with this library.  If not, see <http://www.gnu.org/licenses/>.

(in-package #:cl-esmtp-client-tests)


(defun talk-to-smtp-server (&key client mail-from rcpt-to data)
  (esmtp::with-session (client :trace *trace-output*)
    (esmtp::mail-from mail-from)
    (esmtp::rcpt-to rcpt-to)
    (when data
      (esmtp::data-start)
      (esmtp::data-bytes data)
      (esmtp::data-end))))


(defun talk-to-test.smtp.org ()
  (talk-to-smtp-server :client (make-instance 'esmtp::client
                                              :host "test.smtp.org"
                                              :ssl-options '(:verify nil)
                                              :credentials '("user16" "pass16"))
                       :mail-from ""
                       :rcpt-to "bit-bucket"
                       :data (flex:string-to-octets
"From: Me <me@example.com>
To: You <you@example.com>
Subject: Test

Hello World.")))


(defvar *mailtrap.io-credentials*
  ;; All mail sent using these credentials are discarded by mailtrap.io.
  ;; Exposing them is unlikely to allow for any misuse.
  (list "479a48b137b928"
        (lambda () "3d7550496f7a14")))

(defun talk-to-mailtrap.io ()
  (esmtp::with-session ((make-instance 'esmtp::client
                                       :host "smtp.mailtrap.io"
                                       :port 2525
                                       :credentials *mailtrap.io-credentials*)
                        :trace *trace-output*)
    (esmtp::mail-from "me@example.com")
    (esmtp::rcpt-to "you@example.com")
    (esmtp::data '("From: Me <me@example.com>"
                   "To: You <you@example.com>"
                   "Subject: Test"
                   ""
                   "Hello World."))))


(defun talk-to-gmail.com ()
  (esmtp::with-session ((make-instance 'esmtp::client
                                       :host "smtp.gmail.com"
                                       :ssl t)
                        :trace *trace-output*)
    (esmtp::send-command 250 "NOOP")
    (esmtp::send-command 250 "RSET")
    (esmtp::send-command 252 "VRFY postmaster")
    (esmtp::extensions esmtp::*session*)))


(defun run ()
  (talk-to-test.smtp.org)
  (talk-to-mailtrap.io)
  (talk-to-gmail.com))


(defun travis-run ()
  (talk-to-mailtrap.io)
  (talk-to-gmail.com))
