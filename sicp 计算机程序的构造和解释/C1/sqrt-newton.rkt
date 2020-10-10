#lang sicp

(define (sqrt x)                        ;牛顿法求平方根
  (define (good-enough? guess)
    (< (abs (- (square guess) x) 0.01)))
  (define (improve guess)
    (average guess (/ x guess)))
  (define (sqrt-iter guess)
    (if (good-enough? guess)
        guess
        (sqrt-iter (improve guess))))
   (sqrt-iter 1.0))