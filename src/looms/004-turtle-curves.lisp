(in-package :flax.looms.004-turtle-curves)

;;;; Turtle Graphics ----------------------------------------------------------
(defvar *step* 0.1)
(defvar *angle* 1/4tau)
(defvar *starting-angle* (- 1/4tau))
(defvar *color* nil)

(defstruct turtle
  (x 0.5)
  (y 0.5)
  (angle *starting-angle*)
  (state nil))

(define-with-macro turtle x y angle state)


(defun rot (angle amount)
  (mod (+ angle amount) tau))

(define-modify-macro rotf (amount) rot)


(defgeneric perform-command (turtle command))

(defmethod perform-command (turtle (command (eql 'f)))
  (with-turtle (turtle)
    (list (flax.drawing:path
            (list (coord x y)
                  (progn (perform-command turtle 's)
                         (coord x y)))
            :color *color*))))

(defmethod perform-command (turtle (command (eql 'fl)))
  (perform-command turtle 'f))

(defmethod perform-command (turtle (command (eql 'fr)))
  (perform-command turtle 'f))

(defmethod perform-command (turtle (command (eql 's)))
  (with-turtle (turtle)
    (incf x (* *step* (cos angle)))
    (incf y (* *step* (sin angle))))
  nil)

(defmethod perform-command (turtle (command (eql 'x)))
  nil)

(defmethod perform-command (turtle (command (eql '-)))
  (rotf (turtle-angle turtle) *angle*)
  nil)

(defmethod perform-command (turtle (command (eql '+)))
  (rotf (turtle-angle turtle) (- *angle*))
  nil)

(defmethod perform-command (turtle (command (eql '<)))
  (with-turtle (turtle)
    (push (list x y angle) state))
  nil)

(defmethod perform-command (turtle (command (eql '>)))
  (with-turtle (turtle)
    (when-let ((prev (pop state)))
      (destructuring-bind (ox oy oa) prev
          (setf x ox y oy angle oa))))
  nil)


(defun find-bounds (paths)
  (iterate (for path :in paths)
           (for (p1 p2) = (flax.drawing:points path))
           (maximizing (x p1) :into max-x)
           (maximizing (x p2) :into max-x)
           (maximizing (y p1) :into max-y)
           (maximizing (y p2) :into max-y)
           (minimizing (x p1) :into min-x)
           (minimizing (x p2) :into min-x)
           (minimizing (y p1) :into min-y)
           (minimizing (y p2) :into min-y)
           (finally (return (list min-x min-y max-x max-y)))))

(defun scale (paths)
  (iterate
    ;; (with aspect = 1)
    (with (min-x min-y max-x max-y)  = (find-bounds paths))
    (with factor = (min (/ (- max-x min-x))
                        (/ (- max-y min-y))))
    (with x-padding = (/ (- 1.0 (* factor (- max-x min-x))) 2))
    (with y-padding = (/ (- 1.0 (* factor (- max-y min-y))) 2))
    (for path :in paths)
    (for (p1 p2) = (flax.drawing:points path))
    (zapf
      (x p1) (map-range min-x max-x x-padding (- 1.0 x-padding) %)
      (y p1) (map-range min-y max-y y-padding (- 1.0 y-padding) %)
      (x p2) (map-range min-x max-x x-padding (- 1.0 x-padding) %)
      (y p2) (map-range min-y max-y y-padding (- 1.0 y-padding) %))))

(defun turtle-draw (commands)
  (let ((paths (mapcan (curry #'perform-command (make-turtle)) commands)))
    (scale paths)
    paths))


;;;; L-Systems ----------------------------------------------------------------
(defun expand (word productions)
  (mappend (lambda (letter)
             (ensure-list (or (getf productions letter) letter)))
           word))

(defun run-l-system (axiom productions iterations)
  (iterate
    (repeat iterations)
    (for word :initially axiom :then (expand word productions))
    (finally (return word))))


(defclass* l-system ()
  ((name)
   (axiom)
   (productions)
   (recommended-angle)))

(defun make-l-system (name axiom productions recommended-angle)
  (make-instance 'l-system
    :name name
    :axiom (ensure-list axiom)
    :productions productions
    :recommended-angle recommended-angle))


(defmacro define-l-system (name-and-options axiom &body productions)
  (destructuring-bind (name &key (angle 1/4tau))
      (ensure-list name-and-options)
    `(defparameter ,(symb '* name '*)
       (make-l-system ',name ',axiom ',productions ,angle))))


(define-l-system quadratic-koch-island-a (f - f - f - f)
  f (f - f + f + f f - f - f + f))

(define-l-system quadratic-koch-island-b (f - f - f - f)
  f (f + f f - f f - f - f + f + f f - f - f + f + f f + f f - f))

(define-l-system quadratic-snowflake (- f)
  f (f + f - f - f + f))

(define-l-system islands-and-lakes (f + f + f + f)
  f (f + s - f f + f + f f + f s + f f - s + f f - f - f f - f s - f f f)
  s (s s s s s s))

(define-l-system unnamed-koch-a (f - f - f - f)
  f (f f - f - f - f - f - f + f))

(define-l-system unnamed-koch-b (f - f - f - f)
  f (f f - f - f - f - f f))

(define-l-system unnamed-koch-c (f - f - f - f)
  f (f f - f + f - f - f f))

(define-l-system unnamed-koch-d (f - f - f - f)
  f (f f - f - - f - f))

(define-l-system unnamed-koch-e (f - f - f - f)
  f (f - f f - - f - f))

(define-l-system unnamed-koch-f (f - f - f - f)
  f (f - f + f - f - f))

(define-l-system dragon-curve fl
  fl (fl + fr +)
  fr (- fl - fr))

(define-l-system (sierpinski-gasket :angle (/ tau 6)) fr
  fl (fr + fl + fr)
  fr (fl - fr - fl))

(define-l-system (hexagonal-gosper-curve :angle (/ tau 6)) fl
  fl (fl + fr + + fr - fl - - fl fl - fr +)
  fr (- fl + fr fr + + fr + fl - - fl - fr))


(define-l-system (tree-a :angle (radians 25.7)) f
  f (f < + f > f < - f > f))

(define-l-system (tree-b :angle (radians 20)) f
  f (f < + f > f < - f > < f >))

(define-l-system (tree-c :angle (radians 22.5)) f
  f (f f - < - f + f + f > + < + f - f - f >))

(define-l-system (tree-d :angle (radians 20)) x
  x (f < + x > f < - x > + x)
  f (f f))

(define-l-system (tree-e :angle (radians 25.7)) x
  x (f < + x > < - x > f x)
  f (f f))

(define-l-system (tree-f :angle (radians 22.5)) x
  x (f - < < x > + x > + f < + f x > - x)
  f (f f))



;;;; Mutation -----------------------------------------------------------------
(defun insert (val target n)
  (append (subseq target 0 n)
          (list val)
          (subseq target n)))


(defun mutation-transpose (result)
  (pr 'transposing result)
  (rotatef (elt result (rand (length result)))
           (elt result (rand (length result))))
  (pr '----------> result)
  result)

(defun mutation-insert (result)
  (pr 'inserting result)
  (zapf result (insert (random-elt result #'rand)
                       %
                       (rand (length result))))
  (pr '--------> result)
  result)

(defun mutate-production (result)
  (if (<= (length result) 2)
    result
    (ecase (rand 2)
      (0 (mutation-transpose result))
      (1 (mutation-insert result)))))

(defun mutate-productions (productions)
  (iterate (for (letter production . nil) :on productions :by #'cddr)
           (appending (list letter (mutate-production (copy-list production))))))


;;;; Main ---------------------------------------------------------------------
(defun select-l-system ()
  (random-elt `((,*quadratic-koch-island-a* 2 5)
                (,*quadratic-koch-island-b* 2 4)
                (,*quadratic-snowflake* 3 7)
                (,*islands-and-lakes* 1 4)
                (,*unnamed-koch-a* 3 5)
                (,*unnamed-koch-b* 3 6)
                (,*unnamed-koch-c* 3 6)
                (,*unnamed-koch-d* 2 5)
                (,*unnamed-koch-e* 5 7)
                (,*unnamed-koch-f* 5 7)
                (,*dragon-curve* 7 16)
                (,*sierpinski-gasket* 4 10)
                (,*hexagonal-gosper-curve* 3 6)
                (,*tree-a* 3 7 ,(- 1/4tau))
                (,*tree-b* 3 7 ,(- 1/4tau))
                (,*tree-c* 3 5 ,(- 1/4tau))
                (,*tree-d* 6 7 ,(- 1/4tau))
                (,*tree-e* 6 8 ,(- 1/4tau))
                (,*tree-f* 4 7 ,(- 1/4tau)))
              #'rand))

(defun loom (seed filename filetype width height
             &optional l-system iterations starting-angle)
  (nest
    (with-seed seed)
    (destructuring-bind
        (l-system min-iterations max-iterations &optional starting-angle)
        (if l-system
          (list l-system iterations iterations starting-angle)
          (select-l-system)))
    (let* ((*starting-angle* (or (or starting-angle (rand tau))))
           (bg (hsv (rand 1.0) (rand 1.0) (random-range 0.0 0.2 #'rand)))
           (*color* (hsv (rand 1.0)
                         (random-range 0.5 0.8 #'rand)
                         (random-range 0.9 1.0 #'rand)))
           (iterations (random-range-inclusive min-iterations
                                               max-iterations
                                               #'rand))
           (axiom (l-system-axiom l-system))
           (should-mutate (randomp 0.6 #'rand))
           (mutation-seed (rand (expt 2 31)))
           (productions (-<> l-system
                          l-system-productions
                          (if should-mutate
                            (with-seed mutation-seed
                              (mutate-productions <>))
                            <>)))
           (*angle* (l-system-recommended-angle l-system))))
    (flax.drawing:with-rendering
        (canvas filetype filename width height :background bg))
    (progn (-<> (run-l-system axiom productions iterations)
             (turtle-draw <>)
             (flax.drawing:render canvas <>))
           (list (l-system-name l-system)
                 iterations
                 (if should-mutate mutation-seed nil)))))


;; (time (loom (pr (random (expt 2 31))) "out" :svg 1000 1000))