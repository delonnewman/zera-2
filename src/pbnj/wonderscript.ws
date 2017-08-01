; vim ft=clojure

(def mori (require "mori"))
(def _ (require "./src/pbnj/core.js"))

(def global/pbnj (Object.create nil))
(def global.pbnj/wonderscript (Object.create nil))
(def global.pbnj.wonderscript/MACROS (Object.create nil))
(def global.pbnj/core _)

(defmacro do
  []
  (def body (reverse (into (list) (Array.prototype.slice.call arguments 1))))
  (list (cons 'fn (cons [] (cons body)))))

;(def isMacoDef
;  (fn [tag] (= tag (symbol "defmacro"))))
;
;(def evalMacroDef
;  (fn [exp]
;    (def macro (rest exp))
;    (def name (first macro))
;    (def args (second macro))
;    (def body (rest macro))
;    (def code (cons (symbol "fn") (cons args body)))
;    (set! (.- pbnj.wonderscript/MACROS name) (global.eval (emit code)))
;    nil))
;
;(def isFn
;  (fn [tag] (= tag (symbol "fn"))))
;
;(def emitArgumentList
;  (fn [args]
;    (if (empty? args)
;      "()"
;      (str "(" (join "," (map emit args)) ")"))))
;
;(def emitFunctionBody
;  (fn
;    [body]
;    (def stmts (map emit body))
;    (def rest (take (- (count stmts) 1) stmts))
;    (def last (drop (- (count stmts) 1) stmts))
;    (if (empty? rest)
;      (str "return " (first last) ";")
;      (str (join ";" rest) ";return " (first last) ";"))))
;
;(def emitFunction
;  (fn [exp]
;    (def ident (second exp))
;    (str "(function" (emitArgumentList (second exp)) "{" (emitFunctionBody (rest (rest exp))) "})")))
;
;(def emit
;  (fn [exp]
;    (if (nil? exp)
;      "null"
;      (if (boolean? exp)
;        (if exp "true" "false")
;        (if (number? exp)
;          (str exp)
;          (if (string? exp)
;            (str "'" exp "'")
;            (if (symbol? exp)
;              (str exp)
;              (if (list? exp)
;                (if (isFunction (first exp))
;                  (emitFunction exp)
;                  (if (isMacroDef (first exp))
;                    (evalMacroDef exp)))))))))))
;
;(console.log (emit nil))
;(console.log (emit true))
;(console.log (emit false))
;(console.log (emit 1.3))
;(console.log (emit 3.14159))
;(console.log (emit 5))
;(console.log (emit "Testing"))
;(console.log (emit (list (symbol "fn") [(symbol "x")] (symbol "x"))))
