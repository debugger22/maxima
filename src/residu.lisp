;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 10 -*- ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     The data in this file contains enhancments.                    ;;;;;
;;;                                                                    ;;;;;
;;;  Copyright (c) 1984,1987 by William Schelter,University of Texas   ;;;;;
;;;     All rights reserved                                            ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     (c) Copyright 1982 Massachusetts Institute of Technology         ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "MAXIMA")
(macsyma-module residu)

(load-macsyma-macros rzmac)

(DECLARE-top (*LEXPR $DIFF $SUBSTITUTE $TAYLOR $EXPAND)
	 (SPECIAL $BREAKUP $NOPRINCIPAL VARLIST
		  LEADCOEF VAR *ROOTS *FAILURES WFLAG NN*
		  SN* SD* $TELLRATLIST GENVAR SEMIRAT* DN* ZN)
	 (GENPREFIX RES))

(SETQ SEMIRAT* NIL) 

(DEFUN POLELIST (D REGION REGION1)
       (PROG (ROOTS $BREAKUP R RR SS R1 S POLE WFLAG CF) 
	     (SETQ WFLAG T)
	     (SETQ LEADCOEF (POLYINX D VAR 'LEADCOEF))
	     (SETQ ROOTS (SOLVECASE D))
	     (if (eq roots 'failure) (return ()))
   LOOP1     (COND ((NULL ROOTS)
		    (COND ((AND SEMIRAT*
				(> (f+ (length s) (length r))
				   ;(LENGTH (APPEND S R))
				   (f+ (length ss) (length rr))
				   ;(LENGTH (APPEND SS RR))
				   ))
			   (RETURN (LIST CF RR SS R1)))
			  (T (RETURN (LIST CF R S R1)))))
		   (T (SETQ POLE (CADDAR ROOTS))
		      (SETQ D (CADR ROOTS))
		      (COND (LEADCOEF
			     (SETQ CF (CONS POLE
					    (CONS 
					     (m^ (M+ VAR (M* -1 pole))
						 d)
					     CF)))))))
	(COND ((FUNCALL REGION POLE)
	       (COND ((EQUAL D 1)
		      (SETQ S (CONS POLE S)))
		     (T (SETQ R (CONS (LIST POLE D) R)))))
	      ((FUNCALL REGION1 POLE)
	       (COND ((NOT $NOPRINCIPAL)
		      (SETQ R1 (CONS POLE R1)))
		     (T (return nil))))
	      (SEMIRAT*
	       (COND ((EQUAL D 1)
		      (SETQ SS (CONS POLE SS)))
		     (T (SETQ RR (CONS (LIST POLE D) RR))))))
	(SETQ ROOTS (CDDR ROOTS))
	(GO LOOP1)))

(DEFUN SOLVECASE (E)
       (COND ((NOT (AMONG VAR E)) NIL)
	     (t (let (*FAILURES *ROOTS) 
		     (SOLVE E VAR 1)
		     (COND (*FAILURES 'failure)
			   ((NULL *ROOTS) ())
			   (t *ROOTS))))))

(DEFUN RES (N D REGION REGION1)
  (let ((PL (polelist d region region1))
	DP A B C FACTORS LEADCOEF)
    (cond 
     ((null pl) nil)
     (t (SETQ FACTORS (CAR PL))
	(SETQ PL (CDR PL))
	(COND ((OR (CADR PL)
		   (CADDR PL)) 
	       (SETQ DP (SDIFF D VAR))))
	(COND ((CAR PL)
	       (SETQ A (m+l (RESIDUE N (COND (LEADCOEF FACTORS)
					     (T D))
				     (CAR PL)))))
	      (t (setq a 0.)))
	(COND ((CADR PL)
	       (SETQ B (m+l (mapcar #'(lambda (pole)
					($residue (m// N D) var pole))
				    (CADR PL)))))
	      (t (setq b 0.)))
	(COND ((CADDR PL)
	       (SETQ C (m+l (mapcar #'(lambda (pole)
					($residue (m// N D) var pole))
				    (CADDR PL)))))
	      (t (setq c ())))
	(list (m+ a b) c)))))

(DEFUN RESIDUE (ZN FACTORS PL)
  (COND (LEADCOEF 
	 (MAPCAR #'(LAMBDA (J)
		     (let (((factor1 factor2) (remfactor factors (car j) zn)))
			  (RESM0 factor1 factor2 (car j) (cadr j))))
		 PL))
	(T (MAPCAR #'(LAMBDA (J)
			(RESM1 (DIV* ZN FACTORS) (CAR J)))
		   PL))))

(DEFUN RES1 (ZN ZD PL1)
  (SETQ ZD (DIV* ZN ZD))
  (MAPCAR #'(LAMBDA (J) ($RECTFORM ($EXPAND (SUBIN J ZD)))) PL1))

(DEFUN RESPROG0 (F G N N2)
       (PROG (A B C R) 
	     (SETQ A (RESPROG F G))
	     (SETQ B (CADR A) C (PTIMES (CDDR A) N2) A (CAAR A))
	     (SETQ A (PTIMES N A) B (PTIMES N B))
	     (SETQ R (PDIVIDE A G))
	     (SETQ A (CADR R) R (CAR R))
	     (SETQ B (CONS (PPLUS (PTIMES (CAR R) F) (PTIMES (CDR R) B))
			   (CDR R)))
	     (RETURN (CONS (CONS (CAR A) (PTIMES (CDR A) C))
			   (CONS (CAR B) (PTIMES (CDR B) C)))))) 


(DEFUN RESM0 (E N POLE M)
       (SETQ E (DIV* N E))
       (SETQ E ($DIFF E VAR (SUB1 M)))
       (SETQ E ($RECTFORM ($EXPAND (SUBIN POLE E))))
       (DIV* E (SIMPlify `((MFACTORIAL) ,(SUB1 M)))))

(DEFUN REMFACTOR (L P N)
       (PROG (F G) 
	LOOP (COND ((NULL L)
		    (RETURN (LIST (M*L (CONS LEADCOEF G)) N)))
		   ((EQUAL P (CAR L)) (SETQ F (CADR L)))
		   (T (SETQ G (CONS (CADR L) G))))
	     (SETQ L (CDDR L))
	     (GO LOOP)))

(DEFUN RESPROG (P1B P2B)
       (PROG (TEMP COEF1R COEF2R FAC COEF1S COEF2S ZEROPOLB F1 F2) 
	     (SETQ COEF2R (SETQ COEF1S 0))
	     (SETQ COEF2S (SETQ COEF1R 1))
	B1   (COND ((NOT (LESSP (PDEGREE P1B VAR) (PDEGREE P2B VAR))) (GO B2)))
	     (SETQ TEMP P2B)
	     (SETQ P2B P1B)
	     (SETQ P1B TEMP)
	     (SETQ TEMP COEF2R)
	     (SETQ COEF2R COEF1R)
	     (SETQ COEF1R TEMP)
	     (SETQ TEMP COEF2S)
	     (SETQ COEF2S COEF1S)
	     (SETQ COEF1S TEMP)
	B2   (COND ((ZEROP (PDEGREE P2B VAR))
		    (RETURN (CONS (CONS COEF2R P2B) (CONS COEF2S P2B)))))
	     (SETQ ZEROPOLB (PSIMP VAR
				   (LIST (DIFFERENCE (PDEGREE P1B VAR)
						     (PDEGREE P2B VAR))
					 1)))
	     (SETQ FAC (PGCD (CADDR P1B) (CADDR P2B)))
	     (SETQ F1 (PQUOTIENT (CADDR P1B) FAC))
	     (SETQ F2 (PQUOTIENT (CADDR P2B) FAC))
	     (SETQ P1B (PDIFFERENCE (PTIMES F2 (PSIMP (CAR P1B) (CDDDR P1B)))
				    (PTIMES F1
					    (PTIMES ZEROPOLB
						    (PSIMP (CAR P2B)
							   (CDDDR P2B))))))
	     (SETQ COEF1R (PDIFFERENCE (PTIMES F2 COEF1R)
				       (PTIMES (PTIMES F1 COEF2R) ZEROPOLB)))
	     (SETQ COEF1S (PDIFFERENCE (PTIMES F2 COEF1S)
				       (PTIMES (PTIMES F1 COEF2S) ZEROPOLB)))
	     (GO B1))) 

;;;Looks for polynomials. puts polys^(pos-num) in sn* polys^(neg-num) in sd*.
(DEFUN SNUMDEN (E)
  (COND ((OR (ATOM E) 
	     (MNUMP E))
	 (SETQ SN* (CONS E SN*)))
	((AND (mexptp E) 
	      (INTEGERP (CADDR E)))
	 (COND ((POLYINX (CADR E) VAR NIL)
		(COND ((MINUSP (CADDR E))
		       (SETQ SD* (CONS (COND ((EQUAL (CADDR E) -1) (CADR E))
					     (T (m^ (CADR E)
						       (MINUS (CADDR E)))))
				       SD*)))
		      (T (SETQ SN* (CONS E SN*)))))))
	((POLYINX E VAR NIL)
	 (SETQ SN* (CONS E SN*)))))

(SETQ SN* NIL SD* NIL) 

(DEFMFUN $RESIDUE (E VAR P)
  (COND (($UNKNOWN E) ($NOUNIFY '$RESIDUE) (LIST '(%RESIDUE) E VAR P))
	(T (LET (SN* SD*)
		(IF (AND (MTIMESP E) (ANDMAPCAR #'SNUMDEN (CDR E)))
		    (SETQ NN* (M*L SN*) DN* (M*L SD*))
		    (NUMDEN E)))
	   (RESM1 (DIV* NN* DN*) P))))

(DEFUN RESM1 (E POLE)
  (SETQ POLE ($RECTFORM POLE))
  (SETQ E (RATDISREP ($TAYLOR E VAR POLE
			      0  ;; things like residue(s/(s^2-a^2),s,a) fails if use -1
			      ;;-1
			      )))
  (COEFF E (M^ (M+ (M* -1 POLE) VAR) -1) 1))

