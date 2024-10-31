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


(define-public (delete-file (file-id uint))
  (let
    (
      (file (unwrap! (map-get? files { file-id: file-id }) err-not-found))
    )
    (asserts! (file-exists file-id) err-not-found)
    (asserts! (is-eq (get owner file) tx-sender) err-unauthorized)
    (map-delete files { file-id: file-id })
    (ok true)
  )
)

(define-public (transfer-file-ownership (file-id uint) (new-owner principal))
  (let
    (
      (file (unwrap! (map-get? files { file-id: file-id }) err-not-found))
    )
    (asserts! (file-exists file-id) err-not-found)
    (asserts! (is-eq (get owner file) tx-sender) err-unauthorized)
    (map-set files
      { file-id: file-id }
      (merge file { owner: new-owner })
    )
    (ok true)
  )
)

;; Read-only functions

(define-read-only (get-total-files)
  (ok (var-get total-files))
)

;; read-only
(define-read-only (get-file-info (file-id uint))
  (match (map-get? files { file-id: file-id })
    file-info (ok file-info)
    err-not-found
  )
)




(define-private (get-owner-file (file-id int) (owner principal))
  (match (map-get? files { file-id: (to-uint file-id) })
    file-info (is-eq (get owner file-info) owner)
    false
  )
)

(define-private (get-file-size-by-owner (file-id int))
  (default-to u0 
    (get size 
      (map-get? files { file-id: (to-uint file-id) })
    )
  )
)

(define-public (grant-permission (file-id uint) (permission bool) (recipient principal))
  (let
    (
      ;; Retrieve the file and throw an error if not found
      (file (unwrap! (map-get? files { file-id: file-id }) err-not-found))
    )
    ;; Ensure the caller is the file's owner
    (asserts! (is-eq (get owner file) tx-sender) err-unauthorized)

    ;; Update the file's permissions
    (map-set files
      { file-id: file-id }
      (merge file { permissions: { recipient: recipient, permission: permission } }) ;; Set the permission for the recipient
    )

    ;; Return success
    (ok true)
  )
)

(define-public (revoke-permission (file-id uint) (permission bool) (recipient principal))
  (let
    (
      ;; Retrieve the file and throw an error if not found
      (file (unwrap! (map-get? files { file-id: file-id }) err-not-found))
    )
    ;; Ensure the caller is the file's owner
    (asserts! (is-eq (get owner file) tx-sender) err-unauthorized)

    ;; Update the file's permissions, revoking the permission
    (map-set files
      { file-id: file-id }
      (merge file { permissions: { recipient: recipient, permission: permission } }) ;; Revoke the permission for the recipient
    )

    ;; Return success
    (ok true)
  )
)
