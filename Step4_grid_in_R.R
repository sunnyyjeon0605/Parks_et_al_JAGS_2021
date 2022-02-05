
id = read.csv("V:/Health and Retirement Study/Sun/Anna Park/SAS interim/cohort_id_10232020.csv")

id_mx = rep(as.matrix(id), each=38)
time = seq(0, 7.4, by=0.2)
time_mx = rep(time, nrow(id))
grid = rep.int(1, length(time_mx))

grid_mx = cbind(id_mx, time_mx, grid)

write.csv(as.data.frame(grid_mx), "V:/Health and Retirement Study/Sun/Anna Park/SAS interim/grid_id_time_1022.csv")
