# traffic data 
# read one large csv (agg!) > proc to one rds df > create city aggregates
set.seed(12345)

# library(anytime) 
library(readr)

# messaging file
fileConn <- file("/RDS/Q1071/TEMPO_BCC-traffic/data/clean/bcc_2019_04_agg.txt", "w")
writeLines(paste(Sys.time(), "Job started"), fileConn)

bcc_2019_04_agg <- read_csv("bcc_2019_04_agg.csv")

writeLines(paste(Sys.time(), "csv loaded"), fileConn)
writeLines(paste(print(object.size(x=lapply(ls(), get)), units="Gb"), "Gb csv size"), fileConn)

# duplicates
writeLines(paste(nrow(bcc_2019_04_agg), "lines in raw data"), fileConn)
bcc_2019_04_agg <- bcc_2019_04_agg[!duplicated(bcc_2019_04_agg), ]
writeLines(paste(nrow(bcc_2019_04_agg), "lines without duplicates"), fileConn)

# converting time zone ???
# attr(bcc_2019_04_agg$recorded, "tzone") <- "Australia/Brisbane"
# bcc_2019_04_agg$recorded <- bcc_2019_04_agg$recorded - 10*60*60

# sort on time > tsc > lane 
bcc_2019_04_agg <- bcc_2019_04_agg[order(bcc_2019_04_agg$recorded, bcc_2019_04_agg$tsc), ]

saveRDS(bcc_2019_04_agg, "bcc_2019_04_agg.Rds")

system("mv bcc_2019_04_agg.Rds /RDS/Q1071/TEMPO_BCC-traffic/data/clean/")

writeLines(paste(Sys.time(), "Rds created"), fileConn)

# city aggregates
bcc_2019_04_city <- aggregate(mf ~ recorded, bcc_2019_04_agg, sum)
saveRDS(bcc_2019_04_city, "bcc_2019_04_city.Rds")

system("mv bcc_2019_04_city.Rds /RDS/Q1071/TEMPO_BCC-traffic/data/clean/")

writeLines(paste(Sys.time(), "city created"), fileConn)

# plots 
# daily curves
library(ggplot2)

ggplot(bcc_2019_04_agg, aes(x = recorded, y = mf)) + 
  geom_line(aes(group = tsc), alpha = 0.01) + 
  geom_smooth() +
  scale_x_datetime() + theme_minimal() + xlab("") + ylab("Measured flow (all lanes)")

ggsave("bcc_2019_04_agg.png", width = 32, height = 18, units = "cm", dpi = 300)

system("mv bcc_2019_04_agg.png /RDS/Q1071/TEMPO_BCC-traffic/data/clean/")

# city curve
ggplot(bcc_2019_04_city, aes(x = recorded, y = mf)) + 
  geom_line(alpha = 0.75) + 
  geom_smooth() +
  scale_x_datetime() + theme_minimal() + xlab("") + ylab("Measured flow (city)")

ggsave("bcc_2019_04_city.png", width = 32, height = 18, units = "cm", dpi = 300)

system("mv bcc_2019_04_city.png /RDS/Q1071/TEMPO_BCC-traffic/data/clean/")

writeLines(paste(Sys.time(), "Finished"), fileConn)
close(fileConn)