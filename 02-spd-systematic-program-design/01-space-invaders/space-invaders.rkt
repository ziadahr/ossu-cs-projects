;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname final-project-starter) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders


;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
(define TANK-SPEED 2)
(define MISSILE-SPEED 10)

(define HIT-RANGE 10)

(define INVADE-RATE 100)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))

(define MISSILE (ellipse 5 15 "solid" "red"))
(define MISSILE-HEIGHT 15)

(define GAME-OVER-TEXT (text "Game Over!" 36 "red"))


;; ================
;; Data Definitions:

(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position

;; Game constants defined below Missile data definition

#;
(define (fn-for-game s)
  (... (fn-for-loi (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))


;; ==========
;; Functions:

;; Game -> Game
;; Start the wrold program with (main (make-game empty empty T0))
;; <no tests for main function>

(define (main game)
  (big-bang game
    (stop-when game-over? render-game)   ;Game -> Boolean
    (on-tick    next-game)               ;Game -> Game
    (to-draw  render-game)               ;Game -> Image
    (on-key   handle-game)))             ;Game keyEvent -> Game


;; Game -> Boolean
;; Produce true if any invader has reached or passed the bottom ground
(define (game-over? g)
  (invader-hit-ground (game-invaders g)))

;; ListOfInvader -> Boolean
;; Produce true if an invader hits the ground
(define (invader-hit-ground loi)
  (cond [(empty? loi) false]
        [else
         (or (hitground? (first loi))
             (invader-hit-ground (rest loi)))]))

;; Invader -> Boolean
;; Produce true if the invader's position has reached or passed the bottom of the screen
(check-expect (hitground? (make-invader 100 499 -1)) false)
(check-expect (hitground? (make-invader 100 500  1)) true)
(check-expect (hitground? (make-invader 100 501.5 1)) true)

(define (hitground? i)
  (>= (invader-y i) HEIGHT))


;; Game -> Game
;; Produce the game actions on the BACKGROUND
(define (next-game s)
  (handle-game-cases (make-game (next-invader (game-invaders s))
                                (move-missile (game-missiles s))
                                (move-tank (game-tank s)))))

;; Game -> Game
;; handle cases of invaders, missiles and tank
(define (handle-game-cases g)
  (make-game (lom-hit-loi (game-missiles g) (game-invaders g))
             (loi-hit-lom (game-invaders g) (game-missiles g))
             (game-tank g)))

;; Game -> Image
;; Produce a rendering of the game on BACKGROUND (with GAME-OVER overlay if lost)
(check-expect (render-game G0) 
              (render-war G0))
(check-expect (render-game (make-game (cons (make-invader 100 500 12) empty) LOM1 T0))
              (render-game-over (render-war (make-game (cons (make-invader 100 500 12) empty) LOM1 T0))))

(define (render-game g)
  (if (game-over? g)
      (render-game-over (render-war g))
      (render-war g)))


;; Game -> Image
;; Produce a rendering of missiles, invaders, and tank on BACKGROUND
(check-expect (render-war G0) (render-tank T0))

(define (render-war g)
  (render-loi (game-invaders g)
              (render-lom (game-missiles g)
                          (render-tank (game-tank g)))))


;; Image -> Image
;; Overlay GAME-OVER-TEXT on the center of the given image
(check-expect (render-game-over BACKGROUND)
              (place-image GAME-OVER-TEXT (/ WIDTH 2) (/ HEIGHT 2) BACKGROUND))

(define (render-game-over img)
  (place-image GAME-OVER-TEXT
               (/ WIDTH 2)
               (/ HEIGHT 2)
               img))


;; Game keyEvent -> Game
;; Handle the game to act with clicked keys
(check-expect (handle-game G0     " ") (make-game LOI0 (cons (make-missile 150 (- HEIGHT (+ TANK-HEIGHT/2 MISSILE-HEIGHT))) empty) T0))
(check-expect (handle-game G2  "left") (make-game LOI1 LOM1 (make-tank 50 -1)))
(check-expect (handle-game G2 "right") (make-game LOI1 LOM1 (make-tank 50  1)))
              
;(define (handle-game g ke) g) ;stub

(define (handle-game g ke)
  (cond [(key=? ke " ")
         (make-game (game-invaders g)
                    (cons (make-missile (tank-x (game-tank g)) (- HEIGHT (+ TANK-HEIGHT/2 MISSILE-HEIGHT)))
                          (game-missiles g))
                    (game-tank g))]
        [else
         (make-game (game-invaders g)
                    (game-missiles g)
                    (handle-tank (game-tank g) ke))]))


;; ======================
;; Missile-Invader Cases:

;; Missile Invader -> Boolean
;; Produce true if missile hit the invader, otherwise false
(check-expect (hit? M1 I1) false)
(check-expect (hit? M2 I1) true)

;(define (hit? m i) false) ;stub

(define (hit? m i)
  (and (<= (abs (- (missile-y m) (invader-y i))) HIT-RANGE)
       (<= (abs (- (missile-x m) (invader-x i))) HIT-RANGE)))

;; Missile ListOfInvader -> Boolean
;; if the missile hit an invader in loi produce true
(check-expect (missile-hit-loi? M1 LOI0) false)
(check-expect (missile-hit-loi? M2 LOI1)  true)
(check-expect (missile-hit-loi? M2 LOI2)  true)

;(define (missile-hit-loi? m loi) flse) ;stub

(define (missile-hit-loi? m loi)
  (cond [(empty? loi) false]
        [else
         (or (hit? m (first loi))
             (missile-hit-loi? m (rest loi)))]))

;; Invader ListOfMissile -> Boolean
;; if the invader hit a missile in lom produce true
(check-expect (invader-hit-lom? I1 LOM0) false)
(check-expect (invader-hit-lom? I1 LOM1) false)
(check-expect (invader-hit-lom? I1 LOM2)  true)

;(define (invader-hit-lom? i lom) false) ;stub

(define (invader-hit-lom? i lom)
  (cond [(empty? lom) false]
        [else
         (or (hit? (first lom) i)
             (invader-hit-lom? i (rest lom)))]))


;; ListOfInvader ListOfMissile -> ListOfMissile
;; if an invader in loi hits a missile in lom, the missile should be deleted
(check-expect (loi-hit-lom LOI1 LOM0) empty)
(check-expect (loi-hit-lom LOI1 LOM1) LOM1)
(check-expect (loi-hit-lom LOI1 LOM2) (cons M1 empty))

;(define (loi-hit-lom loi lom) empty) ;stub

(define (loi-hit-lom loi lom)
  (cond [(empty? lom) empty]
        [else
         (if (missile-hit-loi? (first lom) loi)
             (loi-hit-lom loi (rest lom))
             (cons (first lom) (loi-hit-lom loi (rest lom))))]))


;; ListOfMissile ListOfInvader -> ListOfInvader
;; if a missile in lom hits the invader in loi, the invader should be deleted
(check-expect (lom-hit-loi LOM1 LOI0) empty)
(check-expect (lom-hit-loi LOM1 LOI1)  LOI1)
(check-expect (lom-hit-loi LOM2 LOI2) (cons I2 empty))

;(define (lom-hit-loi loi lom) empty) ;stub

(define (lom-hit-loi lom loi)
  (cond [(empty? loi) empty]
        [else
         (if (invader-hit-lom? (first loi) lom)
             (lom-hit-loi lom (rest loi))
             (cons (first loi) (lom-hit-loi lom (rest loi))))]))
         

;; ================
;; Data Definitions:

(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))


;; ==========
;; Functions:

;; Tank -> Tank
;; Produce the next position of the tank on BACKGROUND
(check-expect (move-tank T1) (make-tank 52  1))                              ;Inside-BACKGROUND going-right
(check-expect (move-tank T2) (make-tank 48 -1))                              ;Inside-BACKGROUND going-left
(check-expect (move-tank (make-tank           2 -1)) (make-tank     0 1))    ;In-left-eadge  
(check-expect (move-tank (make-tank (+ WIDTH 2) -1)) (make-tank WIDTH 1))    ;In-right-eadge
(check-expect (move-tank (make-tank     0 -1)) (make-tank     0  1))         ;out-side left-eadge  
(check-expect (move-tank (make-tank WIDTH  1)) (make-tank WIDTH -1))         ;out-side right-eadge

;(define (move-tank t) t)  ;stub

(define (move-tank t)
  (cond [(<= (+ (tank-x t) (* (tank-dir t) TANK-SPEED)) 0)
         (make-tank 0 (abs (tank-dir t)))]
        [(>= (+ (tank-x t) (* (tank-dir t) TANK-SPEED)) WIDTH)
         (make-tank WIDTH (- (tank-dir t)))]
        [else
         (make-tank (+ (tank-x t) (* (tank-dir t) TANK-SPEED))
                    (tank-dir t))]))

;; Tank -> image
;; Produce rendering tank in each position on BACKGROUND
(check-expect (render-tank T0) (place-image TANK (/ WIDTH 2)
                                            (- HEIGHT TANK-HEIGHT/2)
                                            BACKGROUND))

;(define (render-tank t) empty-image)  ;stub

(define (render-tank t)
  (place-image TANK (tank-x t)
               (- HEIGHT TANK-HEIGHT/2)
               BACKGROUND))

;; Tank KeyEvent -> Tank
;; Produce the next tank position by moving it using left-right arrows key
(check-expect (handle-tank T0 "right") (make-tank (/ WIDTH 2)  1))
(check-expect (handle-tank T0  "left") (make-tank (/ WIDTH 2) -1))
(check-expect (handle-tank T2  "left") (make-tank 50 -1))
(check-expect (handle-tank T2 "right") (make-tank 50  1))

;(define (handle-tank t ke) t)  ;stub

(define (handle-tank t ke)
  (cond [(key=? ke "right") (make-tank (tank-x t) (abs (tank-dir t)))]
        [(and (key=? ke  "left") (negative? (tank-dir t))) (make-tank (tank-x t) (tank-dir t))]
        [(and (key=? ke  "left") (positive? (tank-dir t))) (make-tank (tank-x t) (- (tank-dir t)))]
        [else
         (make-tank (tank-x t) (tank-dir t))]))



;; ================
;; Data Definitions:

(define-struct invader (x y dx))
;; Invader is (make-invader Number Number Number)
;; interp. the invader is at (x, y) in screen coordinates
;;         the invader along x by dx pixels per clock tick

(define I1 (make-invader 150 100 12))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -10))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 10) 10)) ;> landed, moving right

