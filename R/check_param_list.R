#' @title Check a parameter list
#' @description Check that the parameter list (or JSON parameter file)
#'  is in the correct format, and then speficied values are coherent with
#'  parameters.
#' @param pm List of parameters or path of a JSON parameter file.
#' @param type Type of the output (see [print_message] for details).
#' @param correct Logical: if TRUE (default), the function corrects
#'  some incoherences (e.g. timewindow of length 1 is transformed in length 2)
#'  and returns the corrected list as output; if false, only checking is
#'  performed, and the output is NULL if no errors occur.
#' @return In case of errors, depending on `type` argument, output can be
#'  a vector of errors (if `type = 'string'`),
#'  the first error occurred (if `type = 'error'`)
#'  or a set of warnings (if `type = 'warning'`).
#'  If no errors occur, output is the corrected parameter list if
#'  `correct = TRUE` or NULL otherwise.
#'
#' @importFrom jsonlite fromJSON
#' @importFrom methods is
#' @importFrom stringr str_pad
#' @author Luigi Ranghetti, phD (2017) \email{ranghetti.l@@irea.cnr.it}
#' @note License: GPL 3.0
#' @export
check_param_list <- function(pm, type = "string", correct = TRUE) {

  # to avoid NOTE on check
  . <- NULL

  # check the output type

  # check the format of pm object
  if (is(pm, "character")) {
    if (file.exists(pm)) {
      # load json parameter file
      pm <- jsonlite::fromJSON(pm)
    } else {
      print_message(type = "error", i18n$t("The file "), pm, i18n$t(" does not exist."))
    }
  } else if (!is(pm, "list")) {
    print_message(type = "error", "\"", deparse(substitute(pm)), "\"", i18n$t("must be a list or a path of a JSON parameter file."))
  }

  # TODO check the names of the content of the list

  # TODO check package version and parameter names

  # check timewindow
  if (!anyNA(pm$timewindow)) {
    if (length(pm$timewindow) == 1) {
      if (is(pm$timewindow, "numeric") | is(pm$timewindow, "difftime")) {
        pm$timewindow <- c(Sys.Date() - pm$timewindow, Sys.Date())
      } else {
        pm$timewindow <- rep(pm$timewindow, 2)
      }
    } else if (length(pm$timewindow) > 2) {
      print_message(type = type, i18n$t("Parameter 'timewindow' must be of length 1 or 2."))
    }
    if (is(pm$timewindow, "character")) {
      tryCatch(pm$timewindow <- as.Date(pm$timewindow), error = print)
    } else if (is(pm$timewindow, "POSIXt")) {
      pm$timewindow <- as.Date(pm$timewindow)
    }
    if (!is(pm$timewindow, "Date")) {
      print_message(type = type, i18n$t("Parameter 'timewindow' must be a Date object."))
    }
  } else if (pm$online == TRUE) {
    # in online mode, NA value is converted to last 90 days
    pm$timewindow <- c(Sys.Date() - 90, Sys.Date())
  }

  # # check output paths (if no products are selected, set to NA)
  # if (!is.na(pm$path_out) & sum(!is.na(nn(pm$list_prods))) == 0) {
  #   pm$path_out <- NA
  # }
  # if (!is.na(pm$path_indices) & sum(!is.na(pm$list_indices)) == 0) {
  #   pm$path_indices <- NA
  # }
  # if (!is.na(pm$path_rgb) & sum(!is.na(pm$list_rgb)) == 0) {
  #   pm$path_rgb <- NA
  # }

  # check consistency among mask_type and selected products (if masking is selected but no prods or indices are selected, set to NA)
  if (!is.na(pm$mask_type) & all(is.na(nn(pm$list_indices))) & all(is.na(nn(pm$list_prods[pm$list_prods != "SCL"])))) {
    pm$mask_type <- NA
  }

  # check bands numbers for required RGB (TOA:1-12; BOA: 1-9,11-12)
  if (!is.na(pm$path_rgb) & sum(!is.na(pm$list_rgb)) > 0) {
    rgb_bands <- lapply(strsplit(gsub("^RGB([0-9a-f]{3})([BT])$", "\\1", pm$list_rgb), ""), function(x) {
      strtoi(paste0("0x", x))
    })
    rgb_sources <- gsub("^RGB([0-9a-f]{3})([BT])$", "\\2OA", pm$list_rgb)
    rgb_list <- foreach(i = seq_along(pm$list_rgb), .combine = c) %do% {
      if (any(rgb_bands[[i]] < 1 | rgb_bands[[i]] > 12 | rgb_bands[[i]] == 10 & rgb_sources[i] == "BOA")) {
        print_message(type = "warning", "RGB ", pm$list_rgb[i], i18n$t(" can not be computed (bands out of range)."))
        character(0)
      } else {
        pm$list_rgb[i]
      }
    }
    pm$list_rgb <- rgb_list
  }

  if (correct == TRUE) {
    return(pm)
  } else {
    return(invisible(NULL))
  }
}
