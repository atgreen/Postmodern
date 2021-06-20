;;;; -*- Mode: LISP; Syntax: Ansi-Common-Lisp; Base: 10; Package: POSTMODERN-TESTS; -*-
(in-package :postmodern-tests)

(def-suite :postmodern-daos
    :description "Dao suite for postmodern"
    :in :postmodern)

(in-suite :postmodern-daos)

(defclass test-data ()
  ((id :col-type serial :initarg :id :accessor test-id)
   (a :col-type (or (varchar 100) db-null) :initarg :a :accessor test-a)
   (b :col-type boolean :col-default nil :initarg :b :accessor test-b)
   (c :col-type integer :col-default 0 :initarg :c :accessor test-c)
   (d :col-type numeric :col-default 0.0 :initarg :d :accessor test-d))
  (:metaclass postmodern:dao-class)
  (:table-name dao-test)
  (:keys id))

;; This class has fewer slots than the database table has fields
(defclass test-data-short ()
  ((id :col-type serial :initarg :id :accessor test-id)
   (a :col-type (or (varchar 100) db-null) :initarg :a :accessor test-a))
  (:metaclass postmodern:dao-class)
  (:table-name dao-test)
  (:keys id))

;; This class is short and has a slot that has a col-type different than the database table
;; slot a has a numeric col-type, but in the database table it is a string
;; Postmodern col-types do not control the actual parameter type.
;; THIS SHOULD BE REVISITED WHEN WE DO THE BINARY PARAMETERS
(defclass test-data-short-wrong-col-type ()
  ((id :col-type serial :initarg :id :accessor test-id)
   (a :col-type (or numeric db-null) :initarg :a :accessor test-a))
  (:metaclass postmodern:dao-class)
  (:table-name dao-test)
  (:keys id))

;; This class has the same number of slots, but one is the wrong type
;; Postmodern col-types do not control the actual parameter type.
;; THIS SHOULD BE REVISITED WHEN WE DO THE BINARY PARAMETERS
(defclass test-data-d-string ()
  ((id :col-type serial :initarg :id :accessor test-id)
   (a :col-type (or (varchar 100) db-null) :initarg :a :accessor test-a)
   (b :col-type boolean :col-default nil :initarg :b :accessor test-b)
   (c :col-type integer :col-default 0 :initarg :c :accessor test-c)
   (d :col-type text :col-default "" :initarg :d :accessor test-d))
  (:metaclass postmodern:dao-class)
  (:table-name dao-test)
  (:keys id))

(defclass test-data-multicolumn-key ()
  ((id :col-type serial :initarg :id :accessor test-id)
   (a :col-type (or (varchar 100) db-null) :initarg :a :accessor test-a)
   (b :col-type boolean :col-default nil :initarg :b :accessor test-b)
   (c :col-type integer :col-default 0 :initarg :c :accessor test-c)
   (d :col-type numeric :col-default 0.0 :initarg :d :accessor test-d))
  (:metaclass postmodern:dao-class)
  (:table-name dao-test-mk)
  (:keys id a))

(defclass test-data-not-serial-key ()
  ((id :col-type integer :initarg :id :accessor id)
   (username :col-type text :unique t  :initarg :username :accessor username)
   (department-id :col-type integer :initarg :department-id :accessor department-id))
  (:metaclass dao-class)
  (:table-name users1)
  (:keys username))

(defclass test-data-col-identity ()
  ((id :col-type integer :col-identity t :accessor id)
   (username :col-type text :unique t  :initarg :username :accessor username)
   (department-id :col-type integer :initarg :department-id :accessor department-id))
  (:metaclass dao-class)
  (:table-name users1)
  (:keys username))

(defclass test-data-col-primary-key ()
  ((id :col-type integer  :accessor id)
   (username :col-type text :col-primary-key t :unique t  :initarg :username :accessor username)
   (department-id :col-type integer :initarg :department-id :accessor department-id))
  (:metaclass dao-class)
  (:table-name users1))

(defclass test-data-col-identity-no-keys ()
  ((id :col-type integer :col-identity t :accessor id)
   (username :col-type text :unique t  :initarg :username :accessor username)
   (department-id :col-type integer :initarg :department-id :accessor department-id))
  (:metaclass dao-class)
  (:table-name users1))

(defclass test-data-col-identity-with-references ()
  ((id :col-type integer :col-identity t :accessor id)
   (username :col-type text :unique t :initarg :username :accessor username)
   (department-id :col-type integer :col-references ((departments id))
                  :initarg :department-id :accessor department-id))
  (:metaclass dao-class)
  (:table-name usersr))

(defclass test-data-department ()
  ((id :col-type integer :col-identity t :accessor id)
   (department-name :col-type text :unique t :initarg :department-name :accessor department-name))
  (:metaclass dao-class)
  (:table-name departments))

(defclass from-test-data ()
        ((id :col-type serial :initarg :id :accessor id)
         (flight :col-type (or integer db-null) :initarg :flight :accessor flight)
         (from :col-type (or (varchar 100) db-null) :initarg :from :accessor from)
         (to-destination :col-type (or (varchar 100) db-null)
                         :initarg :to-destination :accessor to-destination))
        (:metaclass dao-class)
        (:table-name from-test)
        (:keys id from))

