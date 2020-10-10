#lang sicp
(define (fact-iter product counter max-count) ;用线性迭代过程计算阶乘
  (if (> counter max-count)
       product
      (fact-iter (* product counter)
                 (+ counter 1)
                 max-count)))


  