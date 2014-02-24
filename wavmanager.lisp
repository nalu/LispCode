

(ql:quickload :alexandria)
(load "./util.lisp")
(load "./at-accessor.lisp")

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
(defparameter *chunk-map* nil)
(defparameter *enable-crossfade* nil)

(defstruct (wavefile)
  chunk-map
  fmt  
  data
  list
)

(defstruct chunk-fmt
  format-id
  channel
  samplerate
  data-speed
  block-size
  sample-bit
)

(defstruct chunk-data
  wave
)

(defstruct chunk-list
  data
)


(defun wav-get-header (path)


  (with-open-file 
	  (s path :direction :input :element-type '(unsigned-byte 8))
 	(let ((buf (make-array (file-length s) :element-type '(unsigned-byte 8)))
		r-wavefile  )
;; 	(let ((buf (make-array read-block-size  :element-type '(unsigned-byte 8))))
	  (read-sequence buf s)
	  (format t "~a~%" (subseq buf 0 100))
	  (setf testbuf buf)

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

	  (setq *chunk-map* (get-chunk-map buf 12))
	  (setf r-wavefile (make-wavefile :chunk-map *chunk-map* ))
	  (for (i 0 (length @r-wavefile.chunk-map))
	    (let (chunk)
	      (setf chunk (elt @r-wavefile.chunk-map i))
	      (if (equal @chunk.name "fmt ")
		  (setf @r-wavefile.fmt (get-chunk-fmt @chunk.position @chunk.size buf))
		  )
	      (if (equal @chunk.name "data")
		  (setf @r-wavefile.data (get-chunk-data @chunk.position @chunk.size buf))
		  )
	      (if (equal @chunk.name "list")
		  (setf @r-wavefile.list (get-chunk-list @chunk.position @chunk.size buf))
		  )
	      );let
	    );for
	  r-wavefile
	  );let
	);open
)


(defun subseq-size ( buf pos size )
  (subseq buf pos (+ pos size))
)

(defun get-chunk-fmt( start-pos size buf)
  (let (chunk-fmt pos)
    (setf chunk-fmt (make-chunk-fmt))
    (setq pos start-pos)

    (setf @chunk-fmt.format-id (subseq-size buf pos 2 ))
    (+= pos 2)

    (setf @chunk-fmt.channel (subseq-size buf pos 2))
    (+= pos 2)

    (setf @chunk-fmt.samplerate (convert-4byte-list-to-number (subseq-size buf pos 4) ))
    (+= pos 4)

    (setf @chunk-fmt.data-speed (convert-4byte-list-to-number (subseq-size buf pos 4) ))
    (+= pos 4)


    (setf @chunk-fmt.block-size (subseq-size buf pos 2) )
    (+= pos 2)

    (setf @chunk-fmt.sample-bit (subseq-size buf pos 2) )
    (+= pos 2)

    chunk-fmt
    );let

)

(defun get-chunk-data(pos size buf)
)

(defun get-chunk-list(pos size buf)
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
			 (return)
		   )
		 
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

;;タイムストレッチ処理
;;波形データを特定ブロックサイズでずらしながらコピー
;;ブロックが小さすぎると低周波が聞こえなくなる。50msecが良いらしい
;;サンプリングレートの５％ずつちぎって貼り付ける作業。
;;余った50msec未満の断片は消え

;;ブロックサイズの２０％をクロスフェード処理に当てる
;;ブロックＡはブロックサイズの１２０％を取り、ブロックＢの０～２０％を合成
(defun wav-data-timestretch( data samplerate speed )
  (let (r-vec block-size cut-pos offset block-num cut-size
			  block-data cross-block-data cross-block-size)
	(setf r-vec (new-vec))
	(setf block-size (truncate (* samplerate 2 2 0.05 ) 1)) ;sample * 16bit * 2ch * 5%
	(setf offset (truncate (* speed block-size) 1))
	(setf block-num (truncate (length data) offset)) 
	(setf cross-block-data nil)
	(setf cross-block-size (truncate (* block-size 0.2) 1))

	(loop for i below block-num  do
		 (format t "processing timestreatch ~d%~%" (* (/ i block-num) 100.0))
		 (setf cut-pos (* i offset))
		 (setf cut-size block-size)

		 ;;残りデータがブロックサイズに満たない場合はある分だけ貼り付け
		 (if (< (- (length data) cut-pos) block-size)
			 (setf cut-size (- (length data) cut-pos))
			 );

		 ;;ブロックデータを作成
		 (setf block-data (subseq data cut-pos (+ cut-pos cut-size)))
	     

		 ;;クロスフェード用データがある場合はブロックデータと合成
	         (if *enable-crossfade*
		     (cond ((not (equal cross-block-data nil))
			    (setf (subseq block-data 0) 
			    	  (get-crossfade-data cross-block-data (subseq block-data 0 cross-block-size))
			    )
			    ));cond
		     )

		 ;;クロスフェード用データを作成
		 ;;copy last 20%
		 (setf cross-block-data 
			   (subseq block-data 
					   (- block-size cross-block-size) block-size))
		 ;log
;;  		 (format t "block-size: ~d offset:~a block:~d/~d ~d/~d" block-size offset i block-num (+ cut-pos cut-size) (length data) )


 		 (vec-concat r-vec block-data)
		 );loop

	(print "finish process timestretch")
	r-vec
	);let


)

;;create fade data
;;by 5% to create a data
(defun wav-data-fade ( data samplerate in-out fade-msec )
  (let (r-vec block-size cut-pos offset block-num cut-size
			  block-data cross-block-data cross-block-size)
	(setf r-vec (new-vec))
	(setf block-size (truncate (* samplerate 2 2 0.05 ) 1)) ;sample * 16bit * 2ch * 5%
	;; (setf block-num (truncate (/ samplerate block-size)  1)) 
	(setf block-num (* 20 5));SEC 5

	(loop for i below block-num  do
		 (format t "processing fadedata ~d%~%" (* (/ i block-num) 100.0))
		 (setf cut-pos (* i block-size))
		 (setf cut-size block-size)


		 ;;make data
		 (setf block-data (subseq data cut-pos (+ cut-pos cut-size)))

	     ;;start 2 sec silent
	         (cond ((< i 40 )
		     (setf block-data (make-fade-data block-data i 40 'out))

		     ;sin test
			;; (setf block-data (make-sin-wave-data (length block-data) 48000  i 40))
		     ));cond

 		 (vec-concat r-vec block-data)
		 );loop

	(print "finish process timestretch")
	r-vec
	);let


)

(defun make-fade-data (data-array number max in-out )
  (let (r-array gain size)
    (setf r-array (make-array (length data-array)))
    (setf size (length r-array))
    (for (i 0 size)
      (setf (elt r-array i) (elt data-array i))

      ;16bit > 8bit
      (if (<= 128 (elt r-array i)) (-= (elt r-array i) 255))

      ;gain
      (setf gain 0.5)
      (setf gain (/ (+ i (* size number)) (* size max) ));fade
      (if (equal in-out 'out) (setq gain (- 1.0 gain)))
      (setf (elt r-array i) (truncate (* (elt r-array i) gain) 1))

      ;8bit > 16bit
      (if (< (elt r-array i) 0) (setf (elt r-array i) (+ (elt r-array i) 255)))

      ;; (if (<= 128 (elt r-array i)) (setf (elt r-array i) 0))
      )
  ;; (if (< data 0 ) (setf data 0))
    (if (= number 0) (print r-array))
 r-array
 );let
)
(defparameter testd nil)
(defun make-sin-wave-data(size sample number max)
  (let (a f0 r-vec gain)
;    (setf a 0.1)
    (setf a 100)
    (setf f0 500.0)
    (setf r-vec (make-array size))
    (for (n 0 size)
      (setf (elt r-vec n) (* a (sin (/ (* 2.0  pi f0  n) sample))))
      );for

    ;gain
    (setf gain 1.0)
    (for (i 0 size)
      ;; (setf gain (/ (+ i (* size number)) (* size max) ));fade
      (setf (elt r-vec i) (* (elt r-vec i) gain))
      )

    ;float controll
    (for (i 0 size)
      (setf (elt r-vec i) (truncate (elt r-vec i) 1)))
    ;test
    ;; (cond ((= testd 0)
    ;; 	   (setf testd r-vec)
    ;; 	(print r-vec)))
    ;test short
    (for (i 0 size)
      ;; (if (> (elt r-vec i) 0) ( setf (elt r-vec i ) (+ (elt r-vec i) 127))) ;+127 when + nu
      
      ;; (if (< (elt r-vec i) 0) ( setf  (elt r-vec i) (* (elt r-vec i) -1)) );=0 when - num
       ;; (if (< (elt r-vec i) 0) ( setf  (elt r-vec i) (* -1 (elt r-vec i) )) );=0 when - num
      (if (< (elt r-vec i) 0) (setf (elt r-vec i) (+ (elt r-vec i) 255)))
      );for

    (if (= number 0) (print r-vec))
    ;short
    ;; (for (i 0 size)
    ;;   (setf (elt r-vec i) (+ (elt r-vec i) 127)))


    r-vec
    )
)

;;クロスフェード用のデータ列を作成
(defun get-crossfade-data( a-data b-data)

  (let (r-data)
    (setf a-data (mapcar (lambda(x) (- x 128)) (coerce a-data 'list)))
    (setf b-data (mapcar (lambda(x) (- x 128)) (coerce b-data 'list)))
    
    (setf r-data
    	  (mapcar (lambda(x y ratio) 
    		    (+ (* x (- 1.0 ratio))  (* y ratio)))
    		    ;; (+ (* x ratio)  (* y (- 1.0 ratio))))
    		  (coerce a-data 'list) 
    		  (coerce b-data 'list)
    		  (make-ratio-sequence (length b-data))
    		  );map
    	  );setf

    (setf r-data (mapcar (lambda(x)(truncate (+ x 128) 1)) r-data))
    r-data
    );let
)

(defun testa()
  (mapcar (lambda(x y i) (print i)) '(0 0 0 0) '(0 0 0 0) (make-serial-sequence 10))
)

(defun make-serial-sequence(size)
  (coerce (make-serial-array size) 'list)
)

(defun make-serial-array(size)
  (let (r-array) 
    (setq r-array (make-array size))
    (loop for i below size do
	 (setf (elt r-array i) i)
	 );loop
    
    r-array
    );let
)

(defun make-ratio-sequence(size)
  (let (ilist)
    (setf ilist (make-serial-sequence size))
    (mapcar (lambda(i) (* (/ i (- (length ilist) 1)) 1.0)) ilist)
    )
)

;;指定ファイルに対して波形データ部分を書き込み直し、新しい名前で出力;;
(defun wav-data-write (path output-path speed)
  (wav-get-header path)

  (let (write-data)

	(with-open-file 
		(s path :direction :input :element-type '(unsigned-byte 8))
	  (let ((buf (make-array (file-length s) :element-type '(unsigned-byte 8)))
			data-chunk
			data-buf
		  )
		(read-sequence buf s)
		(setf data-chunk (elt *chunk-map* 2))
		(print data-chunk)
		(setf data-buf (subseq buf @data-chunk.position (+ @data-chunk.position @data-chunk.size)))


		(setf data-buf (subseq data-buf 0 (truncate (length data-buf) 10)));大きすぎるので分割

		;; (wav-data-timestretch data-buf 48000 0.8)
		;; (setf write-data (wav-data-timestretch data-buf 48000 speed))

		(setf write-data (wav-data-fade data-buf 48000 'in 1000))

		(fill buf 0 
			  :start @data-chunk.position 
			  :end (+ @data-chunk.position @data-chunk.size))
		(setf (subseq buf @data-chunk.position) write-data )
		(save-file output-path "wav" buf)
		
		);let
	  );open



	);let
)


(defun save-file (filename extension data)
;;   (print "write ~a" filename)
  (with-open-file 
;;      (my-stream (format nil "~a.~a" filename extension))
      (my-stream filename
		 :direction :output 
		 :if-exists :supersede ;overwrite
		 :element-type '(unsigned-byte 8)
		 )
    (loop for i below (length data) do
;	   (print (aref data i))
	 (write-byte (aref data i) my-stream)
	 )
    
    )
)  
