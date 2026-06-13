;;; =========================================================
;;; PROYECTO: Sistema de Semáforos Inteligentes
;;; MATERIA:  Paradigmas y Lenguajes
;;; GRUPO:    31
;;; ARCHIVO:  core.lisp
;;; =========================================================
;;; RESTRICCIONES ACTIVAS:
;;;   - Sin variables globales mutables (no defparameter/defvar para estado)
;;;   - Sin operadores destructivos (no setq/setf)
;;;   - Sin bucles imperativos (no loop/dolist/dotimes)
;;;   - Toda iteración via recursividad de cola o funciones de orden superior
;;; =========================================================



;; ---------------------------------------------------------
;; CONSTANTES DE CONFIGURACIÓN (no son estado, son configuración)
;; defconstant es la forma correcta — no viola la restricción de inmutabilidad
;; ---------------------------------------------------------
(defconstant +duracion-rojo+ 90)
(defconstant +duracion-amarillo+ 6)
(defconstant +duracion-verde+ 120)
(defconstant +duracion-ciclo-total+ 222)
(defconstant +duracion-intermitencia+ 3)


;; =========================================================
;; REQUERIMIENTO 1: Estados de Transición
;; =========================================================

;; --------------------------------------------------------
;; FUNCIÓN: transicion
;; NATURALEZA: Pura
;; ESTRATEGIA: Funcion Condicional (evalúa condiciones sobre los argumentos) 
;; IMPACTO:    No destructiva
;; --------------------------------------------------------
(defun transicion (color-actual cambiar-a)
  (cond 
    ((and(eq color-actual 'en-rojo) (eq cambiar-a 'intermitencia)) 
        (list color-actual "cambiar-a-intermitencia"))
    
    ((and(eq color-actual 'en-intermitencia) (eq cambiar-a 'verde))
        (list color-actual "cambiar-a-verde"))
    
    ((and(eq color-actual 'en-verde) (eq cambiar-a 'intermitencia)) 
        (list color-actual "cambiar-a-intermitencia"))

    ((and(eq color-actual 'en-intermitencia) (eq cambiar-a 'amarillo)) 
        (list color-actual "cambiar-a-amarillo"))

    ; originales:
    ((and(eq color-actual 'en-rojo) (eq cambiar-a 'verde))
        (list color-actual "cambiar-a-verde"))
    
    ((and(eq color-actual 'en-verde) (eq cambiar-a 'amarillo)) 
        (list color-actual "cambiar-a-amarillo"))

    ((and(eq color-actual 'en-amarillo) (eq cambiar-a 'rojo)) 
        (list color-actual "cambiar-a-rojo"))

     (t (list color-actual 'accion-por-defecto)) ; en caso de not-valid-argument
    )
)




;; =========================================================
;; REQUERIMIENTO 2: Temporizador Automático
;; =========================================================

;; --------------------------------------------------------
;; FUNCIÓN: timer
;; NATURALEZA: Pura                 (Dado un timestamp, siempre retorna un color symbol)
;; ESTRATEGIA: Funcion Condicional  (evalúa condiciones sobre los argumentos) 
;; IMPACTO: No destructiva          (solo retorna un symbol)
;; --------------------------------------------------------

;; 0  - 89  → en-rojo
;; 90 - 92  → intermitencia
;; 93 - 212 → en-verde
;; 213- 215 → intermitencia
;; 216- 221 → en-amarillo

;; Determina el estado actual del semáforo a partir
;; de un timestamp utilizando el ciclo configurado.
(defun semaforo-timer (timestamp)
  (cond
    ((integerp timestamp)
      (let ((offset (mod timestamp +duracion-ciclo-total+)))
        (cond
          ((<= 0 offset 89) 'en-rojo)
          ((<= 90 offset 92) 'intermitencia)
          ((<= 93 offset 212) 'en-verde)
          ((<= 213 offset 215) 'intermitencia)
          ((<= 216 offset 221) 'en-amarillo)
        )
      )
    )
  )
)


;; =========================================================
;; REQUERIMIENTO 3: Sistema de Auditoría
;; =========================================================

;; --------------------------------------------------------
;; FUNCIÓN: log-cambio-estado
;; NATURALEZA: No Pura     (Escribe por pantalla/terminal)
;; ESTRATEGIA: Funcion De Efecto Secundario
;; IMPACTO: No Destructiva
;; --------------------------------------------------------
(defun log-cambio-estado (epoch color-anterior color-nuevo)
  (cond
    ((integerp epoch)
      (format t "Tiempo ~a: la luz ha cambiado de ~a a ~a~%" 
          (local-time:format-timestring nil 
            (local-time:unix-to-timestamp epoch)
            :format '(:year "-" (:month 2) "-" (:day 2) " " (:hour 2) ":" (:min 2) ":" (:sec 2)))
          color-anterior
          color-nuevo
      )
    )
  )
)


;; =========================================================
;; REQUERIMIENTO 4a: Duración de Ciclo
;; =========================================================

;; --------------------------------------------------------
;; FUNCIÓN: duracion-ciclo
;; NATURALEZA: Pura
;; ESTRATEGIA: Condicional
;; IMPACTO: No destructiva
;; --------------------------------------------------------
(defun duracion-ciclo (segundos)
  (cond
    ((integerp segundos)
      (list (nth-value 0 (floor segundos +duracion-ciclo-total+)) (recomendacion-ciclo segundos)))
;nth 0 muestra el primer valor del floor que seria el cociente de la operacion(representa ciclos)
    )
)


;; =========================================================
;; REQUERIMIENTO 4b: Recomendación de Ciclo
;; =========================================================

;; --------------------------------------------------------
;; FUNCIÓN: recomendacion-ciclo
;; NATURALEZA: Pura
;; ESTRATEGIA: Funcion Condicional
;; IMPACTO: No destructiva
;; --------------------------------------------------------
(defun recomendacion-ciclo (duracion)
    (cond
      ((AND(integerp duracion)(< duracion 35)) 'ciclo-corto)
       ((AND (integerp duracion) (<= 35 duracion 150))  'ciclo-optimo)
        (t 'ciclo-largo))
      )

;; =========================================================
;; REQUERIMIENTO 5: Planificación Temporal
;; =========================================================

;; --------------------------------------------------------
;; FUNCIÓN: ciclos-por-tiempo
;; NATURALEZA: Pura
;; ESTRATEGIA: Funcion Simple
;; IMPACTO: No Destructiva
;; --------------------------------------------------------
(defun ciclos-por-tiempo (minutos)
  (cond
    ((integerp minutos)
      (nth-value 0 (floor (* minutos 60) +duracion-ciclo-total+)) ;multiplico minutos por 60 para pasarla a segundos
    )
  )
)


;; =========================================================
;; REQUERIMIENTO 6: Distribución Temporal
;; =========================================================

;; --------------------------------------------------------
;; FUNCIÓN: distribucion-temporal
;; NATURALEZA: Pura
;; ESTRATEGIA: Función de orden superior
;; IMPACTO: No destructiva
;; --------------------------------------------------------

;; Calcula el porcentaje de tiempo que el semáforo
;; permanece en cada estado durante una hora de funcionamiento.
(defun distribucion-temporal ()
  (let ((ciclos-por-hora (ciclos-por-tiempo 60)))
    (mapcar
      (lambda (x)
          (cons (car x)
            (* (/ (* (cdr x) ciclos-por-hora) 3600.0) 100.0))
        )
      
      (list
        (cons 'rojo +duracion-rojo+)
        (cons 'amarillo +duracion-amarillo+)
        (cons 'verde +duracion-verde+)
        (cons 'intermitencia (* 2 +duracion-intermitencia+))  ; 6 segundos en total (dos períodos)
      )
    )
  )
)

;; =========================================================
;; REQUERIMIENTO 7: Ejemplos de uso / QA
;; =========================================================
;; Una vez que implementes cada función, agregá acá:
;;   - Un ejemplo del camino normal (funciona como se espera)
;;   - Un ejemplo del camino alternativo (transición inválida, borde de ciclo, etc.)
;;   - Un ejemplo que genera error o comportamiento inesperado
;; =========================================================

(defun run-ejemplos ()
  ;; *** EJEMPLOS DE IMPLEMENTACION DE LOS REQUERIMIENTOS
  ;; ** Requerimiento 1:
  (format t "*** Requerimiento 1: *** ~%")
  (format t "Camino Normal: ~a ~%" (transicion 'en-rojo 'verde))    ;devuelve (EN-ROJO "cambiar-a-verde")
  (format t "Camino alternativo: ~a% ~%" (transicion 'en-verde 'verde)) ;devuelve (EN-VERDE ACCION-POR-DEFECTO)
  (format t "Camino por error: ~a ~%~%" (transicion 'hola 'mundo)); devuelve (HOLA ACCION-POR-DEFECTO)
  (format t "---------------------------------------------------~%")

  ;; ** Requerimiento 2:
  (format t "*** Requerimiento 2: *** ~%")
  (format t "Camino Normal: ~a ~%" (semaforo-timer 200000)) ;devuelve EN-VERDE
  (format t "Camino alternativo: ~a% ~%" (semaforo-timer 2049340.02))  ;devuelve NIL
  (format t "Camino por error: ~a ~%~%" (semaforo-timer 'symbol-malintencionado)) ;devuelve NIL
  (format t "---------------------------------------------------~%")

  ;; ** Requerimiento 3: 
  (format t "*** Requerimiento 3: *** ~%")
  (format t "Camino Normal: ~a ~%" (log-cambio-estado 200000 'rojo 'verde)) ;DEVUELVE Tiempo 1970-01-03 07:33:20: la luz ha cambiado de ROJO a VERDE
  (format t "Camino alternativo: ~a% ~%" (log-cambio-estado 20394994 "en rojo" "verde")) ;DEVUELVE Tiempo 1970-08-25 01:16:34: la luz ha cambiado de en rojo a verde
  (format t "Camino por error: ~a ~%~%" (log-cambio-estado 'timestampthing 'symbol 'other-symbol)) ;DEVUELVE nil
  (format t "---------------------------------------------------~%")

  ;; ** Requerimiento 4a:
  (format t "*** Requerimiento 4a: *** ~%")
  (format t "Camino Normal: ~a ~%" (duracion-ciclo 2000))
  (format t "Camino alternativo: ~a% ~%" (duracion-ciclo 2000.0))
  (format t "Camino por error: ~a ~%~%" (duracion-ciclo 'cuatro-mil))
  (format t "---------------------------------------------------~%")

  ;; ** Requerimiento 4b:
  (format t "*** Requerimiento 4b: *** ~%")
  (format t "Camino Normal: ~a ~%" (recomendacion-ciclo 200))
  (format t "Camino alternativo: ~a% ~%" (recomendacion-ciclo 2000.0))
  (format t "Camino por error: ~a ~%~%" (recomendacion-ciclo 'doscientos))
  (format t "---------------------------------------------------~%")
  
  ;; ** Requerimiento 5:
  (format t "*** Requerimiento 5: *** ~%")
  (format t "Camino Normal: ~a ~%" (ciclos-por-tiempo 300))
  (format t "Camino alternativo: ~a% ~%" (ciclos-por-tiempo 300.0))
  (format t "Camino por error: ~a ~%~%" (ciclos-por-tiempo 'trescientos))
  (format t "---------------------------------------------------~%")

  ;; ** Requerimiento 6:
  (format t "*** Requerimiento 6: *** ~%")
  (format t "Camino Normal: ~a ~%" (distribucion-temporal))
  (format t "Camino alternativo y por error no hay (no necesita argumentos) ~%")
  (format t "---------------------------------------------------~%")


  ;; ** Iteración 2:
  ;; Sistema de Persistencia sobre Archivos de texto Plano:
  (informe '((123923 rojo verde) (29349234 amarillo rojo) (2032032 rojo verde)))
)






;; =========================================================
;; ITERACION 2:   Implementar una funcion extra
;; =========================================================
;;
;; --------------------------------------------------------
;; FUNCIÓN: informe
;; NATURALEZA: No Pura
;; ESTRATEGIA: Función de orden superior
;; IMPACTO: No Destructiva
;; --------------------------------------------------------
;; Genera un archivo de texto con el historial de transiciones
;; registradas por el sistema semafórico.
;; Cada registro contiene fecha, estado anterior y estado nuevo.

(defun informe (datos)
  (with-open-file (stream "informe-ejecucion-semaforo.txt" 
                          :direction :output
                          :if-exists :supersede)
    (format stream "Informe de Ejecución del Sistema Semafórico~%")
    (format stream "=========================================~%")

    ;; Implementar iteración sobre datos y formateo
    ;; Ejemplo de línea: "2024-06-04 14:30:15 - Transición: ROJO → VERDE"
    
;; Recorre cada transición recibida y la escribe
;; en el archivo con un formato legible para el usuario.

    (mapcar
      (lambda (x)
          (format stream "~a - Transición: ~a -> ~a~%" 
              (local-time:format-timestring nil 
                (local-time:unix-to-timestamp (car x))
                :format '(:year "-" (:month 2) "-" (:day 2) " " (:hour 2) ":" (:min 2) ":" (:sec 2)))
            (cadr x)
            (caddr x)))
      datos)
  
    (format stream "~% --- Fin del Informe ---")))