#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dx invader)))

;; ListOfInvader is one of: 
;;  - empty
;;  - (cons Invader ListOfInvader)
;; Interp. list of invader

(define LOI0 empty)
(define LOI1 (cons I1 empty))
(define LOI2 (cons I1 (cons I2 empty)))

#;
(define (fn-for-loi loi)
  (cond [(empty? loi) (...)]
        [else
         (... (fn-for-invader (first loi))   ;NH (R)
              (fn-for-loi (rest loi)))]))    ;NR (SR)

;; Template rules used:
;;  - one of:
;;  - atomic distinct: empty
;;  - compound: (cons Invader ListOfInvader)
;;  - reference: (first loi) is Invader
;;  - self-reference: (rest loi) is ListOfInvader

;; ==========
;; Functions:

;; ListOfInvader -> ListOfInvader
;; Move all invaders and randomly spawn a new invader on tick
(define (next-invader loi)
  (if (= (random INVADE-RATE) 0)
      (cons (make-invader (random WIDTH) 0 (if (= (random 2) 0) INVADER-X-SPEED (- INVADER-X-SPEED)))
            (move-invader loi))
      (move-invader loi)))

;; ListOfInvader -> ListOfInvader
;; Produce the next position of invader on BACKGROUND
(check-expect (move-invader LOI0) empty)
(check-expect (move-invader LOI1) (cons (handle-cases I1) empty))
(check-expect (move-invader LOI2) (cons (handle-cases I1) (cons (handle-cases I2) empty)))

