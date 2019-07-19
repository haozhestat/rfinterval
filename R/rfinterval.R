#' Prediction Intervals for Random forests
#'
#' The \code{rfinterval} constructs prediction intervals for random forest predictions using a fast implementation package 'ranger'.
#'
#' @param formula Object of class \code{formula} or character describing the model to fit. Interaction terms supported only for numerical variables.
#' @param train_data Training data of class data.frame, matrix, or dgCMatrix (Matrix).
#' @param test_data Test data of class data.frame, matrix, or dgCMatrix (Matrix).
#' @param method Method for constructing prediction interval. If method = "oob", compute the out-of-bag prediction intervals; if method = "split-conformal", compute the split conformal prediction interval; if method = "quantreg", use quantile regression forest to compute prediction intervals.
#' @param alpha Confidence level. alpha = 0.05 for the 95\% prediction interval.
#' @param symmetry True if constructing symmetric out-of-bag prediction intervals, False otherwise. Only for method = "oob"
#' @param seed Seed (only for method = "split-conformal")
#' @param params_ranger List of further parameters that should be passed to ranger. See \code{\link[ranger]{ranger}} for possible parameters.
#' @references
#' Haozhe Zhang, Joshua Zimmerman, Dan Nettleton, and Dan Nordman. (2019). "Random Forest Prediction Intervals." The American Statistician. Doi: 10.1080/00031305.2019.1585288.
#' @references
#' Haozhe Zhang. (2019). "Topics in Functional Data Analysis and Machine Learning Predictive Inference." Ph.D. Dissertations. Iowa State University Digital Repository. 17929.
#' @references
#' Lei, J., Max G’Sell, Alessandro Rinaldo, Ryan J. Tibshirani, and Larry Wasserman. "Distribution-free predictive inference for regression." Journal of the American Statistical Association 113, no. 523 (2018): 1094-1111.
#' @references
#' Meinshausen, Nicolai. "Quantile regression forests." Journal of Machine Learning Research 7 (2006): 983-999.
#' @references
#' Leo Breiman. (2001). Random Forests. Machine Learning 45(1), 5-32.
#' @return
#' \item{\code{oob_interval}}{Out-of-bag prediction intervals}
#' \item{\code{sc_interval}}{Split-conformal prediction intervals}
#' \item{\code{quantreg_interval}}{Quantile regression forest prediction intervals}
#' \item{\code{alpha}}{Confidence level for prediction intervals}
#' \item{\code{testPred}}{Random forest prediction for test set}
#' \item{\code{train_data}}{Training data}
#' \item{\code{test_data}}{Test data}
#' @examples
#' \donttest{
#' train_data <- sim_data(n = 500, p = 8)
#' test_data <- sim_data(n = 500, p = 8)
#' output <- rfinterval(y~., train_data = train_data, test_data = test_data,
#'                      method = c("oob", "split-conformal", "quantreg"),
#'                      symmetry = TRUE,alpha = 0.1)
#' y <- test_data$y
#' mean(output$oob_interval$lo < y & output$oob_interval$up > y)
#' mean(output$sc_interval$lo < y & output$sc_interval$up > y)
#' mean(output$quantreg_interval$lo < y & output$quantreg_interval$up > y)
#' }
#' @export


rfinterval <- function(formula = NULL,
                       train_data = NULL,
                       test_data = NULL,
                       method = c("oob", "split-conformal", "quantreg"),
                       alpha = 0.1,
                       symmetry = TRUE,
                       seed = NULL,
                       params_ranger = NULL){

  if (is.null(params_ranger)) {
    params_ranger <- list()
  } else {
    if (!("quantreg" %in% method)) {
      params_ranger[["quantreg"]] <- FALSE
    }
  }

  response_name <- as.character(terms(as.formula(formula), data = train_data)[[2]])

  if ("oob" %in% method) {

    params_ranger[["oob.error"]] <- TRUE

    trainRF <-do.call(ranger::ranger,
                      c(list(formula = formula),
                        list(data = train_data),
                        params_ranger))

    testPred <- predict(trainRF, test_data)$predictions
    oob_error <-  train_data[,response_name] - trainRF$predictions
    oob_abs_error <- abs(oob_error)

    if (isTRUE(symmetry)) {
      upperPred <- testPred + quantile(oob_abs_error, 1-alpha)
      lowerPred <- testPred - quantile(oob_abs_error, 1-alpha)
    }else{
      upperPred <- testPred + quantile(oob_error, 1-alpha/2)
      lowerPred <- testPred + quantile(oob_error, alpha/2)
    }

    oob_interval <- data.frame(lower = lowerPred,
                               upper = upperPred)

  } else {
    oob_interval <- NULL
    testPred <- NULL
  }

  if ("split-conformal" %in% method) {

    params_ranger[c("oob.error", "keep.inbag", "quantreg")] <- list(FALSE, FALSE, FALSE)

    if (!is.null(seed)) {
      set.seed(seed)
    }

    nrow_traindata <- dim(train_data)[1]
    subset1 <- sample.int(n = nrow_traindata, size = floor(nrow_traindata/2))
    subset2 <- setdiff(1:nrow_traindata, subset1)

    trainRF <-do.call(ranger::ranger,
                      c(list(formula = formula),
                        list(data = train_data[subset1, ]),
                        params_ranger))

    sc_error <- abs(train_data[subset2, response_name] - predict(trainRF, train_data[subset2, ])$predictions)
    sc_error <- sort(sc_error, decreasing = FALSE)

    d <- sc_error[ceiling((nrow_traindata/2 + 1)*(1 - alpha))]

    sc_testPred <- predict(trainRF, test_data)$predictions

    upperPred <- sc_testPred + d
    lowerPred <- sc_testPred - d

    sc_interval <- data.frame(lower = lowerPred,
                              upper = upperPred)

  } else {
    sc_interval <- NULL
  }

  if ("quantreg" %in% method) {

    params_ranger[c("oob.error", "keep.inbag", "quantreg")] <- list (FALSE, TRUE, TRUE)

    trainRF <- do.call(ranger::ranger,
                       c(list(formula = formula),
                         list(data = train_data),
                         params_ranger))

    quantreg_testPred <- predict(trainRF, test_data, type = "quantiles", quantiles = c(alpha/2, 1-alpha/2))

    quantreg_interval <- data.frame(quantreg_testPred$predictions)

    colnames(quantreg_interval) <- c("lower", "upper")

  } else {
    quantreg_interval <- FALSE
  }

  if (is.null(testPred)) {
    trainRF <-do.call(ranger::ranger,
                      c(list(formula = formula),
                        list(data = train_data),
                        params_ranger))

    testPred <- predict(trainRF, test_data)$predictions
  }

  result <- list(oob_interval = oob_interval,
                 sc_interval = sc_interval,
                 quantreg_interval = quantreg_interval,
                 alpha = alpha,
                 testPred = testPred,
                 train_data = train_data,
                 test_data = test_data)

  return(result)
}


