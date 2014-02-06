

(ql:quickload :alexandria);文字列ライブラリ
(load "./util.lisp")


;;wav manager

(defun fileload (path)
  (with-open-file 
;      (my-stream (format nil "~a.~a" filename extension)
	  (setf data
      (my-stream path
		 :direction :input 
		 :if-exists :supersede ;overwrite
		 :element-type '(unsigned-byte 8)
		 )
	  );set
    (loop for i below (length data) do
;	   (print (aref data i))
	 (write-byte (aref data i) my-stream)
	 )
    
    )
)


(defparameter testbuf nil)
(defparameter read-block-size (- array-total-size-limit 1))
(defstruct (chunk) name  position size)
(defun wav-get-header (path)


  (with-open-file 
	  (s path :direction :input :element-type '(unsigned-byte 8))
 	(let ((buf (make-array (file-length s) :element-type '(unsigned-byte 8)))
		  chunk-map)
;; 	(let ((buf (make-array read-block-size  :element-type '(unsigned-byte 8))))
	  (read-sequence buf s)
	  (format t "~a~%" (subseq buf 0 100))


	  (format t "RIFF:~a~%" (convert-4byte-list-to-str (subseq buf 0 4)))
	  (format t "RIFF-SIZE:~d~%" (convert-4byte-list-to-number (subseq buf 4 8)))
	  (format t "RIFF-TYPE:~a~%" (convert-4byte-list-to-str (subseq buf 8 12)))
	  (format t "CHUNK:~a~%" (convert-4byte-list-to-str (subseq buf 12 16)))
	  (format t "CHUNK-BYTE:~a~%" (convert-4byte-list-to-number (subseq buf 16 20)))
	  (format t "FORMAT-ID:~a~%" (subseq buf 20 22))
	  (format t "FORMAT-ID(pcm-01):~a~%" (subseq buf 20 22))
	  (format t "CHANNEL:~a~%" (subseq buf 22 24))
	  (format t "SAMPLING-RATE:~a~%" (convert-4byte-list-to-number (subseq buf 24 28) ))
	  (format t "DATA-SPEED:~a~%" (convert-4byte-list-to-number (subseq buf 28 32) ))
	  (format t "BLOCK-SIZE:~a~%" (subseq buf 32 34) )
	  (format t "SAMPLE-BIT:~a~%" (subseq buf 34 36) )
	  (format t "CHUNK:~a~%" (convert-4byte-list-to-str (subseq buf 36 40)))
	  (format t "CHUNK-BYTE:~a~%" (convert-4byte-list-to-number (subseq buf 40 44)))
	  (format t "LIST-DATA:~a~%" (convert-4byte-list-to-str (subseq buf 44 102)))
	  (format t "CHUNK:~a~%" (convert-4byte-list-to-str (subseq buf 102 106)))
	  (format t "CHUNK-BYTE:~a~%" (convert-4byte-list-to-number (subseq buf 106 110)))

	  (setq chunk-map (get-chunk-map buf 12))
	  );let
	);open
)

(defun convert-4byte-list-to-number(byte-list)
  (+ (elt byte-list 0)
			(* (elt byte-list 1) (* 256 1))
			(* (elt byte-list 2) (* 256 256))
			(* (elt byte-list 3) (* 256 256 256))
			)
)

(defun convert-4byte-list-to-str(byte-list)
  (concatenate 'string  (map 'list (lambda(x)(code-char x)) byte-list))
)

(defparameter *tag-search-max* 128)
(defun get-chunk-map (buf chunk-start)
  (print (length buf))
  (let ( r-vec chunk-name data-position chunk-size)
	(setf r-vec (new-vec))
	(loop for i below *tag-search-max* do

	   (if (>= chunk-start (length buf))
;; 		   (return-from get-chunk-map r-vec)
			 (return)
		   )
		 
;; 		 (setf chunk-name (map 'list (lambda(x)(code-char x)) (subseq buf chunk-start (+ chunk-start 4))))
;; 		 (setf chunk-name (concatenate 'string chunk-name))
		 (setf chunk-name (convert-4byte-list-to-str (subseq buf chunk-start (+ chunk-start 4))))
		 (setf data-position (+ chunk-start 8))
		 (setf chunk-size (convert-4byte-list-to-number (subseq buf (+ chunk-start 4) (+ chunk-start 8))))

;; 		 (format t "name:~a size:~a~%" chunk-name chunk-size)

		 (vec-push r-vec 
				   (make-chunk 
					:name chunk-name 
					:position data-position 
					:size chunk-size))

		 (setq chunk-start (+ chunk-start chunk-size 8));8, chunk name and size byte
		   );loop


	r-vec
	   );let
  
)


