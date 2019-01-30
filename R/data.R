#' Beijing PM2.5 Air Pollution Data
#'
#' This hourly data set contains the PM2.5 data of US Embassy in Beijing. Meanwhile, meteorological data from Beijing Capital International Airport are also included.
#'
#' @format A data frame with 8661 rows and 11 variables:
#' \describe{
#'   \item{pm2.5}{PM2.5 concentration (ug/m^3) }
#'   \item{month}{month of observation}
#'   \item{day}{day of observation}
#'   \item{hour}{hour of observation}
#'   \item{DEWP}{dew point}
#'   \item{TEMP}{temperature}
#'   \item{PRES}{air pressure}
#'   \item{cbwd}{combined wind direction}
#'   \item{Iws}{cumulated wind speed}
#'   \item{Is}{cumulated hours of snow}
#'   \item{Ir}{cumulated hours of rain}
#' }
#' @source Liang, X., Zou, T., Guo, B., Li, S., Zhang, H., Zhang, S., Huang, H. and Chen, S. X. (2015). Assessing Beijing's PM2.5 pollution: severity, weather impact, APEC and winter heating. Proceedings of the Royal Society A, 471, 20150257.
"BeijingPM25"
