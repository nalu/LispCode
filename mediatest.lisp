
(defun insert-to-repl (file)
  (swank::eval-in-emacs `(slime-media-insert-image
						  (find-image '((:file ,file :type png))) "image")))


(defun image-test2 (filepath)
  (swank:eval-in-emacs
   `(slime-media-insert-image (create-image ,filepath) ,filepath))
)