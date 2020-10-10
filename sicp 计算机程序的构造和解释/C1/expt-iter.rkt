#lang sicp
(define (expt b n)
  (expt-iter b n 1))

(define (expt-iter b counter product) ;线性迭代
  (if (= counter 0)
      product
      (expt-iter b
                 (- counter 1)
                 (* b product))))