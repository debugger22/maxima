;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 10 -*- ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     The data in this file contains enhancments.                    ;;;;;
;;;                                                                    ;;;;;
;;;  Copyright (c) 1984,1987 by William Schelter,University of Texas   ;;;;;
;;;     All rights reserved                                            ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     (c) Copyright 1980 Massachusetts Institute of Technology         ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "MAXIMA")
(macsyma-module rat3b)

;;	THIS IS THE NEW RATIONAL FUNCTION PACKAGE PART 2.
;;	IT INCLUDES RATIONAL FUNCTIONS ONLY.

(DECLARE-TOP(GENPREFIX A_2)
	 (special $ALGEBRAIC $RATFAC $KEEPFLOAT $FLOAT))

(LOAD-MACSYMA-MACROS RATMAC)

(DEFMVAR $RATWTLVL NIL) 
(DEFMVAR $RATALGDENOM T)  ;If T then denominator is rationalized.

(DEFUN RALGP (R) (OR (PALGP (CAR R)) (PALGP (CDR R))))

(DEFUN PALGP (POLY)
  (COND ((PCOEFP POLY) NIL)
	((ALG POLY) T)
	(T (DO ((P (CDR POLY) (CDDR P))) ((NULL P))
	     (AND (PALGP (CADR P)) (RETURN T))))))




