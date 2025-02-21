;; SubScribe - Subscription Management Smart Contract
;; Handles subscription payments and management through STX locking

;; Constants and Variables
(define-data-var contract-owner principal tx-sender)
(define-data-var minimum-subscription-period uint u30)
(define-data-var early-termination-fee uint u100)

;; Data Maps
(define-map service-providers
    { provider: principal }
    { authorized: bool }
)

(define-map subscriptions
    { subscriber: principal }
    {
        service-provider: principal,
        amount: uint,
        start-height: uint,
        end-height: uint,
        payment-interval: uint,
        last-payment: uint,
        active: bool
    }
)

;; Authorization Functions
(define-read-only (is-service-provider (provider principal))
    (default-to false (get authorized (map-get? service-providers { provider: provider })))
)

(define-public (register-service-provider (provider principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
        (asserts! (not (is-service-provider provider)) (err u13))
        (ok (map-set service-providers { provider: provider } { authorized: true }))
    )
)

(define-public (remove-service-provider (provider principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
        (asserts! (is-service-provider provider) (err u14))
        (ok (map-set service-providers { provider: provider } { authorized: false }))
    )
)

;; Public Functions
(define-public (create-subscription (provider principal) (amount uint) (duration uint) (interval uint))
    (let
        (
            (current-height (unwrap-panic (get-stacks-block-info? time u0)))
            (total-amount (* amount (/ duration interval)))
        )
        (asserts! (is-service-provider provider) (err u15))
        (asserts! (> amount u0) (err u5))
        (asserts! (> duration u0) (err u6))
        (asserts! (> interval u0) (err u7))
        (asserts! (>= duration interval) (err u8))
        (asserts! (not (is-eq provider tx-sender)) (err u11))
        (try! (stx-transfer? total-amount tx-sender (as-contract tx-sender)))
        (ok (map-set subscriptions
            { subscriber: tx-sender }
            {
                service-provider: provider,
                amount: amount,
                start-height: current-height,
                end-height: (+ current-height duration),
                payment-interval: interval,
                last-payment: current-height,
                active: true
            }
        ))
    )
)

(define-public (process-payment (subscriber principal))
    (let
        (
            (subscription-data (unwrap! (map-get? subscriptions {subscriber: subscriber}) (err u1)))
            (current-height (unwrap-panic (get-stacks-block-info? time u0)))
            (subscription-key { subscriber: subscriber })
        )
        ;; Validate subscription exists and get data
        (asserts! (is-some (map-get? subscriptions subscription-key)) (err u18))
        (asserts! (is-eq tx-sender (get service-provider subscription-data)) (err u16))
        (asserts! (is-service-provider tx-sender) (err u17))
        (asserts! (get active subscription-data) (err u2))
        (asserts! (>= current-height (+ (get last-payment subscription-data) (get payment-interval subscription-data))) (err u3))
        (asserts! (<= current-height (get end-height subscription-data)) (err u4))
        
        (try! (as-contract
            (stx-transfer? (get amount subscription-data) tx-sender (get service-provider subscription-data))))
        
        (ok (map-set subscriptions
            subscription-key
            (merge subscription-data { last-payment: current-height })))
    )
)

(define-public (cancel-subscription)
    (let
        (
            (sub (unwrap! (map-get? subscriptions {subscriber: tx-sender}) (err u1)))
            (current-height (unwrap-panic (get-stacks-block-info? time u0)))
            (remaining-duration (- (get end-height sub) current-height))
            (minimum-blocks (* (var-get minimum-subscription-period) u144))
        )
        (asserts! (get active sub) (err u2))
        
        (if (< remaining-duration minimum-blocks)
            (let
                (
                    (penalty (/ (* (get amount sub) (var-get early-termination-fee)) u10000))
                )
                (try! (stx-transfer? penalty tx-sender (get service-provider sub)))
            )
            true
        )
        
        (ok (map-set subscriptions
            { subscriber: tx-sender }
            (merge sub { active: false })))
    )
)

;; Read-only Functions
(define-read-only (get-subscription (subscriber principal))
    (map-get? subscriptions {subscriber: subscriber})
)

(define-read-only (get-minimum-period)
    (var-get minimum-subscription-period)
)

(define-read-only (get-contract-owner)
    (var-get contract-owner)
)

;; Admin Functions
(define-public (set-minimum-period (new-period uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
        (asserts! (> new-period u0) (err u9))
        (ok (var-set minimum-subscription-period new-period))
    )
)

(define-public (transfer-ownership (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
        (asserts! (not (is-eq new-owner tx-sender)) (err u10))
        (ok (var-set contract-owner new-owner))
    )
)