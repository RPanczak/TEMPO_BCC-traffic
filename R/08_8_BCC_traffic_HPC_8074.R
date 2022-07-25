# traffic data 
# selecting for St Lucia

set.seed(12345)

library(readr)

# messaging file
fileConn <- file("/RDS/Q0786/data/BCC/traffic/clean/traffic_8074.txt", "w")
writeLines(paste(Sys.time(), "Job started"), fileConn)

# input
traffic_8074 <- read_csv("traffic_8074.csv")

traffic_8074 <- traffic_8074[!duplicated(traffic_8074), ]
traffic_8074 <- traffic_8074[order(traffic_8074$recorded, traffic_8074$tsc, traffic_8074$lane), ]

saveRDS(traffic_8074, traffic_8074.Rds)

system("mv traffic_8074.Rds /RDS/Q0786/data/BCC/traffic/clean/")

writeLines(paste(Sys.time(), "Finished"), fileConn)
close(fileConn)