(defun dao-test-table-fixture ()
  "Drops and recreates the dao-test table"
  (when (table-exists-p 'dao-test)
    (query (:drop-table :if-exists 'dao-test :cascade)))
  (execute (dao-table-definition 'test-data)))

(defmacro with-dao-test-table-fixture (&body body)
  `(progn
     (dao-test-table-fixture)
     (unwind-protect (progn ,@body)
       (execute (:drop-table :if-exists 'dao-test :cascade)))))

(defun dao-test-table-fixture-mk ()
  "Drops and recreates the dao-test-mk table"
  (when (table-exists-p 'dao-test-mk)
    (query (:drop-table :if-exists 'dao-test-mk :cascade)))
  (execute (dao-table-definition 'test-data-multicolumn-key)))

(defmacro with-dao-test-table-fixture-mk (&body body)
  `(progn
     (dao-test-table-fixture-mk)
     (unwind-protect (progn ,@body)
       (execute (:drop-table 'dao-test-mk :cascade)))))

(defun dao-test-table-fixture-references ()
  "Drops and recreates the usersr and departments tables"
  (when (table-exists-p 'usersr)
    (query (:drop-table :if-exists 'usersr :cascade)))
  (when (table-exists-p 'departments)
    (query (:drop-table :if-exists 'departments :cascade)))
  (execute (dao-table-definition 'test-data-department))
  (execute (dao-table-definition 'test-data-col-identity-with-references)))

(defmacro with-dao-test-table-fixture-references (&body body)
  `(progn
     (dao-test-table-fixture-references)
     (unwind-protect (progn ,@body)
       (execute (:drop-table 'usersr :cascade))
       (execute (:drop-table 'departments :cascade)))))

(defun dao-test-table-fixture-not-serial-key ()
  "Drops and recreates the users1 table"
  (when (table-exists-p 'users1)
    (query (:drop-table :if-exists 'users1 :cascade)))
  (execute (dao-table-definition 'test-data-not-serial-key)))

(defmacro with-dao-test-table-fixture-not-serial-key (&body body)
  `(progn
     (dao-test-table-fixture-not-serial-key)
     (unwind-protect (progn ,@body)
       (execute (:drop-table 'users1 :cascade)))))

(test dao-class
  (with-test-connection
    (with-dao-test-table-fixture
    (is (equal (dao-table-definition 'test-data)
               "CREATE TABLE dao_test (id SERIAL NOT NULL, a VARCHAR(100) DEFAULT NULL, b BOOLEAN NOT NULL DEFAULT false, c INTEGER NOT NULL DEFAULT 0, d NUMERIC NOT NULL DEFAULT 0.0, PRIMARY KEY (id))"))
    (is (equal (dao-keys (find-class 'test-data))
               '(ID)))
    (is (equal (dao-keys (make-instance 'test-data :id 1))
               '(1)))
    (is (member :dao-test (list-tables)))
    (is (null (select-dao 'test-data)))
    (protect
     (let ((dao (make-instance 'test-data :a "quux")))
       (signals error (test-id dao))
       (insert-dao dao)
       (is (dao-exists-p dao))
       (let* ((id (test-id dao))
              (database-dao (get-dao 'test-data id)))
         (is (not (null database-dao)))
         (is (eql (test-id dao) (test-id database-dao)))
         (is (string= (test-a database-dao) "quux"))
         (setf (test-b dao) t)
         (update-dao dao)
         (let ((new-database-dao (get-dao 'test-data id)))
           (is (eq (test-b new-database-dao) t))
           (is (eq (test-b database-dao) nil))
           (delete-dao dao)))
       (is (not (select-dao 'test-data))))))))

(test dao-keys
  "Explicit keys takes priority over col-identity which takes priority over col-primary-key"
  (is (equal (dao-keys (find-class 'test-data))
             '(ID)))
  (is (equal (dao-keys (find-class 'test-data-col-identity))
             '(USERNAME)))
  (is (equal (dao-keys (find-class 'test-data-col-identity-no-keys))
             '(ID)))
  (is (equal (dao-keys (find-class 'test-data-col-primary-key))
             '(USERNAME))))

(test single-column-primary-keys
  (with-test-connection
    (with-dao-test-table-fixture
      (let ((dao (make-instance 'test-data :a "quux"))
            (dao-col-identity (make-instance 'test-data-not-serial-key :a "quux-ci")))
        (is (equal (find-primary-key-column 'test-data)
                   nil))
        (is (equal (find-primary-key-column dao-col-identity)
                   nil))
        (is (equal (find-primary-key-column dao)
                   nil))
        (is (equal (find-primary-key-column 'test-data-col-identity)
                   'id))
        (is (equal (find-primary-key-column
                    (class-of (make-instance 'test-data-col-identity)))
                   'id))
        (is (equal (pomo::dao-keys 'test-data)
                   '(id)))
        (is (equal (find-primary-key-info
                    (dao-table-name
                     (class-of (make-instance 'test-data :a "quux"))))
                   '(("id" "integer"))))
        (is (equal (dao-keys 'test-data)
                   '(id)))))))

(test multi-column-primary-keys
  (with-test-connection
    (with-dao-test-table-fixture-mk
      (dao-test-table-fixture-mk)
      (is (equal (find-primary-key-column 'test-data-multicolumn-key)
                 nil))
      (is (equal (find-primary-key-info 'dao-test-mk)
                 '(("id" "integer") ("a" "character varying(100)"))))
      (is (equal (dao-keys 'test-data-multicolumn-key)
                 '(id a))))))

(test dao-column-slots
  (is (equal (mapcar #'pomo::slot-definition-name
                     (pomo::dao-column-slots
                      (class-of (make-instance 'test-data-col-identity
                                               :id 1
                                               :username "duck"
                                               :department-id 1))))
             '(ID USERNAME DEPARTMENT-ID)))
  (is (equal (mapcar #'pomo::slot-definition-name
                      (pomo::dao-column-slots (find-class 'test-data-col-identity)))
             '(ID USERNAME DEPARTMENT-ID))))

(test dao-column-fields
  (is (equal (pomo::dao-column-fields (find-class 'test-data-col-identity))
             '(ID USERNAME DEPARTMENT-ID)))
  (is (equal (pomo::dao-column-fields
              (class-of
               (make-instance 'test-data-col-identity
                              :id 1 :username "duck" :department-id 1)))
             '(ID USERNAME DEPARTMENT-ID))))

(test dao-table-name
  (is (equal (dao-table-name 'test-data-col-identity)
             'USERS1)))

(test dao-superclasses
  (is (equal (class-name
              (class-of (first (pomo::dao-superclasses (find-class 'test-data-col-identity)))))
               'dao-class)))

(test insert-dao-base
  (with-test-connection
    (with-dao-test-table-fixture
      (progn
        (insert-dao (make-instance 'test-data :a "unbound-stuff-here"))
        (is (equal (query "select * from dao_test")
                   '((1 "unbound-stuff-here" NIL 0 0))))
        ;; The following will trigger a duplicate key error
        (signals error (insert-dao (make-instance 'test-data :id 1 :a "unbound-stuff-here")))
        (is (equal (query "select * from dao_test")
                   '((1 "unbound-stuff-here" NIL 0 0))))
        (signals error (insert-dao (make-instance 'test-data :id 1 :a "bar" :b t :c 17 :d 13.2)))
        (is (equal (query "select * from dao_test")
                   '((1 "unbound-stuff-here" NIL 0 0))))
        (insert-dao (make-instance 'test-data :a "bar" :b t :c 17 :d 13.2))
        (is (equal (query "select * from dao_test")
                   '((1 "unbound-stuff-here" NIL 0 0) (2 "bar" T 17 66/5))))))))

(test save-dao-base
  (with-test-connection
    (with-dao-test-table-fixture
     (let ((dao (make-instance 'test-data :a "quux")))
       (is (save-dao dao)) ; returns a boolean to indicate a new row was inserted
       (setf (test-a dao) "bar")
       (is (equal (test-id dao)
                  1))
       (is (equal (test-d dao)
                  0))
       (is (not (save-dao dao))) ; returns boolean nil showing no new row was inserted
       (is (equal (test-a (get-dao 'test-data (test-id dao))) "bar"))))))

(test save-dao-with-transaction
  (with-test-connection
    (with-dao-test-table-fixture
      (let ((dao (make-instance 'test-data :a "quux")))
        (with-transaction ()
          (save-dao dao))
        (is (equal (query "select * from dao_test")
                    '((1 "quux" NIL 0 0))))
       (setf (test-a dao) "bar")
       (signals database-error
                (with-transaction ()
                  (save-dao dao)))
       (with-transaction ()
         (is (equal (query "select * from dao_test")
                    '((1 "quux" NIL 0 0))))
         (is (not (save-dao/transaction dao)))
         (is (equal (query "select * from dao_test")
                    '((1 "bar" NIL 0 0)))))))))

(test save-dao-with-same-key
  (with-test-connection
    (with-dao-test-table-fixture
     (let ((dao (make-instance 'test-data :a "quux")))
       (save-dao dao)
       (is (equal (test-id dao)
                  1))
       (is (equal (query "select * from dao_test")
                  '((1 "quux" NIL 0 0))))
       (setf (test-a dao) "bar")
       (save-dao dao)
       (is (equal (query "select * from dao_test")
                  '((1 "bar" NIL 0 0))))))))

(test save-dao-smaller-than-table
  (with-test-connection
    (with-dao-test-table-fixture
      (let ((short-dao (make-instance 'test-data-short :a "first short")))
       (save-dao short-dao)
       (is (equalp (query (:select '* :from 'dao-test) :alists)
                   '(((:ID . 1) (:A . "first short") (:B) (:C . 0) (:D . 0)))))
        (setf *ignore-unknown-columns* t)
        (is (equal (test-a (get-dao 'test-data-short 1))
                   "first short"))
        (setf *ignore-unknown-columns* nil)))))

(test save-short-dao-with-bad-col-type
  (with-test-connection
    (with-dao-test-table-fixture
     (let ((dao-short-wrong (make-instance 'test-data-short-wrong-col-type :a 12.75)))
       (save-dao dao-short-wrong)
       (is (equalp (query (:select '* :from 'dao-test) :alists)
                   '(((:ID . 1) (:A . "12.75") (:B) (:C . 0) (:D . 0)))))))))

(test save-dao-with-bad-col-type
  "Tests saving a dao when slot d, accessor test-d has a text col-type and the table is numeric."
  (with-test-connection
    (with-dao-test-table-fixture
      (progn
        (let ((dao-d-string (make-instance 'test-data-d-string :a "D string" :b nil :c 14
                                                               :d "abcd")))
          (signals error (save-dao dao-d-string)) ; invalid type
          (setf (test-d dao-d-string) "18.75")
          (save-dao dao-d-string)
          (is (equal (query (:select '* :from 'dao-test))
                     '((1 "D string" NIL 14 75/4))))
          (setf (test-d dao-d-string) 18.75)
          (save-dao dao-d-string)
          (is (equal (query (:select '* :from 'dao-test))
                     '((1 "D string" NIL 14 75/4)))))))))

(test save-dao-with-col-identity
  "Note the difference between make-instance and make-dao"
  (with-test-connection
    (dao-test-table-fixture-references)
    (with-dao-test-table-fixture-references
      (let ((dao (make-dao 'test-data-department :department-name "Math")))
        (is (equal (query "select * from departments")
                   '((1 "Math"))))
        (setf (department-name dao) "German")
        (signals error (save-dao dao)) ; save-dao tries to insert and cannot insert over the id
        (update-dao dao)
        (is (equal (query "select * from departments")
                   '((1 "German"))))
        (insert-dao (make-instance 'test-data-department :department-name "Philosophy"))
        (is (equal (query "select * from departments")
                   '((1 "German") (2 "Philosophy"))))
        (make-dao 'test-data-department :department-name "Economics")
        (is (equal (query "select * from departments")
                   '((1 "German") (2 "Philosophy") (3 "Economics"))))
        (let ((dao (make-instance 'test-data-department :department-name "Geopolitics")))
          (upsert-dao dao))
        (is (equal (query "select * from departments")
                   '((1 "German") (2 "Philosophy") (3 "Economics") (4 "Geopolitics"))))))))

(test returning-different-dao-types
  "Demonstrates that daos do not enforce slot types. The database will enforce the slot types
so there is a single source of type truth."
  (with-test-connection
    (with-dao-test-table-fixture
      (progn
        (let ((dao-d-string (make-instance 'test-data-d-string :a "D string" :b nil :c 14
                                                               :d "18.75")))
          (save-dao dao-d-string)
          (is (equal (query (:select '* :from 'dao-test))
                     '((1 "D string" NIL 14 75/4)))))
        (is (equal (type-of (query (:select '* :from 'dao-test)
                                   (:dao test-data :single)))
                   'TEST-DATA))
        (is (equal (type-of (query (:select '* :from 'dao-test)
                                   (:dao test-data-d-string :single)))
                   'TEST-DATA-D-STRING))
        (is (equal (test-d (query (:select '* :from 'dao-test)
                                  (:dao test-data-d-string :single)))
                   75/4))))))

(test update-dao
  (with-test-connection
    (with-dao-test-table-fixture
      (progn
        (save-dao (make-instance 'test-data :id 1 :a "bar"))
        ;; error signaled next line due to trying to update using a dao with unbounded slots
        (signals error (update-dao (make-instance 'test-data :id 1 :a "bar")))
        (update-dao (make-instance 'test-data :id 1 :a "bar" :b t :c 17 :d 13.2))
        (is (equal (query "select * from dao_test")
                   '((1 "bar" T 17 66/5))))))))

(test save-upsert-dao-with-serial
  (with-test-connection
    (with-dao-test-table-fixture
     (let ((dao (make-instance 'test-data :a "quux")))
       (save-dao dao)
       (is (equal (query "select * from dao_test")
                  '((1 "quux" NIL 0 0))))
       (is (equal (test-a (get-dao 'test-data (test-id dao))) "quux"))
       (setf (test-a dao) "bar")
       (upsert-dao dao)
       (is (equal (test-a (get-dao 'test-data (test-id dao))) "bar"))
       (is (equal (query "select * from dao_test")
                  '((1 "bar" NIL 0 0))))
       (signals error (update-dao (make-instance 'test-data :id 1 :a "cover?"))) ; unbound :b
       (signals error (upsert-dao (make-instance 'test-data :id 1 :a "cover?"))) ; duplicate key
       (upsert-dao (make-instance 'test-data :a "cover?"))
       (is (equal (query "select * from dao_test")
                  '((1 "bar" NIL 0 0) (2 "cover?" NIL 0 0))))))))

(test save-upsert-dao-not-serial
  (with-test-connection
    (with-dao-test-table-fixture-not-serial-key
     (let ((dao (make-instance 'test-data-not-serial-key :id 1 :username "duck")))
       (signals error (save-dao dao)) ; unbound department-id
       (setf (department-id dao) 12)
       (save-dao dao)
       (is (equal (query "select * from users1")
                  '((1 "duck" 12))))
       (is (equal (username (get-dao 'test-data-not-serial-key (username dao)))
                  "duck"))
       (setf (department-id dao) 13)
       (upsert-dao dao)
       (is (equal (query "select * from users1")
                  '((1 "duck" 13))))
       (setf (username dao) "goose")
       (setf (department-id dao) 17)
       (upsert-dao dao)
       (is (equal (query "select * from users1")
            '((1 "duck" 13) (1 "goose" 17))))
       (is (equal (department-id (get-dao 'test-data-not-serial-key (username dao)))
                  17))
       (signals error (update-dao (make-instance 'test-data-not-serial-key
                                   :id 1 :username "turkey" :department-id 43)))
       ;; update row does not exist
       (is (equal (query "select * from users1")
               '((1 "duck" 13) (1 "goose" 17))))
       (upsert-dao (make-instance 'test-data-not-serial-key
                                  :id 1 :username "chicken" :department-id 3))
       (is (equal (query "select * from users1")
                  '((1 "duck" 13) (1 "goose" 17) (1 "chicken" 3))))
       (upsert-dao (make-instance 'test-data-not-serial-key
                                  :id 1 :username "duck" :department-id 3))
       (is (equal (query "select * from users1")
                  '((1 "goose" 17) (1 "chicken" 3) (1 "duck" 3))))
       (update-dao (make-instance 'test-data-not-serial-key
                                  :id 1 :username "chicken" :department-id 3))
       (is (equal (query "select * from users1")
               '((1 "goose" 17) (1 "duck" 3) (1 "chicken" 3))))
       (upsert-dao (make-instance 'test-data-not-serial-key
                                  :id 1 :username "penguin" :department-id 43))
       (is (equal (query "select * from users1")
               '((1 "goose" 17) (1 "duck" 3) (1 "chicken" 3) (1 "penguin" 43))))
       (signals error (update-dao (make-instance 'test-data-not-serial-key
                                                 :id 1 :username "turkey" :department-id 43)))
       ;; still no turkey to update
       (is (equal (query "select * from users1")
                  '((1 "goose" 17) (1 "duck" 3) (1 "chicken" 3) (1 "penguin" 43))))))))

(test dao-create-table-with-references
  (is (equal (dao-table-definition 'test-data-col-identity-with-references)
             "CREATE TABLE usersr (id INTEGER NOT NULL PRIMARY KEY generated always as identity, username TEXT NOT NULL, department_id INTEGER NOT NULL REFERENCES departments(id) MATCH SIMPLE ON DELETE RESTRICT ON UPDATE RESTRICT)"))
  (with-test-connection
    (with-dao-test-table-fixture-references
      (progn
        (signals error (insert-dao (make-instance 'test-data--col-identity-with-references
                                                  :username "user-1" :department-id 1)))
        (insert-dao (make-instance 'test-data-department :department-name "department 1"
                                                         :department-id 1))
        (insert-dao (make-instance 'test-data-col-identity-with-references
                                   :username "user-1" :department-id 1))
        (is (equal (query "select * from usersr")
                   '((1 "user-1" 1))))
        (is (equal (username (get-dao 'test-data-col-identity-with-references 1))
                   "user-1"))))))

(test query-drop-table-1
  (with-test-connection
    (with-dao-test-table-fixture
     (is (member :dao-test (pomo:list-tables)))
     (pomo:query (:drop-table :dao-test))
     (is (not (member :dao-test (pomo:list-tables)))))))

(defclass test-col-name ()
  ((a :col-type string :col-name aa :initarg :a :accessor test-a)
   (b :col-type string :col-name bb :initarg :b :accessor test-b)
   (c :col-type string              :initarg :c :accessor test-c)
   (from :col-type string :col-name from :initarg :d :accessor test-d)
   (to-destination :col-type string :col-name to :initarg :e :accessor test-e))
  (:metaclass dao-class)
  (:keys a))

(test dao-class-col-name
  "Test the use of col-name in daos"
  (with-test-connection
    (execute "CREATE TEMPORARY TABLE test_col_name (aa text primary key, bb text not null, c text not null,
              \"from\" text not null, \"to\" text not null)")
    (let ((o (make-instance 'test-col-name :a "1" :b "2" :c "3" :d "Reykjavík" :e "Garðabær")))
      (save-dao o)
      (is (equal (query "select * from test_col_name" :alists)
                 '(((:AA . "1") (:BB . "2") (:C . "3") (:FROM . "Reykjavík") (:TO . "Garðabær")))))
      (let ((oo (get-dao 'test-col-name "1")))
        (is (string= "1" (test-a oo)))
        (is (string= "2" (test-b oo)))
        (is (string= "3" (test-c oo)))
        (is (string= "Reykjavík" (test-d oo)))
        (is (string= "Garðabær" (test-e oo)))))
    (let ((o (get-dao 'test-col-name "1")))
      (setf (test-b o) "b")
      (setf (test-d o) "Vestmannaeyjar")
      (update-dao o))
    (is (string= "1" (test-a (get-dao 'test-col-name "1"))))
    (is (string= "b" (test-b (get-dao 'test-col-name "1"))))
    (is (string= "3" (test-c (get-dao 'test-col-name "1"))))
    (is (string= "Vestmannaeyjar" (test-d (get-dao 'test-col-name "1")))))
  (with-test-connection
    (execute "CREATE TEMPORARY TABLE test_col_name (aa text primary key default md5(random()::text), bb text not null, c text not null,
              \"from\" text not null, \"to\" text not null)")
    (let ((o (make-instance 'test-col-name :b "2" :c "3" :d "Reykjavík" :e "Garðabær")))
      (finishes
        (insert-dao o)))))

;;; For threading tests
(defvar *dao-update-lock* (bt:make-lock))

(defun make-class (name)
  (eval `(defclass ,(intern name) ()
           ((id :col-type serial :initarg :id :accessor test-id)
            (a :col-type (or (varchar 100) db-null) :initarg :a :accessor test-a)
            (b :col-type boolean :col-default nil :initarg :b :accessor test-b)
            (c :col-type integer :col-default 0 :initarg :c :accessor test-c))
           (:metaclass dao-class)
           (:table-name dao-test)
           (:keys id))))

(test make-class
  (let ((a (make-class (write-to-string (gensym)))))
    (is (not (equal nil (make-instance a :id 12 :a "six" :b t))))))

(test dao-class-threads
  (with-test-connection
    (with-dao-test-table-fixture
      (unless (pomo:table-exists-p 'dao-test)
        (execute (dao-table-definition 'test-data)))
    (let ((item (make-instance 'test-data :a "test-name" :b t :c 0))
          (threads '()))
      (save-dao item)
      (loop for x from 1 to 5
         do (push (bt:make-thread
                   (lambda ()
                     (with-test-connection
                         (loop repeat 5
                            do (bt:with-lock-held (*dao-update-lock*)
                                 (incf (test-c item) 1)
                                 (upsert-dao item))))
                     (with-test-connection
                         (loop repeat 5
                            do (bt:with-lock-held (*dao-update-lock*)
                                 (decf (test-c item) 1)
                                 (upsert-dao item))))))
                  threads))
      (mapc #'bt:join-thread threads)
      (is (eq 0 (test-c item)))))))

(test reserved-column-names-defclass
  (with-test-connection
    (when (pomo:table-exists-p "from-test")
      (execute (:drop-table "from-test" :cascade)))
    (when (pomo:table-exists-p 'from-test-data1)
      (execute (:drop-table 'from-test-data1 :cascade)))
    (when (pomo:table-exists-p 'iceland-cities)
      (execute (:drop-table 'iceland-cities :cascade)))
    (is (equal (dao-table-definition 'from-test-data)
               "CREATE TABLE from_test (id SERIAL NOT NULL, flight INTEGER DEFAULT NULL, \"from\" VARCHAR(100) DEFAULT NULL, to_destination VARCHAR(100) DEFAULT NULL, PRIMARY KEY (id, \"from\"))"))
    (execute (dao-table-definition 'from-test-data))
    (is (equal (pomo:list-columns 'from-test)
               '("id" "flight" "from" "to_destination")))
    (is (equal (pomo:find-primary-key-info 'public.from-test)
               '(("id" "integer") ("from" "character varying(100)"))))
    (let*  ((item1
              (make-instance 'from-test-data
                             :flight 1 :from "Reykjavík" :to-destination "Seyðisfjörður"))
            (item2
              (make-instance 'from-test-data
                             :flight 2 :from "Stykkishólmur" :to-destination "Reykjavík"))
            (item3
              (make-instance 'from-test-data
                             :flight 3 :from "Stykkishólmur" :to-destination "Reykjavík")))
      (is (equal "Reykjavík" (from item1)))
      (is (equal "Seyðisfjörður" (to-destination item1)))
      (insert-dao item1)
      (is (equal (query (:select 'from :from 'from-test :where (:= 'flight 1)) :single)
                 "Reykjavík"))
      (setf (to-destination item1) "Bolungarvík")
      (update-dao item1)
      (is (equal (query (:select 'to-destination :from 'from-test :where (:= 'flight 1)) :single)
                 "Bolungarvík"))
      (save-dao item2)
      (is (equal (query (:select 'to-destination :from 'from-test :where (:= 'flight 2)) :single)
                 "Reykjavík"))
      (setf (to-destination item1) "Stykkishólmur")
      (upsert-dao item2)
      (is (equal (query (:select 'from 'to-destination :from 'from-test :where (:= 'flight 1)))
                 '(("Reykjavík" "Bolungarvík"))))
      (upsert-dao item3)
      (is (equal (query (:select 'from 'to-destination :from 'from-test :where (:= 'flight 3)))
                 '(("Stykkishólmur" "Reykjavík"))))
      (is (equal (from (get-dao 'from-test-data 1 "Reykjavík")) "Reykjavík"))
      (delete-dao item3)
      (is (not (get-dao 'from-test-data 3 "Stykkishólmur")))
      (execute (:drop-table 'from-test :cascade)))))

(test fetch-defaults
  (with-test-connection
    (with-dao-test-table-fixture
      (let ((dao (make-instance 'test-data :a "something"))
            (short-dao (make-instance 'test-data-short)))
        (signals error (test-b  dao))    ; unbound slot b
        (pomo:fetch-defaults dao)
        (is (equal (test-b dao)
                   nil))
        (is (equal (test-c dao)
                  0))
        (signals error (test-id short-dao))
        (pomo:fetch-defaults short-dao)
        (signals error (test-id short-dao))))))

(test generate-dao-query
  (is (equal (pomo::generate-dao-query 'test-data)
             '(:SELECT '* :FROM (DAO-TABLE-NAME (FIND-CLASS TEST-DATA)) :WHERE T))))

(test select-dao
  (with-test-connection
    (with-dao-test-table-fixture
      (progn
        (make-dao 'test-data :a "dao1")
        (make-dao 'test-data :a "dao2")
        (is (equal (query "select * from dao_test")
                   '((1 "dao1" NIL 0 0) (2 "dao2" NIL 0 0))))
        (is (equal (mapcar #'test-a (select-dao 'test-data))
                   '("dao1" "dao2")))))))

(test do-select-dao
  (with-test-connection
    (with-dao-test-table-fixture
      (progn
        (make-dao 'test-data :a "dao1")
        (make-dao 'test-data :a "dao2")
        (is (equal (query "select * from dao_test")
                   '((1 "dao1" NIL 0 0) (2 "dao2" NIL 0 0))))
        (do-select-dao (('test-data dao))
          (progn
            (setf (test-c dao) 2)
            (signals error (update-dao dao))
            (with-test-connection
              ;; without a new connection, this errors because the previous connection is not done
              (update-dao dao))))
        (is (equal (query "select * from dao_test")
                   '((1 "dao1" NIL 2 0) (2 "dao2" NIL 2 0))))))))

;; Import/Export Function tests

(test find-dao-column-slot
  (is (pomo::find-dao-column-slot (find-class 'test-data) 'id))
  (is (equal (pomo::find-dao-column-slot (find-class 'test-data) 'george)
             nil)))

(test find-col-type
  (is (eq (pomo::find-col-type (find-class 'test-data) 'id)
          'serial)))

(test col-type-text-p
  (is (equal (pomo::col-type-text-p
              (pomo::find-dao-column-slot
               (find-class 'test-data-d-string)
               'd))
       t)))

;; Need to test insert, upsert, update with export functions (text and other formats

(defclass listy ()
  ((id :col-type integer :col-identity t :accessor id)
   (name :col-type text :col-unique t :col-check (:<> 'name "")
         :initarg :name :accessor name)
   (rlist :type list :col-type (or text db-null) :initarg :rlist :accessor rlist
          :col-export list-to-string :col-import dao-string-to-list)
   (alist :type alist :col-type (or text db-null) :initarg :alist :accessor alist
          :col-export list-to-string :col-import dao-string-to-alist)
   (plist :type plist :col-type (or text db-null) :initarg :plist :accessor plist
          :col-export list-to-string :col-import dao-string-to-plist))
  (:metaclass dao-class)
  (:table-name listy))

(defun dao-export-import-table-fixture ()
  "Drops and recreates the listy test table"
  (when (table-exists-p 'listy)
    (query (:drop-table :if-exists 'listy :cascade)))
  (execute (dao-table-definition 'listy)))

(defmacro with-dao-export-import-table-fixture (&body body)
  `(progn
     (dao-export-import-table-fixture)
     (unwind-protect (progn ,@body)
       (execute (:drop-table :if-exists 'listy :cascade)))))

(defun string-to-list (str)
  "Take a string representation of a list and return an lisp list.
Note that you need to handle :NULLs - I am making them unbound in this example"
  (cond ((eq str :NULL)
         :NULL)
        (str
         (with-input-from-string (s str) (read s)))
        (t nil)))

(defun dao-string-to-list (dao str)
  (if (eq str :NULL)
      (slot-makunbound dao 'rlist)
      (setf (slot-value dao 'rlist)
            (string-to-list str))))

(defun dao-string-to-alist (dao str)
  (if (eq str :NULL)
      (slot-makunbound dao 'alist)
      (setf (slot-value dao 'alist)
            (string-to-list str))))

(defun dao-string-to-plist (dao str)
  (if (eq str :NULL)
      (slot-makunbound dao 'plist)
      (setf (slot-value dao 'plist)
            (string-to-list str))))

(defun list-to-string (str)
  (if (listp str) (format nil "~a" str) "unknown"))

;; export data from a dao to a table using an export function
;; with and without null values
(test dao-insert-export
  (with-test-connection
    (with-dao-export-import-table-fixture
      (insert-dao (make-instance 'listy :name "first" :rlist '(a b c)
                                        :alist '((a 1) (b 2) (c 3))
                                        :plist '(a 1 b 2 c 3)))
      (insert-dao (make-instance 'listy :name "second" :rlist '(a b c)
                                        :plist '(a 1 b 2 c 3)))
      (is (equal (query "select rlist from listy where id = 1" :single)
                 "(A B C)"))
      (is (equal (query "select alist from listy where id = 1" :single)
                 "((A 1) (B 2) (C 3))"))
      (is (equal (query "select plist from listy where id = 1" :single)
                 "(A 1 B 2 C 3)"))
      (is (equal (query "select name, alist from listy where id = 2")
                 '(("second" :NULL)))))))

;; save-dao version of above
(test dao-save-export
  (with-test-connection
    (with-dao-export-import-table-fixture
      (save-dao (make-instance 'listy :name "first" :rlist '(a b c)
                                      :alist '((a 1) (b 2) (c 3))
                                      :plist '(a 1 b 2 c 3)))
      (save-dao (make-instance 'listy :name "second" :rlist '(a b c)
                                      :plist '(a 1 b 2 c 3)))
      (is (equal (query "select rlist from listy where id = 1" :single)
                 "(A B C)"))
      (is (equal (query "select alist from listy where id = 1" :single)
                 "((A 1) (B 2) (C 3))"))
      (is (equal (query "select plist from listy where id = 1" :single)
                 "(A 1 B 2 C 3)"))
      (is (equal (query "select name, alist from listy where id = 2")
                 '(("second" :NULL)))))))

;; import data from a table into a dao, using an import function
(test dao-get-with-import
  (with-test-connection
    (with-dao-export-import-table-fixture
      (insert-dao (make-instance 'listy :name "first" :rlist '(a b c)
                                        :alist '((a 1) (b 2) (c 3))
                                        :plist '(a 1 b 2 c 3)))
      (insert-dao (make-instance 'listy :name "second" :rlist '(a b c)
                                        :plist '(a 1 b 2 c 3)))
      (is (equal (name (get-dao 'listy 1))
                 "first"))
      (is (equal (rlist (get-dao 'listy 1))
                 '(A B C)))
      (is (equal (rlist (get-dao 'listy 1))
                 '(a b  C)))
      (is (equal (alist (get-dao 'listy 1))
                 '((A 1) (B 2) (C 3))))
      (is (equal (rlist (get-dao 'listy 2))
                 '(A B C)))
      (signals error (alist (get-dao 'listy 2))))))

(test select-dao-with-import
  (with-test-connection
    (with-dao-export-import-table-fixture
      (insert-dao (make-instance 'listy :name "first" :rlist '(a b c)
                                        :alist '((a 1) (b 2) (c 3))
                                        :plist '(a 1 b 2 c 3)))
      (insert-dao (make-instance 'listy :name "second" :rlist '(a b c)
                                        :plist '(a 1 b 2 c 3)))
      (is (equal (rlist (first (select-dao 'listy)))
                 '(A B C)))
      (is (equal (plist (second (select-dao 'listy)))
                 '(A 1 B 2 C 3))))))

(test query-dao-with-import
  (with-test-connection
    (with-dao-export-import-table-fixture
      (insert-dao (make-instance 'listy :name "first" :rlist '(a b c)
                                        :alist '((a 1) (b 2) (c 3))
                                        :plist '(a 1 b 2 c 3)))
      (insert-dao (make-instance 'listy :name "second" :rlist '(a b c)
                                        :plist '(a 1 b 2 c 3)))
      (is (equal (rlist (first (query-dao 'listy "select * from listy where id=1")))
                 '(A B C)))
      (is (equal (plist (first (query-dao 'listy "select * from listy where id=2")))
                 '(A 1 B 2 C 3)))
      (signals error (alist (first (query-dao 'listy "select * from listy where id=2")))))))

;; update a table from a modified dao
(test dao-update-export
  (with-test-connection
    (with-dao-export-import-table-fixture
      (insert-dao (make-instance 'listy :name "first" :rlist '(a b c)
                                        :alist '((a 1) (b 2) (c 3))
                                        :plist '(a 1 b 2 c 3)))
      (insert-dao (make-instance 'listy :name "second" :rlist '(a b c)
                                        :plist '(a 1 b 2 c 3)))
      (let ((dao1 (get-dao 'listy 1))
            (dao2 (get-dao 'listy 2)))
        (setf (rlist dao1) '(e f g))
        (update-dao dao1)
        (is (equal (query "select rlist from listy where id = 1" :single)
                   "(E F G)"))
        (setf (plist dao2) '("e" 1 f 4 g 7))
        (setf (alist dao2) nil)
        (update-dao dao2)
        (is (equal (query "select plist from listy where id = 2" :single)
                   "(e 1 F 4 G 7)"))
        (is (equal (query "select alist from listy where id = 2" :single)
                   nil))))))

;; upsert with an export function
(test dao-upsert-export
  (with-test-connection
    (with-dao-export-import-table-fixture
      (insert-dao (make-instance 'listy :name "first" :rlist '(a b c)
                                        :alist '((a 1) (b 2) (c 3))
                                        :plist '(a 1 b 2 c 3)))
      (insert-dao (make-instance 'listy :name "second" :rlist '(a b c)
                                        :plist '(a 1 b 2 c 3)))
      (upsert-dao (make-instance 'listy :name "third" :rlist '(a b c)
                                        :alist '(("a" 11) (b 12) (c "13c"))
                                        :plist '(a 1 b 2 c 3)))
      (is (equal (query "select alist from listy where id = 3" :single)
                 "((a 11) (B 12) (C 13c))")))))
