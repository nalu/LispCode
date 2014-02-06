

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
(defun wav-get-header (path)


  (with-open-file 
	  (s path :direction :input :element-type '(unsigned-byte 8))
 	(let ((buf (make-array (file-length s) :element-type '(unsigned-byte 8)))
		  )
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

	  (setq *chunk-map* (get-chunk-map buf 12))
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
;;ブロックＡはブロックサイズの１２０％を取り、ブロックＢの０～２０％を合成して埋める
(defun wav-data-timestretch( data samplerate speed )
  (let (r-vec block-size cut-pos offset block-num cut-size
			  block-data cross-block-data cross-block-size)
	(setf r-vec (new-vec))
	(setf block-size (truncate (* samplerate 0.05) 1))
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


		 ;;クロスフェード用データがある場合はブロックデータと合成する
		 (cond ((not (equal cross-block-data nil))
;; 				(setf (subseq block-data 0 cross-block-size) cross-block-data)
				(setf (subseq block-data 0) 
					  (get-crossfade-data cross-block-data (subseq block-data 0 cross-block-size)))
				));cond

		 ;;クロスフェード用データを作成
		 ;;copy last 20%
		 (setf cross-block-data 
			   (subseq block-data 
					   (- (length block-data) cross-block-size) block-size))

		 ;log
;;  		 (format t "block-size: ~d offset:~a block:~d/~d ~d/~d" block-size offset i block-num (+ cut-pos cut-size) (length data) )

 		 (vec-concat r-vec block-data)
		 );loop

	(print "finish process timestretch")
	r-vec
	);let


)

;;クロスフェード用のデータ列を作成する
(defun get-crossfade-data( a-data b-data)
;  (mapcar (lambda(x y) (truncate (+ x y) 2)) (coerce a-data 'list) (coerce b-data 'list))
)

;;指定ファイルに対して波形データ部分を書き込み直し、新しい名前で出力
(defun wav-data-write( path output-path speed)
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

;; 		(wav-data-timestretch data-buf 48000 0.8)
		(setf write-data (wav-data-timestretch data-buf 48000 speed))

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
