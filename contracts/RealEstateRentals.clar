;; contracts/real-estate-rental.clar

(define-data-var owner principal tx-sender) ;; Contract owner (landlord)
(define-data-var rent-amount uint u1000) ;; Rent amount per period (default: 1000 microSTX)
(define-data-var penalty-fee uint u100) ;; Penalty for late payments
(define-data-var rental-period uint u2592000) ;; Rental period in seconds (~30 days)
(define-data-var tenant (optional principal) none) ;; Currently active tenant
(define-data-var last-payment-time uint u0) ;; Timestamp of the last rent payment

(define-map rent-ledger {tenant: principal} {total-paid: uint}) ;; Ledger of all rent payments

;; ========== Public Functions ==========

;; Set the rent amount (owner-only)
(define-public (set-rent-amount (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) (err u100)) ;; Only the owner can update rent
    (asserts! (> amount u0) (err u105)) ;; Ensure amount is greater than 0
    (asserts! (< amount u1000000000) (err u106)) ;; Set a reasonable upper limit
    (var-set rent-amount amount)
    (ok amount)
  ))

;; Set the penalty fee (owner-only)
(define-public (set-penalty-fee (fee uint))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) (err u100)) ;; Only the owner can update penalty
    (asserts! (> fee u0) (err u105)) ;; Ensure fee is greater than 0
    (asserts! (< fee u1000000000) (err u106)) ;; Set a reasonable upper limit
    (var-set penalty-fee fee)
    (ok fee)
  ))

;; Register a tenant (owner-only)
(define-public (register-tenant (new-tenant principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) (err u100)) ;; Only the owner can register tenants
    (asserts! (not (is-eq (some new-tenant) (var-get tenant))) (err u103)) ;; Ensure new tenant is different
    (var-set tenant (some new-tenant))
    (ok new-tenant)
  ))

;; Pay rent
(define-public (pay-rent)
  (begin
    ;; Ensure a tenant is registered
    (asserts! (is-some (var-get tenant)) (err u101))
    (let ((current-tenant (unwrap! (var-get tenant) (err u101)))
          (current-time stacks-block-height)
          (amount-due (var-get rent-amount)))
      ;; Ensure the caller is the registered tenant
      (asserts! (is-eq tx-sender current-tenant) (err u102))
      ;; Ensure the correct payment amount is provided
      (try! (stx-transfer? amount-due tx-sender (var-get owner)))
      ;; Update the last payment time and ledger
      (var-set last-payment-time current-time)
      (map-insert rent-ledger {tenant: current-tenant} {total-paid: (+ amount-due (default-to u0 (get total-paid (map-get? rent-ledger {tenant: current-tenant}))))})
      (ok amount-due)
    )
  ))

;; Penalize late payments (owner-only)
(define-public (penalize-late-payment)
  (begin
    ;; Ensure a tenant is registered
    (asserts! (is-some (var-get tenant)) (err u101))
    (let ((current-time stacks-block-height)
          (last-payment (var-get last-payment-time))
          (penalty (var-get penalty-fee)))
      ;; Check if payment is overdue
      (asserts! (> current-time (+ last-payment (var-get rental-period))) (err u104))
      ;; Deduct penalty from tenant
      (try! (stx-transfer? penalty tx-sender (var-get owner)))
      (ok penalty)
    )
  ))

;; View the ledger of a tenant
(define-read-only (get-tenant-ledger (target-tenant principal))
  (ok (map-get? rent-ledger {tenant: target-tenant})))

;; ========== Read-Only Functions ==========

;; Check rent details
(define-read-only (get-rent-details)
  (ok {owner: (var-get owner), rent-amount: (var-get rent-amount), penalty-fee: (var-get penalty-fee), rental-period: (var-get rental-period)}))

;; Check tenant details
(define-read-only (get-tenant-details)
  (ok {tenant: (var-get tenant), last-payment-time: (var-get last-payment-time)}))
