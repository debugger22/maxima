;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 10 -*- ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     The data in this file contains enhancments.                    ;;;;;
;;;                                                                    ;;;;;
;;;  Copyright (c) 1984,1987 by William Schelter,University of Texas   ;;;;;
;;;     All rights reserved                                            ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "MAXIMA")

#-NIL
(declare-top (flonum u m m1 a b ca phi
		 ($am flonum flonum) ($am1 flonum flonum)
		 (phi flonum flonum flonum flonum)
		 ($sn flonum flonum) ($cn flonum flonum) ($dn flonum))
	 (*expr asin))

#-NIL
(declare-top (flonum (*f flonum flonum) (//f flonum flonum) 
		    (_f flonum fixnum) (+f flonum flonum) (-f flonum flonum))
	    (*expr *f //f _f +f -f))


#-(or cl NIL)
(and (not (get '*f 'subr)) 
  	(mapc '(lambda (x) (putprop x '(arith fasl dsk liblsp) 'autoload))
	      '(*f //f _f +f -f)))

#+(or cl nil)
(eval-when (eval compile)
  (defmacro *f (a b) `(*$ ,a ,b))
  (defmacro //f (a b) `(//$ ,a ,b))
  (defmacro +f (a b) `(+$ ,a ,b))
  (defmacro -f (a b) `(-$ ,a ,b))
  (defmacro _f (a b) `(scale-float ,a ,b))
)

; Amplitude for Jacobian Elliptic functions. See A+S 16.4
;(defvar *small-flonum* (expt 10.0 -38))

(defun $am1 (u m1)
       (cond ((or (< m1 0.0) (> m1 1.0)) (MAXIMA-ERROR "Modulus of AM must lie in 0<m<1")))
       (phi u (cond ((= m1 0.0)  *small-flonum* ) (t (sqrt m1))) (sqrt (-$ 1.0 m1)) 1.0))

(defun $am (u m) ($am1 u (-$ 1.0 m)))

(defun phi (u b ca a)
       (cond ((not (> (*f ca a) 1.0e-8)) (*$ a u))
	     (t ((lambda (phi)
			 (*$ 0.5 (+$ phi (asin (*$ ca (sin phi))))))
		 (phi (_f u 1)
		      (sqrt (*$ a b)) 
		      (setq ca (//$ (*$ 0.5 (-$ a b))
				    (setq a (*$ 0.5 (+$ a b)))))
		      a)))))

(defun $sn (u m) (sin ($am u m)))

(defun $cn (u m) (cos ($am u m)))

(defun $dn (u m) (sqrt (-$ 1.0 (*$ m (^$ ($sn u m) 2.0)))))

#-(or cl NIL)
(declare-top (flonum ($elliptk1 flonum) ($elliptk flonum)
		 ($ellipte1 flonum) ($ellipte flonum)))

; ref Abramowitz and Stegun eqs 17.3.34 and 36
(defun $elliptk1 (m1)
       (and (or (not (> m1 0.0)) (> m1 1.0))
	    (MAXIMA-ERROR '|Arg. out of range for ELLIPTK|))
       (+$ (+$ (*$ m1 (+$ (*$ m1 (+$ (*$ m1 (+$ (*f m1 0.01451196212)
						       0.03742563713))
						       0.03590092383))
						       0.09666344259))
						       1.38629436112)
	   (*$ (+$ (*$ m1 (+$ (*$ m1 (+$ (*$ m1 (+$ (*f m1 0.00441787012)
							   0.03328355346))
							   0.06880248576))
							   0.12498593597))
							   0.5)
	       (log (//$ m1)))))

(defun $elliptk (m) ($elliptk1 (-$ 1.0 m)))

#-(or NIL cl)(declare (eval (read)))

#-(or cl nil) (setsyntax '/# 'macro '(lambda () (eval (read)))) ; compile constants

(defun $ellipte1 (m1)
  (and (or (< m1 0.0) (> m1 1.0)) (MAXIMA-ERROR "Arg. out of range for ELLIPTE" m1))
  (+$ (+$ (*$ m1 (+$ (*$ m1 (+$ (*$ m1 (+$ (*f m1 0.01736506451)
					   0.04757383546))
						;this is to make ELLIPTE1(1.0) = %PI/2
						; error = 1/2 lsb approx
				#-(or cl NIL) ;;
				#.(fsc (f1- (lsh 0.06260601220 0)) 0)
;;; the use of fsc in maclisp was ok, but the coefficient stands as is,
;;; so i'm using it for DOE MACSYMA
                                #+(or cl NIL) 0.06260601220))
		     0.44325141463))
	  1.0)
      (*$ (*$ m1 (+$ (*$ m1 (+$ (*$ m1 (+$ (*f m1 0.00526449639)
					   0.04069697526))
				0.09200180037))
		     0.24998368310))
	  (log (cond ((= m1 0.0) 1.0) (t (//$ m1))))))) 

(defun $ellipte (m) ($ellipte1 (-$ 1.0 m)))

;AGM method for ELLIPTK1.  Approx. 4 times longer than above method.
; maybe a bit more accurate.
(comment
(defun $k1 (m)
       (do ((a 1.0 (*$ 0.5 (+$ a b)))
	    (b (cond ((= m 0.0) *small-flonum* ) (t (sqrt m))) (sqrt (*$ a b))))
	   ((not (> a b)) (//$ #-NIL #.(atan 1.0 0.0) #+NIL (atan 1.0 0.0)
			       a)))))

; attempt at incomplete ell fun of first kind.  Srewed by ATAN not taking
;  right branch.  Not clear how to fix.
(comment
(defun $f1 (phi m1)
       (do ((n 0 (f1- n))
	    (a 1.0 (*$ 0.5 (+$ a b)))
	    (b (cond ((= m1 0.0)  *small-flonum* )
		     (t (sqrt m1))) (sqrt (*$ a b))))
	   ((not (> a b)) (_f (//$ phi a) n))
	   (setq phi (+$ phi (atan (*$ (//$ b a) (sin phi))
				   (*$ (//$ b a) (cos phi))))))))

#-(or cl NIL)(declare (eval (read)))

#-(or cl NIL)(setsyntax '/# 'macro nil)  ;clean up
