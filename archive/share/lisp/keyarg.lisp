;;; -*- Mode: Lisp; Package: Macsyma -*-
;;; Translated code for LOCAL::MAX$DISK:[SHAREM]KEYARG.MC;2
;;; Written on 8/27/1984 15:40:57, from MACSYMA 302
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

(comment "MAX$DISK:[SHAREM]KEYARG.MC;2")

(DECLARE (SPECIAL $LOADPRINT))
(DEF-MTRVAR $LOADPRINT (QUOTE $LOADPRINT) 1)
(PUTPROP (QUOTE MAPLIST_TR) (OR (GET (QUOTE MARRAYREF) (QUOTE AUTOLOAD)) T) (QUOTE AUTOLOAD))
(DEFMTRFUN-EXTERNAL ($TRANSLATE_KEYARG $ANY MDEFINE NIL NIL))
(DEFMTRFUN-EXTERNAL ($KEY_INDICATOR $ANY MDEFINE NIL NIL))
(DEFMTRFUN-EXTERNAL ($KEY_ATOM $ANY MDEFINE NIL NIL))
(DEFMTRFUN-EXTERNAL ($KEY_PAIR $ANY MDEFINE NIL NIL))

(COND ((IS-BOOLE-CHECK (TRD-MSYMEVAL $LOADPRINT (QUOTE $LOADPRINT))) (SIMPLIFY (MFUNCTION-CALL $PRINT (QUOTE $KEYARG) (QUOTE |&source|) (QUOTE 2)))))
(SIMPLIFY (MFUNCTION-CALL $PUT (QUOTE $KEYARG) (QUOTE 2) (QUOTE $VERSION)))
(DEFPROP $DEF_KEYARG T TRANSLATED)
(ADD2LNC (QUOTE $DEF_KEYARG) $PROPS)
(DEFMTRFUN ($DEF_KEYARG $ANY MDEFMACRO NIL NIL) ($HEADER $BODY) NIL (MBUILDQ-SUBST (LIST (CONS (QUOTE $MNAME) (SIMPLIFY (MFUNCTION-CALL $PART $HEADER 0))) (CONS (QUOTE $BODY) $BODY) (CONS (QUOTE $SNAME) (SIMPLIFY (MFUNCTION-CALL $CONCAT (SIMPLIFY (MFUNCTION-CALL $PART $HEADER 0)) (QUOTE |&-internal|)))) (CONS (QUOTE $SARGS) (MAPLIST_TR (M-TLAMBDA ($U) NIL (COND ((MFUNCTION-CALL $ATOM $U) $U) (T (SIMPLIFY (MFUNCTION-CALL $PART $U 1))))) (SIMPLIFY (MFUNCTION-CALL $ARGS $HEADER)))) (CONS (QUOTE $DISPATCH) (MAP
LIST_TR (M-TLAMBDA ($U) NIL (COND ((MFUNCTION-CALL $ATOM $U) (LIST (QUOTE (MLIST)) (QUOTE $KEY_ATOM) (LIST (QUOTE (MLIST)) $U))) (T (LIST (QUOTE (MLIST)) (QUOTE $KEY_PAIR) (LIST (QUOTE (MLIST)) (SIMPLIFY (MFUNCTION-CALL $PART $U 1)) (SIMPLIFY (MFUNCTION-CALL $PART $U 2))))))) (SIMPLIFY (MFUNCTION-CALL $ARGS $HEADER))))) (QUOTE ((MPROGN) (($EVAL_WHEN) $LOADFILE (($SETUP_AUTOLOAD) |&MAX$DISK:[SHAREM]KEYARG| $TRANSLATE_KEYARG)) (($PUT) ((MQUOTE) $MNAME) ((MQUOTE) $DISPATCH) ((MQUOTE) $TRANSLATE_KEYARG)) ((MDEF
MACRO) (($MNAME) ((MLIST) $MACRO_ARGL)) (($TRANSLATE_KEYARG) $MACRO_ARGL ((MQUOTE) $MNAME) ((MQUOTE) $SNAME))) ((MDEFINE) (($SNAME) (($SPLICE) $SARGS)) $BODY)))))
(DEFPROP $TRANSLATE_KEYARG T TRANSLATED)
(ADD2LNC (QUOTE $TRANSLATE_KEYARG) $PROPS)
(DEFMTRFUN ($TRANSLATE_KEYARG $ANY MDEFINE NIL NIL) ($MACRO_ARGL $MNAME $SNAME) NIL ((LAMBDA ($SARGL $TEMP $DISPATCH) NIL (DO (($D) (MDO (CDR $DISPATCH) (CDR MDO))) ((NULL MDO) (QUOTE $DONE)) (SETQ $D (CAR MDO)) (SETQ $TEMP (SIMPLIFY (MAPPLY-TR (MARRAYREF $D 1) (SIMPLIFY (MFUNCTION-CALL $CONS $MACRO_ARGL (MARRAYREF $D 2)))))) (SETQ $SARGL (SIMPLIFY (MFUNCTION-CALL $CONS (MARRAYREF $TEMP 1) $SARGL))) (SETQ $MACRO_ARGL (MARRAYREF $TEMP 2))) (COND ((NOT (LIKE $MACRO_ARGL (QUOTE ((MLIST))))) (SIMPLIFY (MFUNCTIO
N-CALL $ERROR (QUOTE |&Unknown arguments to|) $MNAME (QUOTE |&:|) $MACRO_ARGL)))) (SIMPLIFY (MFUNCTION-CALL $FUNMAKE $SNAME (SIMPLIFY (MFUNCTION-CALL $REVERSE $SARGL))))) (QUOTE ((MLIST))) (QUOTE $TEMP) (SIMPLIFY (MFUNCTION-CALL $GET $MNAME (QUOTE $TRANSLATE_KEYARG)))))
(DEFPROP $KEY_INDICATOR T TRANSLATED)
(ADD2LNC (QUOTE $KEY_INDICATOR) $PROPS)
(DEFMTRFUN ($KEY_INDICATOR $ANY MDEFINE NIL NIL) ($ARGL $ATOM $VALUE) NIL (PROGN (DO (($A) (MDO (CDR $ARGL) (CDR MDO))) ((NULL MDO) (QUOTE $DONE)) (SETQ $A (CAR MDO)) (COND ((IS-BOOLE-CHECK (SIMPLIFY (MFUNCALL $ATOM $A))) (COND ((LIKE $A $ATOM) (SETQ $VALUE T) (SETQ $ARGL (SIMPLIFY (MFUNCTION-CALL $DELETE $A $ARGL))) (RETURN (QUOTE $DONE))))) ((LIKE (SIMPLIFY (MFUNCTION-CALL $PART $A 1)) $ATOM) (SETQ $VALUE (SIMPLIFY (MFUNCTION-CALL $PART $A 2))) (SETQ $ARGL (SIMPLIFY (MFUNCTION-CALL $DELETE $A $ARGL))) (RE
TURN (QUOTE $DONE))))) (LIST (QUOTE (MLIST)) $VALUE $ARGL)))
(DEFPROP $KEY_ATOM T TRANSLATED)
(ADD2LNC (QUOTE $KEY_ATOM) $PROPS)
(DEFMTRFUN ($KEY_ATOM $ANY MDEFINE NIL NIL) ($ARGL $ATOM) NIL (SIMPLIFY (MFUNCTION-CALL $KEY_INDICATOR $ARGL $ATOM NIL)))
(DEFPROP $KEY_PAIR T TRANSLATED)
(ADD2LNC (QUOTE $KEY_PAIR) $PROPS)
(DEFMTRFUN ($KEY_PAIR $ANY MDEFINE NIL NIL) ($ARGL $ATOM $VALUE) NIL (SIMPLIFY (MFUNCTION-CALL $KEY_INDICATOR $ARGL $ATOM $VALUE)))

(compile-forms-to-compile-queue)

