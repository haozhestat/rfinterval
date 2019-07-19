#' Simulate data
#'
#' Simulate data for illustrate the performance of prediction intervals for random forests
#'
#' @param n Sample size
#' @param p Number of features
#' @param rho Correlation between predictors
#' @param predictor_dist Distribution of predictor: "uncorrelated", and "correlated"
#' @param mean_function Mean function: "linear", "nonlinear", and "nonlinear-interaction"
#' @param error_dist Distribution of error: "homoscedastic", "heteroscedastic", and "heavy-tailed"
#' @return a data.frame of simulated data
#' @examples
#' \donttest{
#' train_data <- sim_data(n = 500, p = 10)
#' test_data <- sim_data(n = 500, p = 10)
#' }
#' @export


sim_data <- function(n = 500,
                     p = 10,
                     rho = 0.6,
                     predictor_dist = "correlated",
                     mean_function = "nonlinear-interaction",
                     error_dist = "homoscedastic"){

  if (predictor_dist == "uncorrelated") {
    x <- matrix(rnorm(n*p, 0, 1), n, p)
  } else if (predictor_dist == "correlated") {
    #library(MASS)
    Sigma <- diag(rep(1,p))
    for(i in 1:p){
      for(j in i:p){
        Sigma[i,j] <- Sigma[j,i] <- rho^(abs(i-j))
      }
    }
    x <- MASS::mvrnorm(n, mu = rep(0,p), Sigma = Sigma)
  }
  x <- data.frame(x)
  colnames(x) <- paste0("X", 1:p)

  if (mean_function == "linear") {
    mx <- x[,1] + 2*x[,2]
  } else if (mean_function == "nonlinear") {
    mx <- exp(-abs(x[,1])-abs(x[,2]))
  } else if (mean_function == "nonlinear-interaction") {
    mx <- exp(-abs(x[,1])-abs(x[,2])) + x[,1]*x[,2]
  }


  if (error_dist == "homoscedastic") {
    epsilon <- rnorm(n, mean = 0, sd = 1)
  } else if(error_dist == "heavy-tailed") {
    epsilon <- rt(n, df = 2)
  } else if(error_dist == "heteroscedastic") {
    epsilon <- rnorm(n, mean = 0, sd = sqrt(1+abs(mx)/mean(abs(mx))))
  }

  y = mx + epsilon

  # if(!is.null(x0)){
  #   x0 <- matrix(x0, ncol = p)
  #
  #   if(mean_function == "linear")
  #     mx0 <- x0[,1] + 2*x0[,2]
  #   else if(mean_function == "nonlinear")
  #     mx0 <- exp(-abs(x0[,1])-abs(x0[,2]))
  #   else
  #     mx0 <- exp(-abs(x0[,1])-abs(x0[,2])) + x0[,1]*x0[,2]
  #
  #   if(error_dist == "homoscedastic")
  #     epsilon0 <- rnorm(nrow(x0), mean = 0, sd = sqrt(1))
  #   else if(error_dist == "heavy-tailed")
  #     epsilon0 <- rt(nrow(x0), df = 2)
  #   else
  #     epsilon0 <- rnorm(nrow(x0), mean = 0, sd = sqrt(1+abs(mx0)/mean(abs(mx))))
  #
  #   return(list(x = x, y = mx + epsilon, mx = mx, x0 = x0, y0 = mx0 + epsilon0, mx0 = mx0))
  # }

  output <- data.frame(cbind(y, x))

  return(output)
}
