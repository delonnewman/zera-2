; vim: ft=clojure
(module pbnj.core)

; aliases
(define list? isList)
(define map? isMap)
(define vector? isVector)
(define set? isSet)
(define collection? isCollection)
(define seq? isSeq)
(define sequential? isSequential)
(define associative? isAssociative)
(define counted? isCounted)
(define indexed? isIndexed)
(define reduceable? isReduceable)
(define seqable? isSeqable)
(define reversible? isReversible)

(define symbol? isSymbol)
(define keyword? isKeyword)

; js types
(define number? isNumber)
(define string? isString)
(define boolean? isBoolean)
(define nil? isNull)
(define undefined? isUndefined)
(define date? isDate)
(define error? isError)
(define regexp? isRegExp)
(define function? isFunction)
(define object? isObject)
(define arguments? isArguments)
(define element? isElement)
(define map-object mapObject)
(define map-indexed mapIndexed)

; arrays
(define array? isArray)
(define arraylike? isArrayLike)
(define ->array toArray)
(define into-array intoArray)

(define odd? isOdd)
(define even? isEven)

(define subset? isSubset)
(define superset? isSuperset)

(define empty? isEmpty)

; other mori functions
(define has? hasKey)
(define has-key? hasKey)
(define hash-map hashMap)
(define sorted-set sortedSet)
(define get-in getIn)
(define assoc-in assocIn)
(define update-in updateIn)
(define reduce-kv reduceKV)
(define take-while takeWhile)
(define drop-while dropWhile)
(define sort-by sortBy)
(define partition-by partitionBy)
(define group-by groupBy)
(define prim-seq primSeq)
(define ->ws toClj)
(define ->js toJs)

(define + add)
(define - sub)
(define * mult)
(define / div)

(define current-module
  (lambda [] pbnj/MODULE_SCOPE))

(define current-module-name
  (lambda [] (.- pbnj/MODULE_SCOPE (symbol "@@NAME@@"))))

(define-macro define-once [nm value]
  (list 'cond (list 'not (list 'defined? nm)) (list 'define nm value) :else nm))

