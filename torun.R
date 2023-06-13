library(plumber)
pr <- plumb("/home/admin/Api_ISBN_Plumber/plumber.R")
pr$run(host='0.0.0.0', port = 7777, swagger = TRUE)