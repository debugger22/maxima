;;; -*- Mode: Lisp; Package: Macsyma -*-
;;; Translated code for LMIVAX::MAX$DISK:[SHARE2]KN.MC;2
;;; Written on 9/15/1984 21:18:40, from MACSYMA 302
;;; Translated for LPH

;;; TRANSL-AUTOLOAD version NIL
;;; TRANSS version 87 TRANSL version 1157 TRUTIL version 27
;;; TRANS1 version 108 TRANS2 version 39 TRANS3 version 50
;;; TRANS4 version 29 TRANS5 version 26 TRANSF version NIL
;;; TROPER version 15 TRPRED version 6 MTAGS version NIL
;;; MDEFUN version 58 TRANSQ version 88 FCALL version 40
;;; ACALL version 70 TRDATA version 68 MCOMPI version 146
;;; TRMODE version 73 TRHOOK version NIL
(eval-when (compile eval)
      (setq *infile-name-key*
	          (namestring (truename '#.standard-input))))

(eval-when (compile)
   (setq $tr_semicompile 'NIL)
   (setq forms-to-compile-queue ()))

(comment "MAX$DISK:[SHARE2]KN.MC;2")

;;; General declarations required for translated MACSYMA code.

(DECLARE (SPECIAL $KARRAY))

(DEF-MTRVAR $KARRAY '$KARRAY 1)

(DEFMTRFUN-EXTERNAL ($KN $ANY MDEFINE NIL NIL))

(DEFMTRFUN-EXTERNAL ($K0 $ANY MDEFINE NIL NIL))

(DEFMTRFUN-EXTERNAL ($K1 $ANY MDEFINE NIL NIL))

(DEFMTRFUN-EXTERNAL ($KNDOT $ANY MDEFINE NIL NIL))


(SIMPLIFY (MFUNCTION-CALL $LOAD '|bessel|))

(MEVAL* '(($DECLARE) $KARRAY $SPECIAL))

(DEFPROP $KN T TRANSLATED)

(ADD2LNC '$KN $PROPS)

(DEFMTRFUN
 ($KN $ANY MDEFINE NIL NIL) ($X $N) NIL
 ((LAMBDA ()
    NIL
    (PROG ()
	 (COND
	   ((LIKE $N 0)
	      (RETURN ((LAMBDA ()
			 NIL
			 (MARRAYSET (SIMPLIFY (MFUNCTION-CALL $K0 $X))
				    (TRD-MSYMEVAL $KARRAY '$KARRAY) 0)
			 (MARRAYREF (TRD-MSYMEVAL $KARRAY '$KARRAY) 0))))))
	 (COND
	   ((LIKE $N 1)
	      (RETURN ((LAMBDA ()
			 NIL
			 (MARRAYSET (SIMPLIFY (MFUNCTION-CALL $K1 $X))
				    (TRD-MSYMEVAL $KARRAY '$KARRAY) 1)
			 (MARRAYREF (TRD-MSYMEVAL $KARRAY '$KARRAY) 1))))))
	 (MARRAYSET
	   (ADD* (MUL* (DIV (MUL* 2.0d+0 (ADD* $N -1)) $X)
		       (SIMPLIFY (MFUNCTION-CALL $KN $X (ADD* $N -1))))
		 (SIMPLIFY (MFUNCTION-CALL $KN $X (ADD* $N -2))))
	   (TRD-MSYMEVAL $KARRAY '$KARRAY) $N)
	 (RETURN (MARRAYREF (TRD-MSYMEVAL $KARRAY '$KARRAY) $N))))))

(DEFPROP $K0 T TRANSLATED)

(ADD2LNC '$K0 $PROPS)

(DEFMTRFUN
  ($K0 $ANY MDEFINE NIL NIL) ($X) NIL
  ((LAMBDA ($XHALF $TWOBYX)
     NIL
     (COND
       ((NOT (IS-BOOLE-CHECK (MGRP $X 2.0d+0)))
	  (SETQ $XHALF (MUL* 0.5d+0 $X))
	  (ADD* (MUL* (*MMINUS (SIMPLIFY (LIST '(%LOG) $XHALF)))
		      (SIMPLIFY (MFUNCTION-CALL $I0 $X)))
		-0.57721566d+0 (MUL* 0.4227842d+0 (POWER $XHALF 2))
		(MUL* 0.23069756d+0 (POWER $XHALF 4))
		(MUL* 3.48859D-02 (POWER $XHALF 6))
		(MUL* 2.62698D-03 (POWER $XHALF 8))
		(MUL* 1.075D-04 (POWER $XHALF 10))
		(MUL* 7.4D-06 (POWER $XHALF 12))))
       (T (SETQ $TWOBYX (DIV 2.0d+0 $X))
	  (MUL*
	    (DIV 1.0d+0
		 (MUL* (SIMPLIFY (LIST '(%SQRT) $X)) (SIMPLIFY ($EXP $X))))
	    (ADD* 1.25331414d+0 (*MMINUS (MUL* 7.832358D-02 $TWOBYX))
		  (MUL* 2.189568D-02 (POWER $TWOBYX 2))
		  (MUL* -1.062446D-02 (POWER $TWOBYX 3))
		  (MUL* 5.87872D-03 (POWER $TWOBYX 4))
		  (MUL* -2.5154D-03 (POWER $TWOBYX 5))
		  (MUL* 5.3208D-04 (POWER $TWOBYX 6)))))))
   '$XHALF '$TWOBYX))

(DEFPROP $K1 T TRANSLATED)

(ADD2LNC '$K1 $PROPS)

(DEFMTRFUN
  ($K1 $ANY MDEFINE NIL NIL) ($X) NIL
  ((LAMBDA ($XHALF $TWOBYX)
     NIL
     (COND
       ((NOT (IS-BOOLE-CHECK (MGRP $X 2.0d+0)))
	  (SETQ $XHALF (MUL* 0.5d+0 $X))
	  (MUL*
	    (DIV 1.0d+0 $X) (ADD* (MUL* $X (SIMPLIFY (LIST '(%LOG) $XHALF))
					(SIMPLIFY (MFUNCTION-CALL $I1 $X)))
				  1 (MUL* 0.15443144d+0 (POWER $XHALF 2))
				  (MUL* -0.67278579d+0 (POWER $XHALF 4))
				  (MUL* -0.18156897d+0 (POWER $XHALF 6))
				  (MUL* -1.919402D-02 (POWER $XHALF 8))
				  (MUL* -1.10404D-03 (POWER $XHALF 10))
				  (MUL* -4.686D-05 (POWER $XHALF 12)))))
       (T (SETQ $TWOBYX (DIV 2.0d+0 $X))
	  (MUL*
	    (DIV 1.0d+0
		 (MUL* (SIMPLIFY (LIST '(%SQRT) $X)) (SIMPLIFY ($EXP $X))))
	    (ADD* 1.25331414d+0 (MUL* 0.23498619d+0 $TWOBYX)
		  (MUL* -3.65562D-02 (POWER $TWOBYX 2))
		  (MUL* 1.504268D-02 (POWER $TWOBYX 3))
		  (MUL* -7.80353D-03 (POWER $TWOBYX 4))
		  (MUL* 3.25614D-03 (POWER $TWOBYX 5))
		  (MUL* -6.8245D-04 (POWER $TWOBYX 6)))))))
   '$XHALF '$TWOBYX))

(DEFPROP $KNDOT T TRANSLATED)

(ADD2LNC '$KNDOT $PROPS)

(DEFMTRFUN
  ($KNDOT $ANY MDEFINE NIL NIL) ($X $N) NIL
  (ADD*
    (SIMPLIFY (MFUNCTION-CALL $KN $X (ADD* $N -1)))
    (*MMINUS (MUL* (DIV $N $X) (SIMPLIFY (MFUNCTION-CALL $KN $X $N))))))

(compile-forms-to-compile-queue)

