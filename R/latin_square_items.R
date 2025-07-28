#' Rotate an item list with a Latin‑square and emit JavaScript
#'
#' @param item_list       list of character vectors (one per item)
#' @param n_conditions    number of conditions (k). If NULL, inferred.
#' @param n_reps          number of k‑item blocks (N / k). If NULL, inferred.
#' @param js_var          JavaScript variable name for the output object.
#' @param add_comment     logical, prepend an HTML comment to every string?
#' @param comment_labels  character vector of length k for the comments.
#'                        Defaults to LETTERS[1:k].
#' @param show_latin      logical, print the Latin‑square matrix?  (NEW)
#'
#' @return (invisibly) a list of k fully rotated stimulus lists.
#' @export
latin_square_items <- function(item_list,
                               n_conditions   = NULL,
                               n_reps         = NULL,
                               js_var         = "syn",
                               add_comment    = TRUE,
                               comment_labels = NULL,
                               show_latin     = TRUE) {   # <- HERE

  ## ---- 1. infer k and reps ----------------------------------------------
  if (is.null(n_conditions)) {
    lens <- vapply(item_list, length, 1L)
    stopifnot(all(lens == lens[1]))
    n_conditions <- lens[1]
  }
  if (is.null(n_reps)) {
    stopifnot(length(item_list) %% n_conditions == 0)
    n_reps <- length(item_list) / n_conditions
  }

  ## ---- 2. comment labels -------------------------------------------------
  if (is.null(comment_labels))
    comment_labels <- LETTERS[seq_len(n_conditions)]
  stopifnot(length(comment_labels) == n_conditions)

  ## ---- 3. build k×k Latin square & (optionally) display it --------------
  k     <- n_conditions
  latin <- outer(0:(k - 1), 0:(k - 1), function(r, c) (r + c) %% k + 1)

  if (show_latin) {
    display <- if (add_comment) {
                 matrix(comment_labels[latin], nrow = k)
               } else {
                 latin
               }
    message(sprintf("%dx%d Latin Square Design:", k, k))
    print(display, quote = FALSE)
  }

  ## ---- 4. allocate output lists -----------------------------------------
  lists <- replicate(k, character(n_reps * k), simplify = FALSE)

  for (blk in 0:(n_reps - 1))
    for (pos in 1:k) {
      idx <- blk * k + pos
      for (lst in 1:k) {
        cond  <- latin[lst, pos]
        text  <- item_list[[idx]][cond]
        if (add_comment)
          text <- sprintf("<!--%s-->%s", comment_labels[cond], text)
        lists[[lst]][idx] <- text
      }
    }

  ## ---- 5. emit JavaScript -----------------------------------------------
  cat(sprintf("var %s = {\n", js_var))
  for (i in seq_along(item_list)) {
    cat(sprintf('  "Item%s": {\n', i))
    for (lst in 1:k)
      cat(sprintf('    "%s": "%s"%s\n',
                  LETTERS[lst], lists[[lst]][i],
                  if (lst < k) "," else ""))
    cat("  }", if (i < length(item_list)) ",", "\n")
  }
  cat("};\n")

  invisible(lists)
}
