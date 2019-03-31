(import os)
(import tty)
(import sys)
(import termios)

(import feedparser)

(defn fetch-new [feedurl]
  (setv parsed (.parse feedparser feedurl))
  (for [entry (. parsed entries)]
       (show-title entry)
       (prompt entry)))

(defn show-title [entry]
  (print)
  (print (. entry title))
  (print (. entry link))
)

(defn prompt [entry]
  (print "q: quit, d: details, o: open in browser, any other key: show next")
  (setv cmd (read-char))
  (cond [(= cmd "q") (.exit sys)]
        [(= cmd "d") (do
          (print (. entry description))
          (prompt entry))]
        [(= cmd "o") (.system os (+ "open " (. entry link)))]))

(defn read-char []
  (setv ttyno (.fileno (. sys stdin)))
  (setv prev-set (.tcgetattr termios ttyno))
  (.setraw tty ttyno)
  (setv input (.read (. sys stdin) 1))
  (.tcsetattr termios ttyno (. termios TCSADRAIN) prev-set)
  (return input))

(setv feeds
  (with [f (open ((. os path expanduser) "~/.subscriptions"))]
        (lfor line (.readlines f) (.strip line))))

(for [feed feeds]
     (if-not (= (first feed) "#")
       (fetch-new feed)))

