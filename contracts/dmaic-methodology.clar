;; DMAIC Methodology Contract
;; Manages the Define, Measure, Analyze, Improve, Control phases

(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_PROJECT_NOT_FOUND (err u301))
(define-constant ERR_INVALID_PHASE (err u302))
(define-constant ERR_PHASE_NOT_READY (err u303))

;; DMAIC Phase constants
(define-constant PHASE_DEFINE u1)
(define-constant PHASE_MEASURE u2)
(define-constant PHASE_ANALYZE u3)
(define-constant PHASE_IMPROVE u4)
(define-constant PHASE_CONTROL u5)

;; Data structures
(define-map project-phases uint {
    current-phase: uint,
    define-completed: bool,
    measure-completed: bool,
    analyze-completed: bool,
    improve-completed: bool,
    control-completed: bool,
    phase-start-date: uint,
    total-duration: uint
})

(define-map phase-deliverables uint {
    problem-statement: (optional (string-ascii 500)),
    process-map: (optional (string-ascii 200)),
    measurement-plan: (optional (string-ascii 300)),
    data-collection: (optional (string-ascii 300)),
    root-cause-analysis: (optional (string-ascii 400)),
    solution-design: (optional (string-ascii 400)),
    implementation-plan: (optional (string-ascii 300)),
    control-plan: (optional (string-ascii 300))
})

;; Read-only functions
(define-read-only (get-project-phase (project-id uint))
    (map-get? project-phases project-id)
)

(define-read-only (get-phase-deliverables (project-id uint))
    (map-get? phase-deliverables project-id)
)

(define-read-only (is-phase-completed (project-id uint) (phase uint))
    (match (map-get? project-phases project-id)
        phase-data (if (is-eq phase PHASE_DEFINE)
                      (get define-completed phase-data)
                      (if (is-eq phase PHASE_MEASURE)
                          (get measure-completed phase-data)
                          (if (is-eq phase PHASE_ANALYZE)
                              (get analyze-completed phase-data)
                              (if (is-eq phase PHASE_IMPROVE)
                                  (get improve-completed phase-data)
                                  (if (is-eq phase PHASE_CONTROL)
                                      (get control-completed phase-data)
                                      false)))))
        false
    )
)

;; Public functions
(define-public (initialize-dmaic (project-id uint))
    (begin
        (map-set project-phases project-id {
            current-phase: PHASE_DEFINE,
            define-completed: false,
            measure-completed: false,
            analyze-completed: false,
            improve-completed: false,
            control-completed: false,
            phase-start-date: block-height,
            total-duration: u0
        })

        (map-set phase-deliverables project-id {
            problem-statement: none,
            process-map: none,
            measurement-plan: none,
            data-collection: none,
            root-cause-analysis: none,
            solution-design: none,
            implementation-plan: none,
            control-plan: none
        })

        (ok true)
    )
)

(define-public (complete-define-phase
    (project-id uint)
    (problem-statement (string-ascii 500))
    (process-map (string-ascii 200)))
    (let ((phase-data (unwrap! (map-get? project-phases project-id) ERR_PROJECT_NOT_FOUND))
          (deliverables (unwrap! (map-get? phase-deliverables project-id) ERR_PROJECT_NOT_FOUND)))

        (asserts! (is-eq (get current-phase phase-data) PHASE_DEFINE) ERR_INVALID_PHASE)

        (map-set project-phases project-id
            (merge phase-data {
                define-completed: true,
                current-phase: PHASE_MEASURE
            })
        )

        (map-set phase-deliverables project-id
            (merge deliverables {
                problem-statement: (some problem-statement),
                process-map: (some process-map)
            })
        )

        (ok true)
    )
)

(define-public (complete-measure-phase
    (project-id uint)
    (measurement-plan (string-ascii 300))
    (data-collection (string-ascii 300)))
    (let ((phase-data (unwrap! (map-get? project-phases project-id) ERR_PROJECT_NOT_FOUND))
          (deliverables (unwrap! (map-get? phase-deliverables project-id) ERR_PROJECT_NOT_FOUND)))

        (asserts! (is-eq (get current-phase phase-data) PHASE_MEASURE) ERR_INVALID_PHASE)
        (asserts! (get define-completed phase-data) ERR_PHASE_NOT_READY)

        (map-set project-phases project-id
            (merge phase-data {
                measure-completed: true,
                current-phase: PHASE_ANALYZE
            })
        )

        (map-set phase-deliverables project-id
            (merge deliverables {
                measurement-plan: (some measurement-plan),
                data-collection: (some data-collection)
            })
        )

        (ok true)
    )
)

(define-public (complete-analyze-phase
    (project-id uint)
    (root-cause-analysis (string-ascii 400)))
    (let ((phase-data (unwrap! (map-get? project-phases project-id) ERR_PROJECT_NOT_FOUND))
          (deliverables (unwrap! (map-get? phase-deliverables project-id) ERR_PROJECT_NOT_FOUND)))

        (asserts! (is-eq (get current-phase phase-data) PHASE_ANALYZE) ERR_INVALID_PHASE)
        (asserts! (get measure-completed phase-data) ERR_PHASE_NOT_READY)

        (map-set project-phases project-id
            (merge phase-data {
                analyze-completed: true,
                current-phase: PHASE_IMPROVE
            })
        )

        (map-set phase-deliverables project-id
            (merge deliverables {
                root-cause-analysis: (some root-cause-analysis)
            })
        )

        (ok true)
    )
)

(define-public (complete-improve-phase
    (project-id uint)
    (solution-design (string-ascii 400))
    (implementation-plan (string-ascii 300)))
    (let ((phase-data (unwrap! (map-get? project-phases project-id) ERR_PROJECT_NOT_FOUND))
          (deliverables (unwrap! (map-get? phase-deliverables project-id) ERR_PROJECT_NOT_FOUND)))

        (asserts! (is-eq (get current-phase phase-data) PHASE_IMPROVE) ERR_INVALID_PHASE)
        (asserts! (get analyze-completed phase-data) ERR_PHASE_NOT_READY)

        (map-set project-phases project-id
            (merge phase-data {
                improve-completed: true,
                current-phase: PHASE_CONTROL
            })
        )

        (map-set phase-deliverables project-id
            (merge deliverables {
                solution-design: (some solution-design),
                implementation-plan: (some implementation-plan)
            })
        )

        (ok true)
    )
)

(define-public (complete-control-phase
    (project-id uint)
    (control-plan (string-ascii 300)))
    (let ((phase-data (unwrap! (map-get? project-phases project-id) ERR_PROJECT_NOT_FOUND))
          (deliverables (unwrap! (map-get? phase-deliverables project-id) ERR_PROJECT_NOT_FOUND)))

        (asserts! (is-eq (get current-phase phase-data) PHASE_CONTROL) ERR_INVALID_PHASE)
        (asserts! (get improve-completed phase-data) ERR_PHASE_NOT_READY)

        (map-set project-phases project-id
            (merge phase-data {
                control-completed: true,
                total-duration: (- block-height (get phase-start-date phase-data))
            })
        )

        (map-set phase-deliverables project-id
            (merge deliverables {
                control-plan: (some control-plan)
            })
        )

        (ok true)
    )
)
