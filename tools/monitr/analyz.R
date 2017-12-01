# create a working copy, so we cant accidentally loose all data
ts = osem_counts_ts

# compute our own measurements per minute, to check against the provided computation
ts$measurement_diff = c(diff(ts$measurements), 0)
ts$measurement_minute = ts$measurement_diff / c(as.numeric(diff(ts$time), unit = 'mins'), 0)

plot(measurements~time, ts)
plot(measurements_per_minute~time, ts)
