;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-name (err u103))
(define-constant err-invalid-size (err u104))
(define-constant err-unauthorized (err u105))

;; Data variables
(define-data-var total-files uint u0)
;; Map to store file information
(define-map files
  { file-id: uint }
  {
    owner: principal,
    name: (string-ascii 64),
    size: uint,
    created-at: uint,
    permissions: { recipient: principal, permission: bool } ;; Add this line
  }
)
;; Private functions

;; (define-private (has-permission (file-id uint) (permission uint))
;;   (let ((file (unwrap! (map-get? files { file-id: file-id }) err-not-found)))
;;     (get permission (get permissions file))
;;   )
;; )

(define-private (file-exists (file-id uint))
  (is-some (map-get? files { file-id: file-id }))
)

;; Public functions
(define-public (upload-file (name (string-ascii 64)) (size uint))
  (let
    (
      (file-id (+ (var-get total-files) u1))
    )
    (asserts! (> (len name) u0) err-invalid-name)
    (asserts! (< (len name) u65) err-invalid-name)
    (asserts! (> size u0) err-invalid-size)
    (asserts! (< size u1000000000) err-invalid-size) ;; Assuming 1GB max file size
    ;; Insert the new file with permissions initialized
    (map-insert files
      { file-id: file-id }
      {
        owner: tx-sender,
        name: name,
        size: size,
        created-at: block-height,
        permissions: { recipient: tx-sender, permission: true } ;; Default permission for the owner
      }
    )
    (var-set total-files file-id)
    (ok file-id)
  )
)

(define-public (update-file (file-id uint) (new-name (string-ascii 64)) (new-size uint))
  (let
    (
      (file (unwrap! (map-get? files { file-id: file-id }) err-not-found))
    )
    (asserts! (file-exists file-id) err-not-found)
    (asserts! (is-eq (get owner file) tx-sender) err-unauthorized)
    (asserts! (> (len new-name) u0) err-invalid-name)
    (asserts! (< (len new-name) u65) err-invalid-name)
    (asserts! (> new-size u0) err-invalid-size)
    (asserts! (< new-size u1000000000) err-invalid-size)
    (map-set files
      { file-id: file-id }
      (merge file { name: new-name, size: new-size })
    )
    (ok true)
  )
)



