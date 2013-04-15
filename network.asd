(in-package :asdf)

;; If you don't need drawing you can remove that component and the
;; dependency on s-dot

(defsystem :cl-network
  :description "Basic support for representing, traversing and drawing a network structure."
  :depends-on (:s-dot)
  :components 
  ((:file "package")
   (:file "network" :depends-on ("package"))
   (:file "drawing" :depends-on ("network"))))


