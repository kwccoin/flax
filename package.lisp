(defpackage :flax.base
  (:use :cl :iterate :losh :flax.quickutils)
  (:export
    :rand
    :with-seed
    :random-or
    :randomly-initialize
    :round-to))

(defpackage :flax.coordinates
  (:use :cl :iterate :losh :flax.base :flax.quickutils)
  (:export
    :coord :x :y
    :radial
    :distance
    :coord+
    :clerp
    :coord-to-cons))

(defpackage :flax.colors
  (:use :cl :iterate :losh :flax.base :flax.quickutils)
  (:export
    :color
    :with-color
    :hsv
    :rgb))

(defpackage :flax.drawing
  (:use :cl :iterate :losh :flax.base :flax.quickutils
    :flax.colors
    :flax.coordinates)
  (:export
    :with-rendering
    :render
    :fade
    :triangle
    :path
    :points
    :rectangle
    :point
    :circle
    :text))


(defpackage :flax.looms.001-triangles
  (:use :cl :iterate :losh :flax.base :flax.quickutils
    :flax.coordinates
    :3d-vectors)
  (:export :loom))

(defpackage :flax.looms.002-wobbly-lines
  (:use :cl :iterate :losh :flax.base :flax.quickutils
    :flax.colors
    :flax.coordinates
    :3d-vectors)
  (:export :loom))

(defpackage :flax.looms.003-basic-l-systems
  (:use :cl :iterate :losh :flax.base :flax.quickutils
    :flax.colors
    :flax.coordinates)
  (:export :loom))

(defpackage :flax.looms.004-turtle-curves
  (:use :cl :iterate :losh :flax.base :flax.quickutils
    :flax.colors
    :flax.coordinates)
  (:export :loom))

(defpackage :flax.looms.005-simple-triangulations
  (:use :cl :iterate :losh :flax.base :flax.quickutils
    :flax.colors
    :flax.coordinates
    :3d-vectors)
  (:export :loom))

(defpackage :flax.looms.006-tracing-lines
  (:use :cl :iterate :losh :flax.base :flax.quickutils
    :flax.colors
    :flax.coordinates)
 (:export :loom))

(defpackage :flax.looms.007-stipple
  (:use :cl :iterate :losh :flax.base :flax.quickutils
    :flax.colors
    :flax.coordinates
    :3d-vectors)
  (:export :loom))