;(define (next-invader loi) loi)  ;stub

(define (move-invader loi)
  (cond [(empty? loi) empty]
        [else
         (cons (handle-cases (first loi))
               (move-invader (rest loi)))]))
        
;; Invader -> Invader
;; produce next invader position by handling all passible cases
(check-expect (handle-cases I1) (make-invader (+ 150 (* 12 INVADER-X-SPEED)) (+ 100 INVADER-Y-SPEED)  12))
(check-expect (handle-cases (make-invader  150 100 -10)) (make-invader (+ 150 (* -10 INVADER-X-SPEED)) (+ 100 INVADER-Y-SPEED)  -10))
(check-expect (handle-cases (make-invader           1.5 100 -1)) (make-invader     0 (+ 100 INVADER-Y-SPEED)  1))
(check-expect (handle-cases (make-invader (- WIDTH 1.5) 100  1)) (make-invader WIDTH (+ 100 INVADER-Y-SPEED) -1))
(check-expect (handle-cases (make-invader     0 100 -1)) (make-invader     0 (+ 100 INVADER-Y-SPEED)  1))
(check-expect (handle-cases (make-invader WIDTH 100  1)) (make-invader WIDTH (+ 100 INVADER-Y-SPEED) -1))

;(define (handle-cases i) i)  ;stub

(define (handle-cases i)
  (cond  [(>= (+ (invader-x i) (* (invader-dx i) INVADER-X-SPEED)) WIDTH)
          (make-invader WIDTH (+ INVADER-Y-SPEED (invader-y i)) (- (invader-dx i)))]
         [(<= (+ (invader-x i) (* (invader-dx i) INVADER-X-SPEED)) 0)
          (make-invader 0 (+ INVADER-Y-SPEED (invader-y i)) (- (invader-dx i)))]
         [else
          (make-invader (+ (invader-x i) (* (invader-dx i) INVADER-X-SPEED))
                        (+ (invader-y i) INVADER-Y-SPEED)
                        (invader-dx i))]))

