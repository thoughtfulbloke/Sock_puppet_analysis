key_sockpuppet_indicator <- function(x){
  collection <- sort(sample(-600:600, size=x, replace=TRUE))
  seconds_before_without = tryCatch(max(collection[collection <= 0]),
                                    error = function(e) -600, warning = function(w) -600)
  
  seconds_after_without = tryCatch(min(collection[collection >= 0]),
                                   error = function(e) 600, warning = function(w) 600)
  before_quartile = collection[ceiling(.25*length(collection))]
  after_quartile = collection[ceiling(.75*length(collection))]
  silence_at_zero = seconds_after_without - seconds_before_without
  central_half = (after_quartile - before_quartile)
  if(central_half == 0){central_half <- 1201}
  return(paste(silence_at_zero/ central_half))
}

sizes <- c(400, 4000, 40000, 400000)
nearby_tweets = 150 # max sample size of tweets within +/- 10 minutes
for (replication_size in sizes) {
  replication_results = data.frame(samplesize = 1:nearby_tweets)
  replication_results$lower_bound <- 0
  replication_results$upper_bound <- 1
  replications = data.frame(replication_no = 1:replication_size)
  replications$ksi <- 0
  
  go <- Sys.time()
  for (i in 1:nearby_tweets) {
    for (j in 1:replication_size) {
      replications$ksi[j] <- key_sockpuppet_indicator((i * 10))
    }
    replication_results$lower_bound[i] <- min(replications$ksi)
    replication_results$upper_bound[i] <- max(replications$ksi)
    if ((i %% 10) == 0) {
      print(i)
    }
  }
  stop <- Sys.time()
  write.csv(
    replication_results,
    file = paste0("bounds", replication_size, ".csv"),
    row.names = FALSE
  )
  it_took <- difftime(stop, go, units = "hours")
  print(it_took)
}
#42 hours for the bounds400K