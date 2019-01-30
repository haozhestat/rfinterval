

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
