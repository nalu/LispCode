(QL:QUICKLOAD :Alexandria);文字列ライブラリ


;文字列リストの結合用concatenate
(defun concat-string (list)
  (concat-string-delimita list "")
)

(defun concat-string-delimita (list delimita)
  (if (listp list)
      (with-output-to-string (s)
         (dolist (item list)
           (if (stringp item)
             (format s "~a~a" item delimita))))))
  

;再帰してネストも扱うバージョン
(defun concat-string-deep (list)
  (if (listp list)
      (with-output-to-string (s)
         (dolist (item list)
           (cond
 			 ((stringp item) (format s "~a" item))
 			 ((consp item) (format s "~a" (concat-string-deep item) ));consなら再帰
			 )
))))

;リストの無差別連結
;一度フラットなリストにしてからmapをかけるので型を見て再帰がいらなくなった
(defun concat-list-flat (list delimita)

  (let (r-list)
  ;平坦化
  (setq r-list
		(alexandria:flatten list))
  
  ;デリミタつけ
  (setq r-list
		(loop for (a b) on r-list by #'cdr
		   collect (if (not (eql b nil)) (list a delimita) a)  ))

  ;デリミタ部を平坦化
  (setq r-list
		(alexandria:flatten r-list))

  ;全て文字列化
   (map 'list (lambda (x) (format nil "~a" x)) r-list)

  ;連結
;  (concat-string r-list)
   )
)


;カンマ区切りでリストを文字列にする
;デリミタ受取りたいがめんどうなのでまたこんど
;exsample 
;'(a b c) > "A, B, C"
(defun concat-list-string (list)
	(format nil "~{~A~^, ~}" list)
)



;連番リスト(効率適当。１万くらいから遅い)
(defun slist (start size)
  (let ((r-list (make-sequence 'list size :initial-element start )))
	(loop for i below size do
		 (setf (elt r-list i)  (+ (elt r-list i) i))
	)
	r-list
 )
)

;リストの末尾に追加
(defmacro push-back (lat x) 
 `(setf ,lat (append ,lat (list ,x))))

;リストの先頭を削除
(defun pop-begin (list)
  (cdr list)
)


;;よくあるフォーマット変換
(defun stoi (x)
  (read-from-string x)
)