(define-macro defined-in-module?
  ([nm] (list '.- 'pbnj/MODULE_SCOPE nm))
  ([mod nm]
   (list '.- mod nm)))

(define-macro define-in-module-once [nm value]
  (list 'cond (list 'not (list 'defined-in-module? nm)) (list 'define nm value) :else nm))

(define-macro test [nm &body]
  (do
    (define-in-module-once *tests* {})
    (list 'set! '*tests*
          (list 'assoc '*tests* (keyword (namespace nm) (name nm))
                {:test/name (keyword (namespace nm) (name nm))
                 :test/fn (cons 'lambda (cons [] (concat body [[(keyword (namespace nm) (name nm)) :passed]])))}))))

(define- format-test-results
 (lambda [body]
  (println "body" body)
  (if (list? body)
    (inspect (cons (first body) (map (rest body) eval)))
    (inspect body))))

(define-macro is [body]
  (list 'cond (list 'not body)
        (list 'throw
              (list 'str
                    "FAILURE: "
                    (list 'inspect
                          (list 'if (list 'list? (list 'quote body))
                            (list 'cons (list 'first (list 'quote body)) (list 'map (list 'rest (list 'quote body)) 'eval))
                            (list 'quote body)))
                    " is false"))))

(define-macro is-not [body]
  (list 'is (list 'not body)))

(test literals
  (let [n (generate-nat)]
    (is (= n (read-string (str n)))))
  (is (= -1 (read-string "-1")))
  (is (= -1.14 (read-string "-1.14")))
  (is (= 1.14 (read-string "+1.14")))
  (is (= 1 (read-string "+1")))
  (is (= 3.14159 (read-string "3.14159")))
  (is (= 3000 (read-string "3_000")))
  (is (= "abc" (read-string "\"abc\"")))
  (is (= :a (read-string ":a")))
  (is (= 'b (read-string "'b")))
  (is (= '(1 2 3) (read-string "'(1 2 3)")))
  (is (= [1 2 3] (read-string "[1 2 3]")))
  (is (= {:a 1 :b 2 :c 3} (read-string "{:a 1 :b 2 :c 3}")))
  (is (= 5000 (read-string "5,000")))
  (is (= 5000 (read-string "5_000")))
  (is (= 5 (read-string "5.000"))))

(define-macro comment [&forms] nil)

(test comment
  (is (= nil (comment)))
  (is (= nil (comment asdfasdf asfasdf sfasdfasd asfasdfasd))))

(define-macro let [bindings &body]
  (cond (not (vector? bindings)) (throw "let bindings should be a vector"))
  (cons 'do
        (concat (map (pair bindings)
                     (lambda [pair] (list 'define- (pair 0) (pair 1))))
                body)))

(test let
  (is (= [1 2]
         (let [x 1
               y (+ x 1)]
           (is (= x 1))
           (is (= y 2))
           [x y]))))

(define-macro if
  ([pred conse] (list 'cond pred conse))
  ([pred conse alt] (list 'cond pred conse :else alt))) 

(test if
  (is (= 1 (if true 1)))
  (is (= 1 (if true 1 2)))
  (is (= 2 (if false 1 2)))
  (is (= nil (if false 1)))
  (is (= 2 (if nil 1 2))))

(define-macro if-not
  ([pred conse] (list 'cond (list 'not pred) conse))
  ([pred conse alt] (list 'cond (list 'not pred) conse :else alt)))

(test if-not
  (is (= 1 (if-not false 1)))
  (is (= 1 (if-not false 1 2)))
  (is (= 2 (if-not true 1 2)))
  (is (= nil (if-not true 1)))
  (is (= 1 (if-not nil 1 2))))

(define-macro unless [pred &acts]
  (list 'cond (list 'not pred) (cons 'do acts)))

(test unless
  (is (= 5 (unless false 1 2 3 4 5)))
  (is (= nil (unless true 1 2 3 4 5))))

(define-macro when [pred &acts]
  (list 'cond pred (cons 'do acts)))

(test when
  (is (= 5 (when true 1 2 3 4 5)))
  (is (= nil (when false 1 2 3 4 5))))

(define-macro or
  ([] nil)
  ([a] a)
  ([&forms]
   (let [or* (first forms)]
     (list 'if or* or* (cons 'or (rest forms))))))

(test or
  (is (or true))
  (is (or false true))
  (is (or false false true))
  (is (or false false false true))
  (is-not (or false))
  (is-not (or false false))
  (is-not (or false false false)))

(define-macro and
  ([] true)
  ([a] a)
  ([&forms]
   (let [and* (first forms)]
     (list 'if and* (cons 'and (rest forms)) and*))))

(test and
  (is (and true))
  (is (and true true))
  (is (and true true true))
  (is-not (and false))
  (is-not (and false false))
  (is-not (and false false false))
  (is-not (and false true))
  (is-not (and false true true))
  (is-not (and true true false)))

(define-macro define-function
  [name &forms]
  (list 'define name
        (cons 'lambda forms)))

(test define-function
  (define-function ident [x] x)
  (define-function inc [x] (+ 1 x))
  (is (= 1 (ident 1)))
  (is (= :a (pbnj.core/ident :a)))
  (is (= 4 (inc 3)))
  (is (= 5 (pbnj.core/inc 4))))

(define-macro define-function-
  [name &forms]
  (list 'define- name
        (cons 'lambda forms)))

(test define-function-
  (define-function- ident- [x] x)
  (define-function- inc- [x] (+ 1 x))
  ;(is (= :a (pbnj.core/ident- :a)))
  ;(is (= 5 (pbnj.core/+1- 4)))
  (is (= 1 (ident- 1)))
  (is (= 4 (inc- 3))))

(define-macro not= [&values]
  (list 'not (cons '= values)))

(test not=
  (is (not= 1 2))
  (is (not= :a :b))
  (is (not= 1 :a))
  (is-not (not= 1 1))
  (is-not (not= :a :a))
  (is-not (not= [1 2 3 4] [1 2 3 4])))

(define-function add1 [n] (+ 1 n))
(define-function sub1 [n] (- 1 n))

(define-function join
  [col delim]
  (let [joiner (lambda [s x] (str s delim x))]
    (reduce col joiner)))

(define-function tests [mod] (.- mod *tests*))

(define-function prove [tname]
  (let [ns (namespace tname)
        nm (name tname)
        mod (if ns (eval (symbol ns)) pbnj/MODULE_SCOPE)
        tmap (tests mod)]
    (let [t (get tmap (keyword nm))]
      (unless t
        (let [ts (keys *tests*)]
          (if (empty? ts)
            (throw "no tests found in *tests*")
            (throw (str "could not find test, " (inspect tname) " in *tests*, found: " (inspect ts))))))
      ((:test/fn t)))))

(test prove
  (test passing-test (is (= 1 1)))
  (test failing-test (is (= 0 1)))
  (is (= (prove :passing-test) [:passing-test :passed])))

(define-function collect-tests [module] (vals (eval (symbol (name module) "*tests*"))))

(define-function prove-module [module]
  (into [] (map (map (collect-tests module) :test/name) prove)))

(define-macro do-times
  [bindings &body]
  (if-not (and (vector? bindings) (= (count bindings) 2))
    (throw "bindings should be a vector with two elements"))
  (let [block-nm (gen-sym "do-times")
        act-nm (gen-sym "do-times-act")
        var (bindings 0)
        init (bindings 1)]
    (list 'do
          (list 'define- act-nm (cons 'lambda (cons [var] body)))
          (list 'define- block-nm
                (list 'lambda [var]
                      (list 'if (list '< var init)
                            (list 'do
                                  (list act-nm var)
                                  (list block-nm (list '+ 1 var))))))
          (list block-nm 0)
          init)))

(define-macro do-each
  [bindings &body]
  (if-not (and (vector? bindings) (= (count bindings) 2))
    (throw "bindings should be a vector with two elements"))
  (let [block-nm (gen-sym "do-each")
        act-nm (gen-sym "do-each-act")
        col-nm (gen-sym "col")
        var (bindings 0)
        col (bindings 1)]
    (list 'do
          (list 'if-not (list 'collection? col) (list 'throw "bound value isn't a collection"))
          (list 'define- act-nm (cons 'lambda (cons [var] body)))
          (list 'define- block-nm
                (list 'lambda [col-nm]
                      (list 'unless (list 'empty? col-nm)
                            (list act-nm (list 'first col-nm))
                            (list block-nm (list 'rest col-nm)))))
          (list block-nm col)
          col)))

(define-function fraction [n]
  (- n (. js/Math floor n)))

(define-function sign [n]
  (if (number? n) (. js/Math sign n) 0))

(define-function positive? [n]
  (= n (. js/Math abs n)))

(define-function negative? [n]
  (not= n (. js/Math abs n)))

(define-function integer? [n] (= 0 (fraction n)))

(define-function natural? [n]
  (and (integer? n) (positive? n)))

(test natural?
  (is (natural? 0))
  (is (natural? 1))
  (is (natural? 34))
  (is (natural? 21412412341234123463456435437456))
  (is-not (natural? -1))
  (is-not (natrual? 1.1)))

(define-function generate-int
  ([] (generate-int -100 100))
  ([min max]
   (let [a (. js/Math ceil min)
         b (. js/Math ceil max)]
     (+ a (. js/Math floor (* (. js/Math random) (- b a)))))))

(test generate-int
  (do-times [n 100]
    (is (integer? (generate-int)))))

(define-function generate-nat
  ([] (generate-int 0 100))
  ([min max]
   (let [a (. js/Math abs min)]
    (if (> a max) (throw "The absolute value of min should be less than max"))
    (generate-int a max))))

(test generate-nat
  (do-times [n 20]
    (let [m (generate-nat)]
      (is (natural? (generate-nat))))))

(define-function generate-float
  ([] (generate-float 0 100))
  ([min max]
   (+ (generate-int min max) (* (. js/Math random (- max min))))))

(test generate-float
  (do-times [n 20]
    (is (number? (generate-float)))))

(define-function generate-str
  ([] (generate-str 1 20))
  ([min max]
   (let [n (generate-nat min max)
         xs (take n (iterate (partial generate-nat 0x20 0x4000) (generate-nat 0x20 0x4000)))]
     (apply-method js/String (.- js/String fromCodePoint) xs))))

(test generate-string
  (do-times [n 20]
    (is (string? (generate-string)))))

(define-function generate-keyword
  ([] (generate-keyword 1 20))
  ([min max]
   (let [ns? (> (generate-int 0 2) 0)
         nm (generate-str min max)
         ns (generate-str min max)]
     (if ns?
      (keyword ns nm)
      (keyword nm)))))

(test generate-keyword
  (do-times [n 20]
    (is (keyword? (generate-keyword)))))

(define-function generate-symbol
  ([] (generate-keyword 1 20))
  ([min max]
   (let [ns? (> (generate-int 0 2) 0)
         nm (generate-str min max)
         ns (generate-str min max)]
     (if ns?
      (symbol ns nm)
      (symbol nm)))))

(test generate-symbol
  (do-times [n 20]
    (is (symbol? (generate-symbol)))))

(define-function maybe
  ([value just]
   (maybe value just nil))
  ([value just none]
   (if (nil? value) none (just value))))

(define-function either
  ([value left]
   (if (nil? value) (left) nil))
  ([value left right]
   (if (nil? value) (left) (right value))))

(require "src/pbnj/jess.ws")
(require "src/pbnj/wonderscript/compiler.ws")

(define *sym-count* 0)
(define-function gen-sym 
  ([] (gen-sym "sym"))
  ([prefix]
   (let [sym (symbol (str prefix "-" *sym-count*))]
     (set! *sym-count* (+ 1 *sym-count*))
     sym)))

(test gen-sym
  (is (symbol? (gen-sym)))
  (is (symbol? (gen-sym "prefix")))
  (is-not (= (gen-sym) (gen-sym)))
  (is-not (= (gen-sym "prefix") (gen-sym "prefix"))))

(define-macro .?
  ([obj method]
   (list '.? obj method nil))
  ([obj method alt]
   (if (list? method)
     (list 'if (list '.- obj (first method)) (list '. obj method) alt)
     (list 'if (list '.- obj method) (list '. obj method) alt))))

(test .?
  (let [d (new js/Date 2016 10 25)]
    (is (= (.? d getMonth) 10))
    (is (= (.? d missing-method) nil))
    (.? d (setMonth 11))
    (is (= (.? d (getMonth)) 11))))

(define-macro ..
  ([x form] (list '. x form))
  ([x form &more] (cons '.. (cons (list '. x form) more))))

(test ..
  (let [xs (array 1 2 3 4 5)]
    (.. "1,2,3,4,5"
        (split ",")
        (map (lambda [x &rest] (* 1 x)))
        (forEach (lambda [x i other] (is (= x (.- xs i))))))))

(define-macro ..?
  ([x form] (list '.? x form))
  ([x form &more] (cons '..? (cons (list '.? x form) more))))

(test ..?
  (let [xs (array 1 2 3 4 5)]
    (..? "1,2,3,4,5"
         (split ",")
         (map (lambda [x &rest] (* 1 x)))
         (forEach (lambda [x i other]
                       (println "x" x "xs" xs (str "xs[" i "]") (.- xs i))
                       (is (= x (.- xs i)))))))
  (is (= nil (..? "1,2,3,4,5" (split ",") (missing-method 1 2 3 4 5)))))


(define-macro define-class [nm fields &methods]
  (let [env (pbnj/env)
        klass (symbol nm)
        assigns
        (map-indexed
          (lambda [i f]
                  (list '.-set! 'this (name f) f)) fields)
        ctr (cons 'function (cons nm (cons (apply vector fields) assigns)))
        meths
        (map methods
             (lambda [meth]
                     (let [n (str (first meth))
                           args (first (rest meth))
                           body (rest (rest meth))]
                       (list '.-set! klass (vector "prototype" n)
                             (list 'function
                                   (into (vector) (rest args))
                                   (list 'return
                                         (list '.
                                               (cons 'fn
                                                     (cons
                                                       (if (empty? args) [] [(first args)])
                                                       (map body (lambda [exp] (pbnj.wonderscript/ws->jess exp env)))))
                                               'apply
                                               'this
                                               (list '.
                                                     '[this]
                                                     'concat
                                                     (list 'Array.prototype.slice.call 'arguments)))))))))
        proto (cons (list '.-set! klass "prototype" (hash-map)) meths)
        code (into (list) (reverse (concat (list 'do) (list ctr) proto (list klass))))]
    ;(pprint code)
    ;(pprint (pbnj.jess/compile code))
    (list 'define nm (list 'pbnj.jess/eval (list 'quote code)))))

(test define-class
  (define-class Point
    [x y]
    (toString
      [self]
      (str "(" (.- self x) ", " (.- self y) ")"))
    (distance
      [p1 p2]
      (Math/sqrt (+ (Math/pow (- (.- p2 x) (.- p1 x)) 2) (Math/pow (- (.- p2 y) (.- p1 y)) 2))))) 
  (let [p (new Point 3 4)]
    (is (= 3 (.- p x)))
    (is (= 4 (.- p y)))
    (is (= "(3, 4)", (str p)))
    (is (= "(3, 4)", (. p toString)))))

(comment
(define-macro define-method
  [nm value args &body]
  )

(define-method distance Point [p1 p2]
  (Math/sqrt (+ (Math/pow (- (point-x p2) (point-x p1)) 2) (Math/pow (- (point-y p2) (point-y p1)) 2)))) 

(define-class pbnj.core/PersistentList [h t]
  (first [] this.h)
  (rest [] this.t)
  (isEmpty [] (and (nil? this.h) (nil? this.t))))

(define pbnj.core.PersistentList/EMPTY (new PersistentList nil nil))

(define-function plist
  [&elements]
  (reduce elements
          (lambda [e] ) ))
)