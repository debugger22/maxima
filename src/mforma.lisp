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
(macsyma-module mforma macro)

;#+ti
;(eval-when (compile)
;  (load "cl-maxima-source:maxima;mforma.lisp"))


;;; A mini version of FORMAT for macsyma error messages, and other
;;; user interaction.
;;; George J. Carrette - 10:59am  Tuesday, 21 October 1980

;;; This file is used at compile-time for macsyma system code in general,
;;; and also for MAXSRC;MFORMT > and MAXSRC;MERROR >.
;;; Open-coding of MFORMAT is supported, as are run-time MFORMAT string
;;; interpretation. In all cases syntax checking of the MFORMAT string
;;; at compile-time is done.

;;; For the prettiest output the normal mode here will be to
;;; cons up items to pass as MTEXT forms.

;;; Macro definitions for defining a format string interpreter.
;;; N.B. All of these macros expand into forms which contain free
;;; variables, i.e. they assume that they will be expanded in the
;;; proper context of an MFORMAT-LOOP definition. It's a bit
;;; ad-hoc, and not as clean as it should be.
;;; (Macrofy DEFINE-AN-MFORMAT-INTERPRETER, and give the free variables
;;; which are otherwise invisible, better names to boot.)

;;; There are 3 definitions of MFORMAT.
;;; [1] The interpreter.
;;; [2] The compile-time syntax checker.
;;; [3] The open-compiler.

;; Some commentary as to what the hell is going on here would be greatly
;; appreciated.  This is probably very elegant code, but I can't figure
;; it out. -cwh
;; This is macros defining macros defining function bodies man.
;; top-level side-effects during macroexpansion consing up shit
;; for an interpreter loop. I only do this to save address space (sort of
;; kidding.) -gjc

