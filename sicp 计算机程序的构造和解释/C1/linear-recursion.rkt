#lang sicp
(define (factorial n) ;线性递归过程计算阶乘 
  (if (= n 1)
      1
      (* n (factorial (- n 1)))))

