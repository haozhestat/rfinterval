library(testthat)
library(rfinterval)

test_check("rfinterval")

BeijingPM25 <- BeijingPM25[sample.int(n=nrow(BeijingPM25), nrow(BeijingPM25)), ]

devtools::use_data(BeijingPM25, overwrite = TRUE)

output <- rfinterval(pm2.5~.,
                     train_data = BeijingPM25[1:1000, ],
                     test_data = BeijingPM25[1001:2000, ],
                     method = c("oob", "split-conformal", "quantreg"),
                     symmetry = TRUE,
                     alpha = 0.1)

y <- BeijingPM25[1001:2000, "pm2.5"]
mean(output$oob_interval$lo < y & output$oob_interval$up > y)
mean(output$sc_interval$lo < y & output$sc_interval$up > y)
mean(output$quantreg_interval$lo < y & output$quantreg_interval$up > y)
