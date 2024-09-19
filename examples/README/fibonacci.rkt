(define (fib n)
  (if (<= n 1) n
      (+ (fib (- n 1)) (fib (- n 2)))))

(display "Fibonacci of 10 is ")
(display (fib 10))