;#-ti
;(DEFMACRO DEF-MFORMAT (&OPTIONAL  #-ti (type '||)
;		       #+ti (TYPE  (intern "")))
;  ;; Call to this macro at head of file.
;  (PUTPROP TYPE NIL 'MFORMAT-OPS)
;  (PUTPROP TYPE NIL 'MFORMAT-STATE-VARS)
;  `(PROGN 'COMPILE
;	  (DEFMACRO ,(SYMBOLCONC 'DEF-MFORMAT-OP TYPE)
;	    (CHAR &REST BODY)
;	    `(+DEF-MFORMAT-OP ,',TYPE ,CHAR ,@BODY))
;	  (DEFMACRO ,(SYMBOLCONC 'DEF-MFORMAT-VAR TYPE)
;	    (VAR VAL INIT)
;	    `(+DEF-MFORMAT-VAR ,',TYPE ,VAR ,VAL ,INIT))
;	  (DEFMACRO ,(SYMBOLCONC 'MFORMAT-LOOP TYPE)
;	    (&REST ENDCODE)
;	    `(+MFORMAT-LOOP ,',TYPE ,@ENDCODE))))



(DEFMACRO DEF-MFORMAT (&OPTIONAL  
		        (TYPE  (intern "")))
  ;; Call to this macro at head of file.
  (PUTPROP TYPE NIL 'MFORMAT-OPS)
  (PUTPROP TYPE NIL 'MFORMAT-STATE-VARS)
  `(eval-when (compile load eval)
	  (DEFMACRO ,(SYMBOLCONC 'DEF-MFORMAT-OP TYPE)
	    (CHAR &REST BODY)
	    `(+DEF-MFORMAT-OP ,',TYPE ,CHAR ,@BODY))
	  (DEFMACRO ,(SYMBOLCONC 'DEF-MFORMAT-VAR TYPE)
	    (VAR VAL INIT)
	    `(+DEF-MFORMAT-VAR ,',TYPE ,VAR ,VAL ,INIT))
	  (DEFMACRO ,(SYMBOLCONC 'MFORMAT-LOOP TYPE)
	    (&REST ENDCODE)
	    `(+MFORMAT-LOOP ,',TYPE ,@ENDCODE))))


(defmacro +def-mformat-var (TYPE var val INIT-CONDITION)
  (LET #+LISPM ((DEFAULT-CONS-AREA WORKING-STORAGE-AREA)) #-LISPM NIL
       ;; How about that bullshit LISPM conditionalization put in
       ;; by BEE? It is needed of course or else conses will go away. -gjc
       (PUSH (LIST VAR VAL)
	     (CDR (OR (zl-ASSOC INIT-CONDITION
				(GET TYPE 'MFORMAT-STATE-VARS))
		      (CAR (PUSH (NCONS INIT-CONDITION)
				 (GET TYPE 'MFORMAT-STATE-VARS)))))))
  `',VAR)

(defmacro +def-mformat-op (TYPE char &rest body)
  ; can also be a list of CHAR's
  (LET #+LISPM ((DEFAULT-CONS-AREA WORKING-STORAGE-AREA)) #-LISPM NIL
       (IF (ATOM CHAR) (SETQ CHAR (LIST CHAR)))
	  (PUSH (CONS CHAR BODY) (GET TYPE 'MFORMAT-OPS))
	  `',(MAKNAM (NCONC (EXPLODEN "MFORMAT-")
			    (MAPCAR #'ASCII CHAR)))))

(DEFMACRO POP-MFORMAT-ARG ()
  `(COND ((= ARG-INDEX N)
	  (MAXIMA-ERROR "Ran out of mformat args" (LISTIFY N) 'FAIL-ACT))
	 (T (PROGN (SETQ ARG-INDEX (f1+ ARG-INDEX))
		   (ARG ARG-INDEX)))))

(DEFMACRO LEFTOVER-MFORMAT-ARGS? ()
  ;; To be called after we are done.
  '(OR (= ARG-INDEX N)
       (MAXIMA-ERROR "Extra mformat args" (LISTIFY N) 'FAIL-ACT)))

(DEFMACRO BIND-MFORMAT-STATE-VARS (TYPE &REST BODY)
  `(LET ,(DO ((L NIL)
	      (V (GET TYPE 'MFORMAT-STATE-VARS) (CDR V)))
	     ((NULL V) L)
	   (DO ((CONDS (CDR (CAR V)) (CDR CONDS)))
	       ((NULL CONDS))
	     (PUSH (CAR CONDS) L)))
     ,@BODY))

(DEFMACRO POP-MFORMAT-STRING ()
  '(IF (NULL SSTRING) 
       (MAXIMA-ERROR "Runout of MFORMAT string" NIL 'FAIL-ACT)
       (POP sSTRING)))

(DEFMACRO NULL-MFORMAT-STRING () '(NULL sSTRING))
(DEFMACRO TOP-MFORMAT-STRING ()
  '(IF (NULL sSTRING)
       (MAXIMA-ERROR "Runout of MFORMAT string" NIL 'FAIL-ACT)
       (CAR sSTRING)))

(DEFMACRO CDR-MFORMAT-STRING ()
  `(SETQ sSTRING (CDR sSTRING)))

(DEFMACRO MFORMAT-DISPATCH-ON-CHAR (TYPE)
  `(PROGN (COND ,@(MAPCAR #'(LAMBDA (PAIR)
			      `(,(IF (ATOM (CAR PAIR))
				     `(char= CHAR ,(CAR PAIR))
				     `(OR-1 ,@(MAPCAR
					       #'(LAMBDA (C)
						   `(char= CHAR,C))
					       (CAR PAIR))))
				,@(CDR PAIR)))
			  (GET TYPE 'MFORMAT-OPS))
		;; perhaps optimize the COND to use ">" "<".
		(t
		 (MAXIMA-ERROR "Unknown format op." (ascii char) 'FAIL-ACT)))
	  ,@(MAPCAR #'(LAMBDA (STATE)
			`(IF ,(CAR STATE)
			     (SETQ ,@(APPLY #'APPEND (CDR STATE)))))
		    (GET TYPE 'MFORMAT-STATE-VARS))))

(DEFMACRO OR-1 (FIRST &REST REST)
  ;; So the style warnings for one argument case to OR don't
  ;; confuse us.
  (IF (NULL REST) FIRST `(OR ,FIRST ,@REST)))

;(DEFMACRO WHITE-SPACE-P (X)
;  `(zl-MEMBER ,X '(#\LINEFEED #\Return #\SPACE #\TAB #-lispm #\VT #\Page)))

(DEFMACRO WHITE-SPACE-P (X)
  `(zl-member ,x '(#\linefeed #\return #\space #\tab  #\page)))



(DEFMACRO +MFORMAT-LOOP (TYPE &REST end-code)
  `(BIND-MFORMAT-STATE-VARS
    ,TYPE
    (DO ((CHAR))
	((NULL-MFORMAT-STRING)
	 (LEFTOVER-MFORMAT-ARGS?)
	 ,@end-code)
      (SETQ CHAR (POP sSTRING))
      (COND ((char= CHAR #\~)
	     (DO ()
		 (NIL)
	       (SETQ CHAR (POP-MFORMAT-STRING))
	       (COND ((char= CHAR #\@)
		      (SETQ |@-FLAG| T))
		     ((char= CHAR #\:)
		      (SETQ |:-FLAG| T))
		     ((char= CHAR #\~)
		      (PUSH CHAR TEXT-TEMP)
		      (RETURN NIL))
		     ((WHITE-SPACE-P CHAR)
		      (DO ()
			  ((NOT (WHITE-SPACE-P (TOP-MFORMAT-STRING))))
			(CDR-MFORMAT-STRING))
		      (RETURN NIL))
		     ((OR (#+cl char< #-cl <
			    CHAR #\0) ( #+cl char> #-cl >
					CHAR #\9))
		      (MFORMAT-DISPATCH-ON-CHAR ,TYPE)
		      (RETURN NIL))
		     (T
		      (SETQ PARAMETER
			    (f+ (f- (char-code char) (char-code #\0))
			       (f* 10. PARAMETER))
			    PARAMETER-P T)))))

	    (T
	     (PUSH CHAR TEXT-TEMP))))))


;;; The following definitions of MFORMAT ops are for compile-time,
;;; the runtime definitions are in MFORMT.

(defvar WANT-OPEN-COMPILED-MFORMAT NIL)
(defvar CANT-OPEN-COMPILE-MFORMAT NIL)


(DEF-MFORMAT |-C|)

	 
(DEF-MFORMAT-VAR-C |:-FLAG|     NIL T)
(DEF-MFORMAT-VAR-C |@-FLAG|     NIL T)
(DEF-MFORMAT-VAR-C PARAMETER   0  T) 
(DEF-MFORMAT-VAR-C PARAMETER-P NIL T)
(DEF-MFORMAT-VAR-C TEXT-TEMP NIL NIL)
(DEF-MFORMAT-VAR-C CODE NIL NIL)

(DEFMACRO EMITC (X)
  `(PUSH ,X CODE))

(DEFMACRO PUSH-TEXT-TEMP-C ()
  '(AND TEXT-TEMP
	(PROGN (EMITC `(PRINC ',(MAKNAM (NREVERSE TEXT-TEMP)) ,STREAM))
	       (SETQ TEXT-TEMP NIL))))

(DEF-MFORMAT-OP-C (#\% #\&)
  (COND (WANT-OPEN-COMPILED-MFORMAT
	 (PUSH-TEXT-TEMP-C)
	 (IF (char= CHAR #\&)
	     (EMITC `(CURSORPOS 'A ,STREAM))
	     (EMITC `(TERPRI ,STREAM))))))

(DEF-MFORMAT-OP-C #\M
  (COND (WANT-OPEN-COMPILED-MFORMAT
	 (PUSH-TEXT-TEMP-C)
	 (EMITC `(,(IF |:-FLAG| 'MGRIND 'DISPLAF)
		  (,(IF |@-FLAG| 'GETOP 'PROGN)
		   ,(POP-MFORMAT-ARG))
		  ,STREAM)))
	(T (POP-MFORMAT-ARG))))

(DEF-MFORMAT-OP-C (#\A #\S)
  (COND (WANT-OPEN-COMPILED-MFORMAT
	 (PUSH-TEXT-TEMP-C)
	 (EMITC `(,(IF (char= CHAR #\A) 'PRINC 'PRIN1)
		  ,(POP-MFORMAT-ARG)
		  ,STREAM)))
	(T (POP-MFORMAT-ARG))))

(DEFUN OPTIMIZE-PRINT-INST (L)
  ;; Should remove extra calls to TERPRI around DISPLA.
  ;; Mainly want to remove (PRINC FOO NIL) => (PRINC FOO)
  ;; although I'm not sure this is correct. geezz.
  (DO ((NEW NIL))
      ((NULL L) `(PROGN ,@NEW))
    (LET ((A (POP L)))
      (COND ((EQ (CAR A) 'TERPRI)
	     (COND ((EQ (CADR A) NIL)
		    (PUSH '(TERPRI) NEW))
		   (T (PUSH A NEW))))
	    ((AND (EQ (CADDR A) NIL)
		  (NOT (EQ (CAR A) 'MGRIND)))
	     (COND ((EQ (CAR A) 'DISPLAF)
		    (PUSH `(DISPLA ,(CADR A)) NEW))
		   (T
		    (PUSH `(,(CAR A) ,(CADR A)) NEW))))
	    (T
	     (PUSH A NEW))))))

(DEFMACRO NORMALIZE-STREAM (STREAM)
  STREAM
  #+ITS `(IF (EQ ,STREAM '*terminal-io*)
	     (SETQ ,STREAM 'TYO))
  #-ITS NIL)

(DEFmfUN MFORMAT-TRANSLATE-OPEN N
  (LET ((STREAM (ARG 1))
	(sSTRING (EXPLODEN (ARG 2)))
	(WANT-OPEN-COMPILED-MFORMAT T)
	(CANT-OPEN-COMPILE-MFORMAT NIL)
	(ARG-INDEX 2))
    (NORMALIZE-STREAM STREAM)
    (MFORMAT-LOOP-C
     (PROGN (PUSH-TEXT-TEMP-C)
	    (IF CANT-OPEN-COMPILE-MFORMAT
		(MAXIMA-ERROR "CAN'T OPEN COMPILE MFORMAT ON THIS CASE."
		       (LISTIFY N)
		       'FAIL-ACT
		       ))
	    (OPTIMIZE-PRINT-INST CODE)))))

(DEFmfUN MFORMAT-SYNTAX-CHECK N
  (LET ((ARG-INDEX 2)
	(STREAM NIL)
	(sSTRING (EXPLODEN (ARG 2)))
	(WANT-OPEN-COMPILED-MFORMAT NIL))
    (MFORMAT-LOOP-C NIL)))


(defmacro progn-pig (&rest l) `(progn ,@l))

(DEFUN PROCESS-MESSAGE-ARGUMENT (X)
  ;; Return NIL if we have already processed this
  ;; message argument, NCONS of object if not
  ;; processed.
  (IF (AND (NOT (ATOM X))
	   (MEMQ (CAR X) '(OUT-OF-CORE-STRING PROGN-pig)))
      NIL
      (NCONS (IF (AND (STRINGP X) (STATUS FEATURE ITS))
		 `(OUT-OF-CORE-STRING ,X)
		 `(PROGN-pig ,X)))))

(DEFUN MFORMAT-TRANSLATE (ARGUMENTS COMPILING?)
  (LET (((STREAM sSTRING . OTHER-SHIT) ARGUMENTS))
    (let ((mess (process-message-argument sstring)))
      (COND ((NULL MESS) NIL)
	    ('On-the-other-hand
	     (SETQ MESS (CAR MESS))
	     (NORMALIZE-STREAM STREAM)
	     (IF (AND (STRINGP sSTRING) COMPILING?)
		 (APPLY #'MFORMAT-SYNTAX-CHECK
				STREAM sSTRING OTHER-SHIT))
	     `(,(OR (CDR (zl-ASSOC (f+ 2			; two leading args.
				   (LENGTH OTHER-SHIT))
				'((2 . *MFORMAT-2)
				  (3 . *MFORMAT-3)
				  (4 . *MFORMAT-4)
				  (5 . *MFORMAT-5))))
		   'MFORMAT)
	       ,STREAM
	       ,MESS
	       ,@OTHER-SHIT))))))

(DEFUN MTELL-TRANSLATE (ARGUMENTS COMPILING?)
  (LET (((sSTRING . OTHER-SHIT) ARGUMENTS))
    (LET ((MESS (PROCESS-MESSAGE-ARGUMENT sSTRING)))
      (COND ((NULL MESS) NIL)
	    ('ON-THE-OTHER-HAND
	     (SETQ MESS (CAR MESS))
	     (IF (AND (STRINGP sSTRING) COMPILING?)
		 (APPLY #'MFORMAT-SYNTAX-CHECK
				NIL SSTRING OTHER-SHIT))
	     `(,(OR (CDR (zl-ASSOC (f+ 1 (LENGTH OTHER-SHIT))
				'((1 . MTELL1)
				  (2 . MTELL2)
				  (3 . MTELL3)
				  (4 . MTELL4)
				  (5 . MTELL5))))
		    'MTELL)
	       ,MESS
	       ,@OTHER-SHIT))))))

(DEFMACRO MFORMAT-OPEN (STREAM SSTRING &REST OTHER-SHIT)
  (IF (NOT (STRINGP SSTRING))
      (MAXIMA-ERROR "Not a string, can't open-compile the MFORMAT call"
	     SSTRING 'FAIL-ACT)
      (APPLY #'MFORMAT-TRANSLATE-OPEN
		     STREAM
		     SSTRING
		     OTHER-SHIT)))

(DEFMACRO MTELL-OPEN (MESSAGE &REST OTHER-SHIT)
  `(MFORMAT-OPEN NIL ,MESSAGE . ,OTHER-SHIT))

(DEFUN MERROR-TRANSLATE (ARGUMENTS COMPILING?)
  (LET (((MESSAGE . OTHER-SHIT) ARGUMENTS))
    (LET ((MESS (PROCESS-MESSAGE-ARGUMENT MESSAGE)))
      (COND ((NULL MESS) NIL)
	    ('ON-THE-OTHER-HAND
	     (IF (AND (STRINGP MESSAGE) COMPILING?)
		 (APPLY #'MFORMAT-SYNTAX-CHECK
		       NIL
		       MESSAGE OTHER-SHIT))
	     (SETQ MESS (CAR MESS))
	     `(,(OR (CDR (zl-ASSOC (f+ 1 (LENGTH OTHER-SHIT))
				'((1 . *MERROR-1)
				  (2 . *MERROR-2)
				  (3 . *MERROR-3)
				  (4 . *MERROR-4)
				  (5 . *MERROR-5))))
		    'MERROR)
	       ,MESS
	       ,@OTHER-SHIT))))))

(DEFUN ERRRJF-TRANSLATE (ARGUMENTS COMPILING?)
  (LET (((MESSAGE . OTHER-SHIT) ARGUMENTS))
    (LET ((MESS (PROCESS-MESSAGE-ARGUMENT MESSAGE)))
      (COND ((NULL MESS) NIL)
	    ('ON-THE-OTHER-HAND
	     (IF (AND (STRINGP MESSAGE) COMPILING?)
		 (APPLY #'MFORMAT-SYNTAX-CHECK
		       NIL
		       MESSAGE OTHER-SHIT))
	     (SETQ MESS (CAR MESS))
	     `(,(OR (CDR (zl-ASSOC (f+ 1 (LENGTH OTHER-SHIT))
				'((1 . *ERRRJF-1))))
		    'ERRRJF)
	       ,MESS ,@OTHER-SHIT))))))
#+PDP10
(PROGN 'COMPILE

(DEFUN GET-TRANSLATOR (OP)
  (OR (GET OP 'TRANSLATOR)
      (GET-TRANSLATOR (MAXIMA-ERROR "has no translator" OP 'wrng-type-arg))))

(DEFVAR SOURCE-TRANS-DRIVE NIL)
(DEFUN SOURCE-TRANS-DRIVE (FORM)
  (LET ((X (FUNCALL (GET-TRANSLATOR (CAR FORM)) (CDR FORM) T)))
    (WHEN (AND X SOURCE-TRANS-DRIVE)
	  (PRINT FORM TYO)
	  (PRINC "==>" TYO)
	  (PRINT X TYO))
    (IF (NULL X) (VALUES FORM NIL) (VALUES X T))))
(DEFUN PUT-SOURCE-TRANS-DRIVE (OP TR)
  (PUTPROP OP '(SOURCE-TRANS-DRIVE) 'SOURCE-TRANS)
  (PUTPROP OP TR 'TRANSLATOR))

(PUT-SOURCE-TRANS-DRIVE 'MFORMAT 'MFORMAT-TRANSLATE)
(PUT-SOURCE-TRANS-DRIVE 'MTELL 'MTELL-TRANSLATE)
(PUT-SOURCE-TRANS-DRIVE 'MERROR 'MERROR-TRANSLATE)
(PUT-SOURCE-TRANS-DRIVE 'ERRRJF 'ERRRJF-TRANSLATE)
)

;;; Other systems won't get the syntax-checking at compile-time
;;; unless we hook into their way of doing optimizers.

