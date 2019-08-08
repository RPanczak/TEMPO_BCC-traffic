# traffic data 
# read proc monthly rds to one rds df > create city aggregates
set.seed(12345)

fileConn <- file("/RDS/Q1071/TEMPO_BCC-traffic/data/clean/BCC_raw.txt", "w")

writeLines(paste(Sys.time(), "Started"), fileConn)

files <- list.files(pattern = "agg.Rds")

for (i in 1:length(files)) assign(files[i], readRDS(files[i]))
rm(files, i)

BCC_raw <- rbind(back_01_agg.Rds, back_02_agg.Rds, bcc_2018_09_agg.Rds, bcc_2018_10_agg.Rds, bcc_2018_11_agg.Rds, 
                 bcc_2018_12_agg.Rds, bcc_2019_01_agg.Rds, bcc_2019_02_agg.Rds, bcc_2019_03_agg.Rds, bcc_2019_04_agg.Rds, 
                 bcc_2019_05_agg.Rds, bcc_2019_06_agg.Rds, bcc_2019_07_agg.Rds)

rm(back_01_agg.Rds, back_02_agg.Rds, bcc_2018_09_agg.Rds, bcc_2018_10_agg.Rds, bcc_2018_11_agg.Rds, 
   bcc_2018_12_agg.Rds, bcc_2019_01_agg.Rds, bcc_2019_02_agg.Rds, bcc_2019_03_agg.Rds, bcc_2019_04_agg.Rds, 
   bcc_2019_05_agg.Rds, bcc_2019_06_agg.Rds, bcc_2019_07_agg.Rds)


# duplicates
BCC_raw <- BCC_raw[!duplicated(BCC_raw), ]

#order
BCC_raw <- BCC_raw[order(BCC_raw$recorded, BCC_raw$tsc), ]

saveRDS(BCC_raw, "BCC_raw.Rds")

system("mv BCC_raw.Rds /RDS/Q1071/TEMPO_BCC-traffic/data/clean/")

writeLines(paste(Sys.time(), "Finished"), fileConn)
close(fileConn)

