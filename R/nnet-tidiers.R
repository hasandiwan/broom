#' Tidying methods for multinomial logistic regression models
#'
#' These methods tidy the coefficients of multinomial logistic regression
#' models generated by `multinom` of the `nnet` package.
#'
#' @param x A `multinom` object returned from [nnet::multinom()].
#' @template param_confint
#' @template param_exponentiate
#' @template param_unused_dots
#'
#' @evalRd return_tidy("y.value", regression = TRUE)
#'
#' @examples
#'
#' library(nnet)
#' library(MASS)
#'
#' example(birthwt)
#' bwt.mu <- multinom(low ~ ., bwt)
#' tidy(bwt.mu)
#' glance(bwt.mu)
#'
#' #* This model is a truly terrible model
#' #* but it should show you what the output looks
#' #* like in a multinomial logistic regression
#'
#' fit.gear <- multinom(gear ~ mpg + factor(am), data = mtcars)
#' tidy(fit.gear)
#' glance(fit.gear)
#' @aliases multinom_tidiers nnet_tidiers
#' @export
#' @family multinom tidiers
#' @seealso [tidy()], [nnet::multinom()]
tidy.multinom <- function(x, conf.int = FALSE, conf.level = .95,
                          exponentiate = FALSE, ...) {


  # when the response is a matrix, x$lev is null
  if (is.null(x$lev)) {
    n_lev <- ncol(x$residuals)
  } else {
    n_lev <- length(x$lev) 
  }

  col_names <- if (n_lev > 2) colnames(coef(x)) else names(coef(x))
  s <- summary(x)

  co <- coef(s)
  coef <- matrix(co,
    byrow = FALSE,
    nrow = n_lev - 1,
    dimnames = list(
      row.names(co),
      col_names
    )
  )

  se <- s$standard.errors
  se <- matrix(se,
    byrow = FALSE,
    nrow = n_lev - 1,
    dimnames = list(
      row.names(se),
      col_names
    )
  )

  multinomRowToDf <- function(r, coef, se, col_names) {
    unrowname(data.frame(
      y.level = rep(r, length(col_names)),
      term = colnames(coef),
      estimate = coef[r, ],
      std.error = se[r, ],
      stringsAsFactors = FALSE
    ))
  }

  ret <- lapply(rownames(coef), multinomRowToDf, coef, se, col_names)
  ret <- do.call("rbind", ret)

  ret$statistic <- ret$estimate / ret$std.error
  ret$p.value <- stats::pnorm(abs(ret$statistic), 0, 1, lower.tail = FALSE) * 2

  if (conf.int) {
    ci <- apply(stats::confint(x), 2, function(a) unlist(as.data.frame(a)))
    ci <- as.data.frame(ci)
    names(ci) <- c("conf.low", "conf.high")
    ret <- cbind(ret, ci)
  }

  if (exponentiate) {
    ret <- exponentiate(ret)
  }

  as_tibble(ret)
}

#' @templateVar class multinom
#' @template title_desc_glance
#'
#' @inherit tidy.multinom params examples
#'
#' @evalRd return_glance("edf", "deviance", "AIC", "nobs")
#' @export
#' @family multinom tidiers
#' @seealso [glance()], [nnet::multinom()]
glance.multinom <- function(x, ...) {
  as_glance_tibble(
    edf = x$edf,
    deviance = x$deviance,
    AIC = x$AIC,
    nobs = stats::nobs(x),
    na_types = "irri"
  )
}
