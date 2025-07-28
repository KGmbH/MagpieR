# null‑coalescing helper
`%||%` <- function(a, b) if (is.null(a) || is.na(a)) b else a

#' Build magpie trials (experimental items + optional fillers)
#'
#' @param n_exp        Number of experimental items (Item1, Item2, …).
#' @param fillers      Character vector of filler sentences (optional).
#'                     Each string is inserted verbatim into the *sentence*
#'                     field and **never** wrapped in `''.concat(...)`.
#' @param coin_var     JS variable that indexes the condition
#'                     (`syn.Item1[coin]`). Default `"coin"`.
#' @param question     Prompt shown to participants (Likert task).
#'                     Default *“How acceptable is the utterance?”*.
#' @param n_options    0 = Likert task (default); 2 or 3 = forced‑choice.
#' @param option_labels
#'   *When `n_options == 0`* → ignored.  
#'   *When `n_options == 2`* and **missing** → defaults to
#'   `c("Yes", "No")`.  
#'   Otherwise **must** be either  
#'   • a vector of length `n_options` (same labels for every item), or  
#'   • a list of `n_options` vectors. The *i‑th* element of each vector is
#'     used for item *i* (cycling if shorter than the number of items).
#' @param js_var       JS variable name for the emitted array
#'                     (default `"trial_template"`).
#' @param print_js     Logical. Write JS to the console?  Default `TRUE`.
#'
#' @return (invisibly) list of trial objects.
#' @export
trial_format <- function(n_exp,
                         fillers        = NULL,
                         coin_var       = "coin",
                         question       = "How acceptable is the utterance?",
                         n_options      = 0L,
                         option_labels  = NULL,
                         js_var         = "trial_template",
                         print_js       = TRUE) {

  stopifnot(n_options %in% 0:3,
            is.numeric(n_exp), n_exp >= 1)

  ## ---- 1. handle option labels ------------------------------------------
  if (n_options == 0L) {
    option_labels <- NULL

  } else {
    if (is.null(option_labels)) {
      if (n_options == 2L) {
        option_labels <- c("Yes", "No")     # automatic default
      } else {
        stop("`option_labels` must be supplied when n_options = ", n_options)
      }
    }

    # Accept either vector or list(list-of-vectors)
    if (is.list(option_labels)) {
      if (length(option_labels) != n_options)
        stop("When `option_labels` is a list, its length must equal `n_options`.")
      # ensure every element is a vector
      option_labels <- lapply(option_labels, as.character)
    } else {
      option_labels <- rep(list(as.character(option_labels)), n_options)
    }
  }

  ## ---- 2. pre‑allocate ---------------------------------------------------
  n_fill  <- length(fillers)
  trials  <- vector("list", n_exp + n_fill)

## ---- 3. convenience for cycling labels (+ warning) --------------------
recycle_warned <- logical(n_options)          # track per‑option field

get_label <- function(opt_idx, item_idx) {
  vec <- option_labels[[opt_idx]]
  if (length(vec) < (n_exp + length(fillers)) && !recycle_warned[opt_idx]) {
    warning(sprintf(
      "Option %d has %d labels but %d trials; cycling from the top.",
      opt_idx, length(vec), n_exp + length(fillers)
    ))
    recycle_warned[opt_idx] <<- TRUE           # warn only once
  }
  vec[ ((item_idx - 1) %% length(vec)) + 1 ]
}


  ## ---- 4. builder helper -------------------------------------------------
  make_trial <- function(name, sentence, item_idx, is_filler) {

    trial <- list(
      sentence = sentence,
      question = sprintf("\"%s\"", question)
    )

    if (n_options > 0L) {
      for (o in seq_len(n_options)) {
        lbl <- get_label(o, item_idx)
        trial[[paste0("option", o)]] <- sprintf("\"%s\"", lbl)
      }
    }

    trial$itemname          <- sprintf("\"%s\"", name)
    trial$participant_group <- coin_var
    trial$participant_id    <- "participantID"
    trial$wordPos           <- "'same'"
    trial$underline         <- "'none'"

    trial
  }

  ## ---- 5. experimental items --------------------------------------------
  for (i in seq_len(n_exp)) {
    name     <- paste0("Item", i)
    sentence <- sprintf("''.concat(syn.%s[%s],'')", name, coin_var)
    trials[[i]] <- make_trial(name, sentence, i, FALSE)
  }

  ## ---- 6. fillers --------------------------------------------------------
  if (n_fill) {
    for (i in seq_len(n_fill)) {
      name     <- paste0("Filler", i)
      sent_raw <- fillers[i]
      sentence <- sprintf("'%s'", gsub("'", "\\\\'", sent_raw))
      trials[[n_exp + i]] <- make_trial(name, sentence, n_exp + i, TRUE)
    }
  }

  if (print_js) print_trials_js(trials, js_var)
  invisible(trials)
}

#' Print trial list as JavaScript
#' @param trials list returned by `trial_format()`
#' @param js_var JS variable name (default `"trial_template"`)
#' @export
print_trials_js <- function(trials, js_var = "trial_template") {
  cat(sprintf("var %s = [\n", js_var))
  for (i in seq_along(trials)) {
    t <- trials[[i]]
    cat("  {\n")
    for (j in seq_along(t)) {
      cat(sprintf("    %s: %s", names(t)[j], t[[j]]))
      if (j < length(t)) cat(",")
      cat("\n")
    }
    cat("  }")
    if (i < length(trials)) cat(",")
    cat("\n")
  }
  cat("];\n")
  invisible(NULL)
}
