## rfinterval: Predictive Inference on Random Forests (beta)
Haozhe Zhang

### Introduction
*rfinterval* is a fast implementation of random forest prediction intervals described in the paper "*Random Forest Prediction Intervals*" by Haozhe Zhang, Joshua Zimmerman, Dan Nettleton, and Daniel J. Nordman. This R package produce out-of-bag prediction intervals, split conformal prediction intervals, and quantile regression forest intervals for random forest predictions.

### Installation

To install the R package *rfinterval* directly from github, run the following in R:

```{r}
install.packages("devtools")
devtools::install_github(repo="haozhestat/rfinterval")
library(rfinterval)
?rfinterval
```  

### Usage
Quickstart:
```{r}
train_data <- sim_data(n = 1000, p = 10)
test_data <- sim_data(n = 1000, p = 10)

output <- rfinterval(y~., train_data = train_data, test_data = test_data,
                     method = c("oob", "split-conformal", "quantreg"),
                     symmetry = TRUE,alpha = 0.1)
                     
### print the marginal coverage of OOB prediction interval
mean(output$oob_interval$lo < test_data$y & output$oob_interval$up > test_data$y)

### print the marginal coverage of Split-conformal prediction interval
mean(output$sc_interval$lo < test_data$y & output$sc_interval$up > test_data$y)

### print the marginal coverage of Quantile regression forest prediction interval
mean(output$quantreg_interval$lo < test_data$y & output$quantreg_interval$up > test_data$y)
``` 

Data example:
```{r}
oob_interval <- rfinterval(pm2.5 ~ .,
                            train_data = BeijingPM25[1:1000, ],
                            test_data = BeijingPM25[1001:2000, ],
                            method = "oob",
                            symmetry = TRUE,
                            alpha = 0.1)
str(oob_interval)
```

If you find any bugs, or if you experience any crashes, please report to us. If you have any questions just ask, we won't bite. 

Please cite our paper if you use *rfinterval*.

### References
* Zhang, H., Zimmerman, J., Nettleton, D. and Nordman, D. (2019+). "Random Forest Prediction Intervals." Tentatively Accepted by The American Statistician.
* Lei, J., Max G’Sell, A. R., Tibshirani, R.J., and Wasserman, L. "Distribution-free predictive inference for regression." Journal of the American Statistical Association 113, no. 523 (2018): 1094-1111.
* Meinshausen, N. "Quantile regression forests." Journal of Machine Learning Research 7, no. Jun (2006): 983-999.
* Liang, X., Zou, T., Guo, B., Li, S., Zhang, H., Zhang, S., Huang, H. and Chen, S.X., 2015. "Assessing Beijing's PM2. 5 pollution: severity, weather impact, APEC and winter heating". Proc. R. Soc. A, 471(2182), p.20150257.
