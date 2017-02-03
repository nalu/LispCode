(ql:quickload :date-calc)
(load "./util.lisp")

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

(defun make-titles2 (day-count)

  (let (day-list r-str)
	  (for (i 0 day-count) 
		(multiple-value-bind (year month day)
			(date-calc:today)
		  (multiple-value-bind (y m  next-day) 
			(date-calc:add-delta-days year month day i);; to next
			;;format padding yyyymmdd
			(push-back day-list (format nil "~4,'0d~2,'0d~2,'0d" y m next-day ))
			;;day
			)
		  )
		);;for

	(for (i 0 day-count)
	  (setq r-str
	  (concatenate 'string
				   r-str
				   (format nil "~a ~a ~a~a"
						   *line-str* (elt day-list i) *line-str* #\newline)
				   
				   )
	  )
	  )
	
	r-str
	  )
  

)