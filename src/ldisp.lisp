;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 10 -*- ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     The data in this file contains enhancments.                    ;;;;;
;;;                                                                    ;;;;;
;;;  Copyright (c) 1984,1987 by William Schelter,University of Texas   ;;;;;
;;;     All rights reserved                                            ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Auxiliary DISPLA package for doing 1-D display
;;;
;;; (c) 1979 Massachusetts Institute of Technology
;;;
;;; See KMP for details

(in-package "MAXIMA")
(declare-top (*EXPR MSTRING STRIPDOLLAR)
	 (SPECIAL LINEAR-DISPLAY-BREAK-TABLE FORTRANP))

#+Maclisp
(EVAL-WHEN (EVAL COMPILE)
	   (SSTATUS MACRO /# '+INTERNAL-/#-MACRO SPLICING))

;;; (LINEAR-DISPLA <thing-to-display>)
;;;
;;; Display text linearly. This function should be usable in any case
;;;  DISPLA is usable and will attempt to do something reasonable with
;;;  its input.


;;;The old linear-displa used charpos, not available in common lisp.
;;;It also did a much worse job on the display, breaking inside things
;;;like x^2.  --wfs

#+cl
(DEFUN LINEAR-DISPLA (X )
       (declare (special chrps))
       (fresh-line *standard-output*)
       (COND ((NOT (ATOM X))
	      (COND ((EQ (CAAR X) 'MLABLE)
		     (setq chrps 0)
		     (COND ((CADR X)
			    (princ "(")
			    (setq chrps
				  (+  3 (length (mgrind (cadr x) nil))))
			    (princ ") ")))
		     (MPRINT (MSIZE (caddr x) NIL NIL 'MPAREN 'MPAREN)
			     *standard-output*))
		    ((EQ (CAAR X) 'MTEXT)
		     (DO ((X (CDR X) (CDR X))
			  (FORTRANP))			; Atoms in MTEXT
			 ((NULL X))			;  should omit ?'s
			 (SETQ FORTRANP (ATOM (CAR X)))
			 ;(LINEAR-DISPLA1 (CAR X) 0.)
			 (mgrind (car x) *standard-output*)
			 ;(tyo #\space )
			 ))
		    (T
		     (mgrind x *standard-output*))))
	     (T
	      (mgrind X *standard-output*)))
        (TERPRI))



;;; (LINEAR-DISPLA <thing-to-display>)
;;;
;;; Display text linearly. This function should be usable in any case
;;;  DISPLA is usable and will attempt to do something reasonable with
;;;  its input.
#-cl
(DEFUN LINEAR-DISPLA (X)
       (TERPRI)
       (COND ((NOT (ATOM X))
	      (COND ((EQ (CAAR X) 'MLABLE)
		     (COND ((CADR X)
			    (PRIN1 (LIST (STRIPDOLLAR (CADR X))))
			    (TYO #\space)))
		     (LINEAR-DISPLA1 (CADDR X) (CHARPOS T)))
		    ((EQ (CAAR X) 'MTEXT)
		     (DO ((X (CDR X) (CDR X))
			  (FORTRANP))			; Atoms in MTEXT
			 ((NULL X))			;  should omit ?'s
			 (SETQ FORTRANP (ATOM (CAR X)))
			 (LINEAR-DISPLA1 (CAR X) 0.)
			 ;(TYO #\space)
			 ))
		    (T
		     (LINEAR-DISPLA1 X 0.))))
	     (T
	      (LINEAR-DISPLA1 X 0.)))
        (TERPRI))


;;********** old linear-displa *************
;;; LINEAR-DISPLAY-BREAK-TABLE
;;;  Table entries have the form (<char> . <illegal-predecessors>)
;;;
;;;  The linear display thing will feel free to break BEFORE any
;;;  of these <char>'s unless they are preceded by one of the
;;;  <illegal-predecessor> characters.

#-cl
(SETQ LINEAR-DISPLAY-BREAK-TABLE
      '((#\= #\: #\=)
	(#. left-parentheses-char #. left-parentheses-char #\[)
	(#. right-parentheses-char #. right-parentheses-char #\])
	(#\[ #. left-parentheses-char #\[)
	(#\] #. right-parentheses-char #\])
	(#\: #\:)
	(#\+ #\E #\B)
	(#\- #\E #\B)
	(#\* #\*)
	(#\^)))
	
;;; (FIND-NEXT-BREAK <list-of-fixnums>)
;;;   Tells how long it will be before the next allowable
;;;   text break in a list of chars.

#-cl
(DEFUN FIND-NEXT-BREAK (L)
       (DO ((I 0. (f1+ I))
	    (TEMP)
	    (L L (CDR L)))
	   ((NULL L) I)
	   (COND ((zl-MEMBER (CAR L) '(#\SPACE #\,)) (RETURN I))
		 ((AND (SETQ TEMP (ASSQ (CADR L) LINEAR-DISPLAY-BREAK-TABLE))
		       (NOT (MEMQ (CAR L) (CDR TEMP))))
		  (RETURN I)))))

;;; (LINEAR-DISPLA1 <object> <indent-level>)
;;;  Displays <object> as best it can on this line.
;;;  If atom is too long to go on line, types # and a carriage return.
;;;  If end of line is found and an elegant break is seen 
;;;   (see FIND-NEXT-BREAK), it will type a carriage return and indent
;;;   <indent-level> spaces.
#-cl
(DEFUN LINEAR-DISPLA1 (X INDENT)
       (LET ((CHARS (MSTRING X)))
	    (DO ((END-COLUMN  (f- (LINEL T) 3.))
		 (CHARS CHARS (CDR CHARS))
		 (I (CHARPOS T) (f1+ I))
		 (J (FIND-NEXT-BREAK CHARS) (f1- J)))
		((NULL CHARS) T)
		(TYO (CAR CHARS))
		(COND ((< J 1)
		       (SETQ J (FIND-NEXT-BREAK (CDR CHARS)))
		       (COND ((> (f+ I J) END-COLUMN)
			      (TERPRI)
			      (DO ((I 0. (f1+ I))) ((= I INDENT)) (TYO #\space))
			      (SETQ I INDENT))))
		      ((= I END-COLUMN)
		       (PRINC '/#)
		       (TERPRI)
		       (SETQ I -1.))))))
