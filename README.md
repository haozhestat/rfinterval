

### Installation

To install the R package *rfinterval* directly from github, run the following in R:

```{r}
install.packages("devtools")
devtools::install_github(repo="haozhestat/rfinterval")
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
y <- test_data$y
### print the marginal coverage of OOB prediction interval
mean(output$oob_interval$lo < y & output$oob_interval$up > y)
### print the marginal coverage of Split-conformal prediction interval
mean(output$sc_interval$lo < y & output$sc_interval$up > y)
### print the marginal coverage of Quantile regression forest prediction interval
mean(output$quantreg_interval$lo < y & output$quantreg_interval$up > y)
``` 
