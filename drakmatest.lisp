(ql:quickload :drakma)



(defun get-test()
  (let (get-str)
    (setq get-str (drakma:http-request "http://www.yahoo.co.jp/") )
    (save-file "get-test.txt" get-str)
    )
)


(defun save-file( filename save-str )
  
  (with-open-file 
      (my-stream filename
		 :direction :output 
		 :if-exists :supersede ;overwrite
		 )
;    (print save-str)
    (format my-stream  save-str)
    
    )
)