;; ListOfInvader Image -> Image
;; Produce rendering list of invader on BACKGROUND
(check-expect (render-loi LOI0 BACKGROUND) BACKGROUND)
(check-expect (render-loi LOI1 BACKGROUND) (place-image INVADER 150 100
                                                        BACKGROUND))

;(define (render-loi loi img) BACKGROUND)  ;stub

(define (render-loi loi img)
  (cond [(empty? loi) img]
        [else
         (render-invader (first loi)
                         (render-loi (rest loi) img))]))

;; Invader Image -> Image
;; Produce rendering invader on BACKGROUND
(check-expect (render-invader I1 BACKGROUND) (place-image INVADER 150 100
                                                          BACKGROUND))

;(define (render-invader i img) BACKGROUND)  ;stub

(define (render-invader i img)
  (place-image INVADER (invader-x i) (invader-y i)
               img))



;; ================
;; Data Definitions:

(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit I1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit I1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit I1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))

;; ListOfMissile is one
;;  - empty
;;  - (cons Missile ListOfMissile)
;; interp. a list of missile
(define LOM0 empty)
(define LOM1 (cons M1 empty))
(define LOM2 (cons M1 (cons M2 empty)))

#;
(define (fn-for-lom lom)
  (cond [(empty? lom) (...)]
        [else
         (... (fn-for-missile (first lom))    ;NH
              (fn-for-lom (rest lom)))]))     ;NR

;; Template ruels used:
;;  - one of:
;;  - atomic distinct: empty
;;  - compound: (cons Missile ListOfMissile)
;;  - reference: (first lom) is Missile
;;  - self-reference: (rest lom) is ListOfMissile


;; ==========
;; Functions:

;; ListOfMissile -> ListOfMissile
;; Produce the next position (x, y) of missiles on BACKGROUND
(check-expect (move-missile LOM0) empty)
(check-expect (move-missile LOM1) (cons (make-missile 150 (- 300 MISSILE-SPEED)) empty))
(check-expect (move-missile (cons (make-missile 150 20) (cons (make-missile 150 10) (cons (make-missile 150 0) empty))))
              (cons (make-missile 150 10) (cons (make-missile 150 0) (cons (make-missile 150 -10) empty))))

;(define (move-missile lom) empty)  ;stub

;<template from ListOfMissile> 

(define (move-missile lom)
  (cond [(empty? lom) empty]
        [else
         (if (offscreen? (first lom))
             (move-missile (rest lom))
             (cons (missile-case (first lom)) (move-missile (rest lom))))]))

;; Missile -> Missile
;; Handle all cases of of missile on BACKGROUND
(check-expect (missile-case M1) (make-missile 150 (- 300 MISSILE-SPEED)))
(check-expect (missile-case (make-missile 150 10)) (make-missile 150   0))
(check-expect (missile-case (make-missile 150  0)) (make-missile 150 -10))

;(define (missile-case m) m)  ;stub

;<template from Missile>
(define (missile-case m)
  (make-missile (missile-x m) (- (missile-y m) MISSILE-SPEED)))

;; Missile -> Boolean
;; Produce true if missile is out of the BACKGROUND 
(check-expect (offscreen? M1) false)
(check-expect (offscreen? (make-missile 150  0)) false)
(check-expect (offscreen? (make-missile 150 -1)) true)

;(define (offscreen? m) false)  ;stub

;<template from Missile>
(define (offscreen? m)
  (< (missile-y m) 0))

;; ListOfMissile Image -> Image
;; Produce rendering list of missile on their position on BACKGROUND
(check-expect (render-lom LOM0 BACKGROUND) BACKGROUND)
(check-expect (render-lom LOM1 BACKGROUND) (place-image MISSILE 150 300
                                                        BACKGROUND))

;(define (render-lom lom img) img)  ;stub

(define (render-lom lom img)
  (cond [(empty? lom) img]
        [else
         (render-missile (first lom)
                         (render-lom (rest lom) img))]))

;; Missile Image -> Image
;; Produce rendering missile on its position on BACKGROUND
(check-expect (render-missile M1 BACKGROUND) (place-image MISSILE 150 300
                                                          BACKGROUND))

;(define (render-missile m img) img)  ;stub

(define (render-missile m img)
  (place-image MISSILE (missile-x m) (missile-y m)
               img))



(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))

