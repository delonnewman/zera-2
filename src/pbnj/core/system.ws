; vim: ft=clojure
(module pbnj.core.system)

(define Promise
  (for-platform
    :nodejs (js.node/require "bluebird")
    :browser js/Promise))

(define-macro promise
  [binds &forms]
  (cons 'Promise. (cons 'lambda (cons binds forms))))

(define-macro >>
  [x &forms]
  (cons '..
    (cons x
          (map
            (lambda [form] (list 'then (list 'lambda '[x] (list form 'x))))
            forms))))

(define-function fulfilled?
  [x]
  (.? x isFulfilled))

(define-function rejected?
  [x]
  (.? x isRejected))

(define-function pending?
  [x]
  (.? x isPending))

(define-function canceled?
  [x]
  (.? x isCanceled?))

(browser?
  (define-function http-get
    [url]
    (promise [success failure]
      (do-to (js/XMLHttpRequest.)
        (.addEventListener "error" failure)
        (.addEventListener "load" success)
        (.open "GET" url)
        (.send nil)))))

(nodejs?

  (define
    {:doc "An alias for process.abort() on Node.js"
     :platforms #{:nodejs}
     :added "1.0"}
    abort process/abort)

  (define 
    {:doc "An alias for process.chdir() on Node.js"
     :arglists '([directory])
     :platforms #{:nodejs}
     :added "1.0"}
    chdir process/chdir)

  (define
    {:doc "An alias for process.cwd() on Node.js"
     :arglists '([])
     :platforms #{:nodejs}
     :added "1.0"}
    cwd process/cwd)

  (define
    {:doc "An alias for process.exit() on Node.js"
     :arglists '([] [code])
     :platforms #{:nodejs}
     :added "1.0"}
    exit process/exit)

  (define- *fs* (js.node/require "fs"))
  (define- read-file (.promisify Promise (.-readFile *fs*)))
  (define- write-file (.promisify Promise (.-readFile *fs*)))

  ;; TODO: Make a browser version of slurp and spit

  (define-function slurp
    "Read entire contents of `file` to a string"
    {:added "1.0"}
    [file &opts]
    (if (= :sync (first opts))
      (.readFileSync *fs* file)
      (>> (read-file file) .toString)))

  (define-function spit
    "Write `data` to `file`. Data can be a String, Buffer, or Uint8Array."
    {:added "1.0"}
    [file data]
    (write-file file data))

  (define- *path* (js.node/require "path"))

  (define
    {:doc "An alias for path.basename() on Node.js"
     :arglists '([path] [path ext])
     :platforms #{:nodejs}
     :added "1.0"}
    basename (.-basename *path*))

  (define
    {:doc "An alias for path.dirname() on Node.js"
     :arglists '([path] [path ext])
     :platforms #{:nodejs}
     :added "1.0"}
    dirname (.-dirname *path*))

  (define
    {:doc "An alias for path.extname() on Node.js"
     :arglists '([path] [path ext])
     :platforms #{:nodejs}
     :added "1.0"}
    extname (.-extname *path*))
)
