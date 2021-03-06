#' @templateVar class irlba
#' @template title_desc_tidy_list
#'
#' @param x A list returned from [irlba::irlba()].
#'
#' @inherit tidy_svd return params examples
#'
#' @details A very thin wrapper around [tidy_svd()].
#'
#' @aliases tidy.irlba irlba_tidiers
#' @family list tidiers
#' @family svd tidiers
#' @seealso [tidy()], [irlba::irlba()]
#' @export
tidy_irlba <- function(x, ...) {
  tidy_svd(x, ...)
}
