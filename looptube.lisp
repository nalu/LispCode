(ql:quickload :drakma)
(ql:quickload :yason)
(ql:quickload :split-sequence)
(ql:quickload :cl-ppcre)

(defparameter *user-agent* 0)
(defparameter *youtube-url-test* "http://gdata.youtube.com/feeds/api/videos?vq=abc&alt=json&start-index=1&max-results=7&format=1,6")
(defparameter *youtube-search-query* "http://gdata.youtube.com/feeds/api/videos?vq=~a&alt=json&start-index=~d&max-results=~d&format=1,6&time=~a&orderby=~a")
(defparameter *youtube-url-base* "http://www.youtube.com/watch?v=~a")
(defparameter *useragent*  "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10A5376eW")

(defparameter *youtube-parameter-time-today* "today")
(defparameter *youtube-parameter-orderby-relevance* "relevance")
(defparameter *block-contents-num* 7)

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

    (format my-stream "~a" save-str)
    
    )
)

;ユーザーエージェントをセット
(defun set-user-agent () 
; (drakma:http-request "http://whatsmyuseragent.com/" :user-agent :explorer)
)

;検索クエリ作成
(defun make-search-url (search-ward)
  (format nil *youtube-search-query* search-ward 1 7 "today" "relevance")
)

(defun save-video-first-searched (search-word)
  (let (video-id)
    (setq video-id (search-youtube (make-search-url search-word)))
    (save-video (make-video-url video-id))
    )
)

;サーチ
(defparameter *test-get-str* 0)
(defun search-youtube( search-url )
  (let (get-str get-video get-id get-title)
    (setq get-str (drakma:http-request search-url) )
    ;vectorから文字列に変換
    (setq get-str (flexi-streams:octets-to-string get-str :external-format :utf-8))
    (save-file "get-test.txt" get-str);backup
    ;ハッシュテーブル処理
    (setq *test-get-str* get-str);test
;    (setq *test-get-str* (yason:parse get-str)); test
    (setq get-video (car (gethash "entry" (gethash "feed" (yason:parse get-str)))))
;    (setq get-str (gethash "entry" get-str))
    (setq get-title (gethash "$t" (gethash "title" get-video)))
    (setq get-id (gethash "$t" (gethash "id" get-video)))
    (print get-title)
    (setq get-id (last (split-sequence:split-sequence #\/ get-id)))
    (print get-id)
    
    (elt get-id 0)
    )
;  (print "search")
)

;ビデオリストを表示
(defun show-video-list()
  (print "show-videos")
)

;ビデオIDでurlを取得
(defun make-video-url( video-id )
  (format nil *youtube-url-base* video-id)
)

;ビデオを保存
(defparameter test-videopage 0)
(defparameter test-bootstrap 0)
(defun save-video( video-url )
  (let (get-str bootstrap-str fmt-stream-map1 )
    (setq get-str (drakma:http-request video-url :user-agent *useragent*) )
    (setq test-videopage get-str)
    ;Win環境ではSIMPLE-BASE-STRINGによってエラーが発生していたので変換
	(setq get-str (format nil "~a" get-str)) 
    (save-file "test-video-page.txt" get-str);backup
    (multiple-value-bind (start end) 
	(setq bootstrap-str (ppcre:scan-to-strings (format nil "var bootstrap_data.*?~b" #\newline) get-str))
	(setq test-bootstrap bootstrap-str)
	(setq fmt-stream-map1 (ppcre:scan-to-strings "fmt_stream_map.*?{.*?}" bootstrap-str))
	(setq video-url 
		  (ppcre:scan-to-strings "http.*?\""
		  (ppcre:regex-replace-all "\\"
		  (ppcre:regex-replace-all "\u0026" fmt-stream-map1 "&")
		  "")
		 ))
	(print video-url)
	
;	(ppcre:scan "var bootstrap_data.*?;" get-str)
;      (if (eql start 'nil) (print "bootstrap get error") (print "get bootstrap"))
;       (setq bootstrap-str (subseq get-str start end))
;      (setq test-bootstrap bootstrap-str)
;    )
    (save-file "test-get-bootstrap.txt" bootstrap-str);backup
    ))
) 


(defun test-last()
  (save-video-first-searched "gohan")
)