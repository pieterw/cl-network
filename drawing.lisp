(in-package :cl-network)

;; Some functionality for drawing of networks with s-dot

;; -------------
;; S-Dot Drawing
;; -------------

(export '(string-for-s-dot draw-dot render-ps render-as render-as-removal
render-as-change get-color))

(defun string-replace (str1 sub1 sub2)
  "Nondestructively replaces all occurences of sub1 in str1 by sub2"
  (let ((str1 (string str1))
        (str2 "")
        (sub1 (string sub1))
        (sub2 (string sub2))
        (index1 0))
    (loop
       if (string-equal str1 sub1
                        :start1 index1
                        :end1 (min (length str1)
                                   (+ index1 (length sub1))))
       do (setq str2 (concatenate 'string str2 sub2))
         (incf index1 (length sub1))
       else do 
         (setq str2 (concatenate 'string str2
                                 (subseq str1 index1 (1+ index1))))
         (incf index1)
       unless (< index1 (length str1))
       return str2)))

(defun mkdotstr (symbol)
  "Dot cannot handle - in strings so it just replaces all - by _"
  (string-replace (format nil "~a" symbol) "-" "_"))

(defun string->file (string file-path)
  (let ((file (open file-path :direction :output :if-exists :supersede)))
    (format file string)
    (close file)))

(defgeneric string-for-s-dot (object &key &allow-other-keys)
  (:documentation "Should return a string that will be used by
  draw-dot"))

(defmethod string-for-s-dot ((object t) &key)
  (mkdotstr object))

(defgeneric draw-dot (node &key &allow-other-keys)
  (:documentation "Draws the given object in dot"))

(defmethod draw-dot ((node net-node) &key)
  `(s-dot::node ((s-dot::id ,(mkdotstr (id node)))
                 (s-dot::label ,(string-for-s-dot node)))))

(defmethod draw-dot ((edge net-edge) &key (include-edge-labels nil) (directed t))
  (let (features)
    (push `(s-dot::from ,(mkdotstr (id (start edge)))) features)
    (push `(s-dot::to ,(mkdotstr (id (end edge)))) features)
    (when include-edge-labels
      (push `(s-dot::label ,(mkdotstr (label edge))) features))
    (unless directed
      (push `(s-dot::dir "none") features))
    `(s-dot::edge ,(nreverse features))))

(defmethod draw-dot ((net network) &key (rankdir "TB") (include-edge-labels nil))
  (let ((draw-dots (loop for prim in (primitives net)
		      collect (draw-dot prim :include-edge-labels include-edge-labels))))
    `(s-dot::graph ((s-dot::rankdir ,rankdir))
                   (s-dot::cluster ((s-dot::id "network")))
                   ,@draw-dots)))
