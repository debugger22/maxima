;;; -*- Mode: Lisp; Package: Macsyma -*-
;;; Translated code for LOCAL::MAX$DISK:[SHAREM]DEFSTMRUN.MC;2
;;; Written on 9/05/1984 13:27:21, from MACSYMA 302
;;; Translated for 176228

;;; TRANSL-AUTOLOAD version NIL
;;; TRANSS version 87 TRANSL version 1157 TRUTIL version 27
;;; TRANS1 version 108 TRANS2 version 39 TRANS3 version 50
;;; TRANS4 version 29 TRANS5 version 26 TRANSF version NIL
;;; TROPER version 15 TRPRED version 6 MTAGS version NIL
;;; MDEFUN version 58 TRANSQ version 88 FCALL version 40
;;; ACALL version 70 TRDATA version 68 MCOMPI version 146
;;; TRMODE version 75 TRHOOK version NIL
(eval-when (compile eval)
      (setq *infile-name-key*
	          (namestring (truename '#.standard-input))))

(eval-when (compile)
   (setq $tr_semicompile 'NIL)
   (setq forms-to-compile-queue ()))

(comment "MAX$DISK:[SHAREM]DEFSTMRUN.MC;2")

;;; General declarations required for translated MACSYMA code.

(DECLARE (SPECIAL $LOADPRINT))

(DEF-MTRVAR $LOADPRINT '$LOADPRINT 1)

(DEFMTRFUN-EXTERNAL ($REFERENCE_AN_EXTEND $ANY MDEFINE NIL NIL))

(DEFMTRFUN-EXTERNAL ($NOT_AN_EXTEND $ANY MDEFINE NIL NIL))

(DEFMTRFUN-EXTERNAL ($ALTER_EXTEND_CHECK $ANY MDEFINE NIL NIL))


(COND ((IS-BOOLE-CHECK (TRD-MSYMEVAL $LOADPRINT '$LOADPRINT))
	 (SIMPLIFY (MFUNCTION-CALL $PRINT '$DEFSTMRUN '|&source| '2))))

(SIMPLIFY (MFUNCTION-CALL $PUT '$DEFSTMRUN '2 '$VERSION))

(MEVAL* '(($MATCHFIX) &{ &}))

(DEFPROP $REFERENCE_AN_EXTEND T TRANSLATED)

(ADD2LNC '$REFERENCE_AN_EXTEND $PROPS)

(DEFMTRFUN
 ($REFERENCE_AN_EXTEND $ANY MDEFINE NIL NIL)
 ($X $ACCESSOR $EXPECTED_EXTEND_TYPE $SLOT_NUMBER) NIL
 ((LAMBDA ($TYPE)
    NIL
    (COND
      ((LIKE $TYPE NIL)
	 (SIMPLIFY (MFUNCTION-CALL $NOT_AN_EXTEND $ACCESSOR $X)))
      (T
	(COND
	  ((LIKE $TYPE $EXPECTED_EXTEND_TYPE)
	     (SIMPLIFY (MFUNCTION-CALL $EXTEND_REF $X $SLOT_NUMBER)))
	  (T
	    (SIMPLIFY (MFUNCTION-CALL $ERROR '|&Attempt to use| $ACCESSOR
				      '|&to access a slot of| $X
				      '|&Expected MACSYMA EXTEND type was:|
				      $EXPECTED_EXTEND_TYPE)))))))
  (SIMPLIFY (MFUNCTION-CALL $EXTENDP $X))))

(DEFPROP $NOT_AN_EXTEND T TRANSLATED)

(ADD2LNC '$NOT_AN_EXTEND $PROPS)

(DEFMTRFUN
  ($NOT_AN_EXTEND $ANY MDEFINE NIL NIL) ($ALT $OBJ) NIL
  (SIMPLIFY
    (MFUNCTION-CALL
      $ERROR $ALT
      '|&was not given a MACSYMA EXTEND object; argument was:| $OBJ)))

(DEFPROP $ALTER_EXTEND_CHECK T TRANSLATED)

(ADD2LNC '$ALTER_EXTEND_CHECK $PROPS)

(DEFMTRFUN
 ($ALTER_EXTEND_CHECK $ANY MDEFINE NIL NIL)
 ($X $ALTERANT $EXPECTED_EXTEND_TYPE) NIL
 ((LAMBDA ($TYPE)
    NIL
    (COND
      ((LIKE $TYPE NIL)
	 (SIMPLIFY (MFUNCTION-CALL $NOT_AN_EXTEND $ALTERANT $X)))
      (T
	(COND
	  ((NOT (LIKE $TYPE $EXPECTED_EXTEND_TYPE))
	     (SIMPLIFY (MFUNCTION-CALL
			 $ERROR '|&Attempt to apply| $ALTERANT '|&to alter|
			 $X '|&Expected MACSYMA EXTEND type was:|
			 $EXPECTED_EXTEND_TYPE)))))))
  (SIMPLIFY (MFUNCTION-CALL $EXTENDP $X))))

(compile-forms-to-compile-queue)

