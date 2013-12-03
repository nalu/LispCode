
(defparameter *line-str* "------------------------------------------")
(defun make-titles (year month)
  (let (r-str)
    (loop for i below 31 do
	 (setq r-str
	 (concatenate 'string
		     r-str
		     (format nil "~a ~2,'0d~2,'0d~2,'0d ~a~d" 
			     *line-str* year month (+ i 1) 
			     *line-str* #\newline );format
		     );concat
		     );setq
       );loop

    r-str
    );let
)