(DEFUN RATDX (E *X*)
 (declare (special *x*))
 (PROG (VARLIST FLAG V* GENVAR *A A TRUNCLIST)
       (DECLARE (SPECIAL V* *A FLAG TRUNCLIST))
       (AND (MEMQ 'TRUNC (CAR E)) (SETQ TRUNCLIST (CADDDR (CDAR E))))
       (COND ((NOT (EQ (CAAR E) (QUOTE MRAT))) (SETQ E (RATF E))))
       (SETQ VARLIST (CADDAR E))
       (SETQ GENVAR (CAR (CDDDAR E)))
       ;; Next cond could be flushed if genvar would shrink with varlist
       (COND ((> (LENGTH GENVAR) (LENGTH VARLIST))
	      ;; Presumably this produces a copy of GENVAR which has the
	      ;; same length as VARLIST.  Why not rplacd?
	      (SETQ GENVAR (MAPCAR #'(LAMBDA (A B) A ;Ignored
					     B)
				   VARLIST GENVAR))))
       (SETQ *X* (FULLRATSIMP *X*))
       (NEWVAR *X*) 
       (SETQ A (MAPCAN #'(LAMBDA (Z)
				 (PROG (FF)
				       (NEWVAR 
					(SETQ FF (FULLRATSIMP (SDIFF Z *X*))))
				       (ORDERPOINTER VARLIST)
				       (RETURN (LIST Z FF)))) VARLIST))
       (SETQ *A (CONS NIL A))
       (MAPC #'(LAMBDA(Z B)
		      (COND ((NULL (OLD-GET *A Z))(PUTPROP B (RZERO) 'DIFF))
			    ((AND(PUTPROP B(CDR (RATF (OLD-GET *A Z))) 'DIFF)
				 (ALIKE1 Z *X*))
			     (SETQ V*  B))
			    (T (SETQ FLAG T)))) VARLIST GENVAR)
       (COND ((AND (SIGNP N (CDR (OLD-GET TRUNCLIST V*)))
		   (CAR (OLD-GET TRUNCLIST V*))) (RETURN 0)))	     
       (AND TRUNCLIST
	    (RETURN (CONS (LIST 'MRAT 'SIMP VARLIST GENVAR TRUNCLIST 'TRUNC)
			  (COND (FLAG (PSDP (CDR E)))
				(T (PSDERIVATIVE (CDR E) V*))))))
       (RETURN (CONS (LIST 'MRAT 'SIMP VARLIST GENVAR)
		     (COND (FLAG (RATDX1 (CADR E) (CDDR E)))
			   (T (RATDERIVATIVE (CDR E) V*)))))))

(DEFUN RATDX1 (U V)
       (RATQUOTIENT (RATDIF (RATTIMES (CONS V 1) (RATDP U) T)
			    (RATTIMES (CONS U 1) (RATDP V) T))
		    (CONS (PEXPT V 2) 1)))

(DEFUN RATDP (P) (COND ((PCOEFP P) (RZERO))
		       ((RZEROP (GET (CAR P) 'DIFF))
			(RATDP1 (CONS (LIST (CAR P) 'FOO 1) 1) (CDR P)))
		       (T (RATDP2 (CONS (LIST (CAR P) 'FOO 1) 1)
				  (GET (CAR P) 'DIFF)
				  (CDR P)))))

(DEFUN RATDP1 (X V)
  (COND ((NULL V) (RZERO))
	((EQN (CAR V) 0) (RATDP (CADR V)))
	(T (RATPLUS (RATTIMES (SUBST (CAR V) 'FOO X) (RATDP (CADR V)) T)
		    (RATDP1 X (CDDR V))))))

(DEFUN RATDP2 (X DX V)
       (COND ((NULL V) (RZERO))
	     ((EQN (CAR V) 0) (RATDP (CADR V)))
	     ((EQN (CAR V) 1)
	      (RATPLUS (RATDP2 X DX (CDDR V))
		       (RATPLUS (RATTIMES DX (CONS (CADR V) 1) T)
				(RATTIMES (SUBST 1 'FOO X)
					  (RATDP (CADR V)) T))))
	     (T (RATPLUS (RATDP2 X DX (CDDR V))
			 (RATPLUS (RATTIMES DX
					    (RATTIMES (SUBST (SUB1 (CAR V))
							     'FOO
							     X)
						      (CONS (PTIMES (CAR V)
								    (CADR V))
							    1)
						      T)
					    T)
				  (RATTIMES (RATDP (CADR V))
					    (SUBST (CAR V) (QUOTE FOO) X)
					    T))))))

(DEFMFUN RATDERIVATIVE (RAT  VAR)
 (LET ((NUM (CAR RAT))
	(DENOM (CDR RAT)))
   (COND ((EQN 1 DENOM) (CONS (PDERIVATIVE NUM VAR) 1))
	 (T (SETQ DENOM (PGCDCOFACTS DENOM (PDERIVATIVE DENOM VAR)))
	    (SETQ NUM (RATREDUCE (PDIFFERENCE (PTIMES (CADR DENOM)
						      (PDERIVATIVE NUM VAR))
					      (PTIMES NUM (CADDR DENOM)))
				 ;RATREDUCE ONLY NEEDS TO BE DONE WITH CONTENT OF GCD WRT VAR.
				  (CAR DENOM)))
	    (COND ((PZEROP (CAR NUM)) NUM)
		  (T (RPLACD NUM (PTIMES (CDR NUM)
					 (PEXPT (CADR DENOM) 2)))))))))

;; (DEFMFUN RATABS (Y)
;;  (COND ((PMINUSP (CAR Y)) (CONS (PMINUS (CAR Y)) (CDR Y)))
;; 	(T Y)))


(DEFMFUN RATDIF (X Y) (RATPLUS X (RATMINUS Y))) 

(DEFMFUN RATFACT (X FN)
  (declare (object fn))
  (COND ((AND $KEEPFLOAT (OR (PFLOATP (CAR X)) (PFLOATP (CDR X)))
	      (SETQ FN 'FLOATFACT) NIL))
	((NOT (EQUAL (CDR X) 1))
	 (NCONC (FUNCALL FN (CAR X)) (FIXMULT (FUNCALL FN (CDR X)) -1)))
	(T (FUNCALL FN (CAR X)))))
	 
(DEFUN FLOATFACT (P)
  (LET (((CONT PRIMP) (PTERMCONT P)))
       (SETQ CONT (MONOM->FACL CONT))
       (COND ((EQUAL PRIMP 1) CONT)
	     (T (APPEND CONT (LIST PRIMP 1))))))

;; (DEFUN RATGCM (X Y)
;;   (CONS (PGCD (CAR X) (CAR Y)) (PLCM (CDR X) (CDR Y))))

(DEFUN RATINVERT (Y)
  (RATALGDENOM
   (COND ((PZEROP (CAR Y)) (ERRRJF "QUOTIENT by ZERO"))
	 ((AND MODULUS (PCOEFP (CAR Y)))
	  (CONS (PCTIMES (CRECIP (CAR Y)) (CDR Y)) 1))
	 ((AND $KEEPFLOAT (FLOATP (CAR Y)))
	  (CONS (PCTIMES (*QUO 1.0 (CAR Y)) (CDR Y)) 1))
	 ((PMINUSP (CAR Y)) (CONS (PMINUS (CDR Y)) (PMINUS (CAR Y))))
	 (T (CONS (CDR Y) (CAR Y))))))

(DEFMFUN RATMINUS (X) (CONS (PMINUS (CAR X)) (CDR X)))
	 
(DEFUN RATALGDENOM (X)
       (COND ((NOT $RATALGDENOM) X)
	     ((PCOEFP (CDR X)) X)
	     ((AND (ALG (CDR X))
		   (LET ((ERRRJFFLAG T))
		     (CATCH 'RATERR
			     (RATTIMES (CONS (CAR X) 1)
				       (RAINV (CDR X)) T)))))
	     (T X)))

(DEFMFUN RATREDUCE (X Y &AUX B)
  (COND ((PZEROP Y) (ERRRJF "QUOTIENT by ZERO"))
	((PZEROP X) (RZERO))
	((EQN Y 1) (CONS X 1))
	((AND $KEEPFLOAT (PCOEFP Y) (OR $FLOAT (FLOATP Y) (PFLOATP X)))
	 (CONS (PCTIMES (QUOTIENT 1.0 Y) X) 1))
	(T (SETQ B (PGCDCOFACTS X Y))
	   (SETQ B (RATALGDENOM (RPLACD (CDR B) (CADDR B))))
	   (COND ((AND MODULUS (PCOEFP (CDR B)))
		  (CONS (PCTIMES (CRECIP (CDR B)) (CAR B)) 1))
		 ((PMINUSP (CDR B))
		  (CONS (PMINUS (CAR B)) (PMINUS (CDR B))))
		 (T B)))))


(DEFUN PTIMES* (P Q)
       (COND ($RATWTLVL (WTPTIMES P Q 0))
	     (T (PTIMES P Q))))

(DEFMFUN RATTIMES (X Y GCDSW)
  (COND ($RATFAC (FACRTIMES X Y GCDSW))
	((AND $ALGEBRAIC GCDSW (RALGP X) (RALGP Y))
	 (let ((w  (RATTIMES X Y NIL)))
	   (RATREDUCE (CAR w) (CDR w))))
	((EQN 1 (CDR X))
	 (COND ((EQN 1 (CDR Y)) (CONS (PTIMES* (CAR X) (CAR Y)) 1))
	       (T (COND (GCDSW (RATTIMES (RATREDUCE (CAR X) (CDR Y))
					 (CONS (CAR Y) 1) NIL))
			(T (CONS (PTIMES* (CAR X) (CAR Y)) (CDR Y)))))))
	((EQN 1 (CDR Y)) (RATTIMES Y X GCDSW))
	(T (COND (GCDSW (RATTIMES (RATREDUCE (CAR X) (CDR Y))
				  (RATREDUCE (CAR Y) (CDR X)) NIL))
		 (T (CONS (PTIMES* (CAR X) (CAR Y))
			  (PTIMES* (CDR X) (CDR Y))))))))
	  
(DEFMFUN RATEXPT (X N)
  (COND ((EQUAL N 0) '(1 . 1))
	((EQUAL N 1) X)
	((MINUSP N) (RATINVERT (RATEXPT X (MINUS N))))
	($RATWTLVL (RATREDUCE (WTPEXPT (CAR X) N) (WTPEXPT (CDR X) N)))
	($ALGEBRAIC (RATREDUCE (PEXPT (CAR X) N) (PEXPT (CDR X) N)))
	(T (CONS (PEXPT (CAR X) N) (PEXPT (CDR X) N)))))

(DEFMFUN RATPLUS (X Y &AUX Q N)
  (COND ($RATFAC (FACRPLUS X Y))
	($RATWTLVL
	 (RATREDUCE
	  (PPLUS (WTPTIMES (CAR X) (CDR Y) 0)
		 (WTPTIMES (CAR Y) (CDR X) 0))
	  (WTPTIMES (CDR X) (CDR Y) 0)))
	((AND $ALGEBRAIC (RALGP X) (RALGP Y))
	 (RATREDUCE
	  (PPLUS (PTIMESCHK (CAR X) (CDR Y))
		 (PTIMESCHK (CAR Y) (CDR X)))
	  (PTIMESCHK (CDR X) (CDR Y))))
	((EQN 1 (CDR X))
	 (COND ((EQN 0 (CAR X)) Y)
	       ((EQN 1 (CDR Y)) (CONS (PPLUS (CAR X) (CAR Y)) 1))
	       (T (CONS (PPLUS (PTIMES (CAR X) (CDR Y)) (CAR Y)) (CDR Y)))))
	((EQN 1 (CDR Y))
	 (COND ((EQN 0 (CAR Y)) X)
	       (T (CONS (PPLUS (PTIMES (CAR Y) (CDR X)) (CAR X)) (CDR X)))))
	(T (SETQ Q (PGCDCOFACTS (CDR X) (CDR Y)))
	   (SETQ N (PPLUS (PTIMES (CAR X)(CADDR Q))
			  (PTIMES (CAR Y)(CADR Q))))
	   (COND ((PZEROP N) (RZERO))
		 ((EQN 1 (CAR Q)) (CONS N (PTIMES (CDR X) (CDR Y))))
		 (T (SETQ N (RATREDUCE N (CAR Q)))
		    (CONS (CAR N) (PTIMES (CDR N)
					  (PTIMES (CADR Q) (CADDR Q)))))))))

(DEFMFUN RATQUOTIENT (X Y) (RATTIMES X (RATINVERT Y) T)) 

;;	THIS IS THE END OF THE NEW RATIONAL FUNCTION PACKAGE PART 2.
;;	IT INCLUDES RATIONAL FUNCTIONS ONLY.
