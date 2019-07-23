# traffic data 
# read multiple JSONs > save as one csv
set.seed(12345)

library(jsonlite) 
library(readr)

# messaging file
fileConn <- file("/RDS/Q0786/data/BCC/traffic/raw/bcc_2019_04.txt", "w")

# loop prep
names <- list.files(pattern  =".json") #, full.names = TRUE)

writeLines(paste(Sys.time(), "Found", length(names), "files"), fileConn)

temp <- jsonlite::fromJSON(names[1], flatten=TRUE)
write_csv(temp, "bcc_2019_04.csv", append = FALSE, col_names = TRUE)

temp <- temp[!duplicated(temp), ]
temp <- temp[order(temp$recorded, temp$tsc, temp$lane), ]
temp$mf <- rowSums(temp[,c("mf1", "mf2", "mf3", "mf4")], na.rm = TRUE)
temp <- subset(temp, select = -c(ds1, ds2, ds3, ds4, mf1, mf2, mf3, mf4, rf1, rf2, rf3, rf4))
temp_agg <- aggregate(mf ~ recorded + tsc, temp, sum)
write_csv(temp_agg, "bcc_2019_04_agg.csv", append = FALSE, col_names = TRUE)

rm(temp, temp_agg)

# loop 
for (i in 2:length(names)) {
  
  temp <- jsonlite::fromJSON(names[i], flatten=TRUE)
  write_csv(temp, "bcc_2019_04.csv", append = TRUE, col_names = FALSE)

  temp <- temp[!duplicated(temp), ]
  temp <- temp[order(temp$recorded, temp$tsc, temp$lane), ]
  
  # some files can have lane4 missing
  if(! "ds4" %in% colnames(temp)) {
	temp$ds4 <- NA
  }  
  if(! "mf4" %in% colnames(temp)) {
	temp$mf4 <- NA
  }  
  if(! "rf4" %in% colnames(temp)) {
	temp$rf4 <- NA
  }  
  
  temp$mf <- rowSums(temp[,c("mf1", "mf2", "mf3", "mf4")], na.rm = TRUE)
  temp <- subset(temp, select = -c(ds1, ds2, ds3, ds4, mf1, mf2, mf3, mf4, rf1, rf2, rf3, rf4))
  temp_agg <- aggregate(mf ~ recorded + tsc, temp, sum)
  write_csv(temp_agg, "bcc_2019_04_agg.csv", append = TRUE, col_names = FALSE)
  print(paste("finished:", names[i]))
  rm(temp, temp_agg)
  
  # if (i %in% seq(from = 1000, to = length(names), by = 1000)) {
  #   writeLines(paste(Sys.time(), "Done", i, "files"), fileConn)
  # }
  
}

rm(names)
rm(i)

writeLines(paste(Sys.time(), "Processed"), fileConn)

system("mv bcc_2019_04.csv /RDS/Q0786/data/BCC/traffic/raw/")
system("mv bcc_2019_04_agg.csv /RDS/Q0786/data/BCC/traffic/raw/")

writeLines(paste(Sys.time(), "Finished"), fileConn)
close(fileConn)