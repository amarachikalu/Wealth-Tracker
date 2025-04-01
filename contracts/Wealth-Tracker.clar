;; Wealth Tracker Smart Contract
;; Allows users to set financial targets, track spending, revenue, and manage their wealth goals

;; Data Maps
(define-map financial-plans
    {user: principal}  ;; Unique identifier for each user
    {
        total-allocation: uint,
        available-funds: uint,
        total-revenue: uint
    }
)

(define-map transactions
    {
        user: principal,
        transaction-id: uint
    }  
    {
        amount: uint,
        category: (string-ascii 9),
        timestamp: uint
    }
)

(define-map revenue-entries
    {
        user: principal,
        revenue-id: uint
    }
    {
        amount: uint,
        channel: (string-ascii 9),
        timestamp: uint
    }
)

;; Data Variables
(define-data-var transaction-counter uint u0) ;; Counter for transaction ID
(define-data-var revenue-counter uint u0)  ;; Counter for revenue ID

;; Error Constants
(define-constant ERR-INVALID-ALLOCATION (err u100))
(define-constant ERR-PLAN-NOT-SET (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-NO-PLAN-FOUND (err u104))
(define-constant ERR-TRANSACTION-NOT-FOUND (err u105))
(define-constant ERR-REVENUE-NOT-FOUND (err u106))
(define-constant ERR-INVALID-CATEGORY (err u107))
(define-constant ERR-INVALID-CHANNEL (err u108))

;; Valid categories and channels lists
(define-constant VALID-CATEGORIES (list 
    "essentials"
    "shelter"
    "travel"
    "services"
    "wellness"
    "recreation"
    "other"
))

(define-constant VALID-REVENUE-CHANNELS (list
    "employment"
    "venture"
    "returns"
    "contract"
    "other"
))

;; Helper Functions
(define-private (is-valid-string (input (string-ascii 10)))
    (and
        (not (is-eq input ""))
        (<= (len input) u10)
    )
)

(define-private (is-valid-category (category (string-ascii 9)))
    (and
        (is-valid-string category)
        (is-some (index-of VALID-CATEGORIES category))
    )
)

(define-private (is-valid-channel (channel (string-ascii 9)))
    (and
        (is-valid-string channel)
        (is-some (index-of VALID-REVENUE-CHANNELS channel))
    )
)

;; Public Functions
;; Function to set or update a financial plan for a user
(define-public (set-allocation (total-allocation uint))
    (begin
        (asserts! (> total-allocation u0) ERR-INVALID-ALLOCATION)
        (let ((current-plan (map-get? financial-plans {user: tx-sender})))
            (map-set financial-plans
                {user: tx-sender}
                {
                    total-allocation: total-allocation,
                    available-funds: total-allocation,
                    total-revenue: (match current-plan
                        plan (get total-revenue plan)
                        u0)
                }
            )
            (ok total-allocation)
        )
    )
)

;; Function to add a transaction
(define-public (record-transaction (amount uint) (category (string-ascii 9)))
    (let ((transaction-id (var-get transaction-counter)))
        (begin
            (asserts! (is-some (map-get? financial-plans {user: tx-sender})) ERR-PLAN-NOT-SET)
            (asserts! (> amount u0) ERR-INVALID-AMOUNT)
            (asserts! (is-valid-category category) ERR-INVALID-CATEGORY)

            (let ((current-plan (unwrap-panic (map-get? financial-plans {user: tx-sender}))))
                (asserts! (>= (get available-funds current-plan) amount) ERR-INSUFFICIENT-FUNDS)

                ;; Update available funds
                (map-set financial-plans
                    {user: tx-sender}
                    {
                        total-allocation: (get total-allocation current-plan),
                        available-funds: (- (get available-funds current-plan) amount),
                        total-revenue: (get total-revenue current-plan)
                    }
                )

                ;; Store the transaction
                (map-set transactions
                    {
                        user: tx-sender,
                        transaction-id: transaction-id
                    }
                    {
                        amount: amount,
                        category: category,
                        timestamp: burn-block-height
                    }
                )

                ;; Increment counter
                (var-set transaction-counter (+ transaction-id u1))
                (ok transaction-id)
            )
        )
    )
)

;; Function to add revenue
(define-public (record-revenue (amount uint) (channel (string-ascii 9)))
    (let ((revenue-id (var-get revenue-counter)))
        (begin
            (asserts! (> amount u0) ERR-INVALID-AMOUNT)
            (asserts! (is-valid-channel channel) ERR-INVALID-CHANNEL)

            ;; Initialize financial plan if not exists
            (match (map-get? financial-plans {user: tx-sender})
                current-plan 
                (map-set financial-plans
                    {user: tx-sender}
                    {
                        total-allocation: (get total-allocation current-plan),
                        available-funds: (get available-funds current-plan),
                        total-revenue: (+ (get total-revenue current-plan) amount)
                    }
                )
                (map-set financial-plans
                    {user: tx-sender}
                    {
                        total-allocation: u0,
                        available-funds: u0,
                        total-revenue: amount
                    }
                )
            )

            ;; Store the revenue entry
            (map-set revenue-entries
                {
                    user: tx-sender,
                    revenue-id: revenue-id
                }
                {
                    amount: amount,
                    channel: channel,
                    timestamp: burn-block-height
                }
            )

            ;; Increment counter
            (var-set revenue-counter (+ revenue-id u1))
            (ok revenue-id)
        )
    )
)

;; Read-only Functions
;; Function to get the available funds for the user
(define-read-only (get-available-funds (user principal))
    (match (map-get? financial-plans {user: user})
        plan (ok (get available-funds plan))
        ERR-NO-PLAN-FOUND
    )
)

;; Function to get total revenue for the user
(define-read-only (get-total-revenue (user principal))
    (match (map-get? financial-plans {user: user})
        plan (ok (get total-revenue plan))
        ERR-NO-PLAN-FOUND
    )
)

;; Function to retrieve details of a transaction by ID
(define-read-only (get-transaction (transaction-id uint))
    (match (map-get? transactions {user: tx-sender, transaction-id: transaction-id})
        transaction (ok transaction)
        ERR-TRANSACTION-NOT-FOUND
    )
)

;; Function to retrieve details of a revenue entry by ID
(define-read-only (get-revenue-entry (revenue-id uint))
    (match (map-get? revenue-entries {user: tx-sender, revenue-id: revenue-id})
        revenue (ok revenue)
        ERR-REVENUE-NOT-FOUND
    )
)

;; Function to get valid categories
(define-read-only (get-valid-categories)
    (ok VALID-CATEGORIES)
)

;; Function to get valid revenue channels
(define-read-only (get-valid-revenue-channels)
    (ok VALID-REVENUE-CHANNELS)
)

;; Function to reset the financial plan and all transactions for a user
(define-public (reset-financial-plan)
    (begin
        (map-delete financial-plans {user: tx-sender})
        (ok "Financial plan reset successful")
    )
)

