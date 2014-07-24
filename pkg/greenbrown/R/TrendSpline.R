TrendSpline <- structure(function(
	##title<< 
	## Trend estimation based on a smoothing splines
	
	##description<<
	## The function computes a non-linear trend based on \code{\link{smooth.spline}}. 
	
	Yt,
	### univariate time series of class \code{\link{ts}}
	
	...
	### additional arguments (currently not used)
	
	##seealso<<
	## \code{\link{stl}}
) {
	# get time series properties
	freq <- frequency(Yt)
	start <- start(Yt)
	end <- end(Yt)
	time <- time(Yt)	
	
	# do initial linear interpolation and initial gap filling
	Na <- ts(is.na(Yt), start=start, end=end, frequency=freq)
	xout <- time(Yt)
	Yt1 <- na.approx(Yt, xout=xout, rule=c(2,2))	
	Na1 <- na.approx(Na, xout=xout, method="constant", rule=c(2,2))	
	Yt1[Na1 == 1] <- Yt1[Na1 == 1] + rnorm(sum(Na1), 0, diff(range(Yt, na.rm=TRUE)) * 0.01)
	
	spl <- smooth.spline(Yt, spar=0.95)
	Tt <- ts(spl$y, start=start, end=end, frequency=freq)
	Tt[Na1 == 1] <- NA	
	
	# results: pvalue with MannKendall test
	mk <- MannKendall(Tt)
	mk.pval <- mk$sl 
	mk.tau <- mk$tau
	
	# return results
	result <- list(
		series = Yt,
		trend = Tt,
		time = as.vector(time),
		bp = NoBP(),
		slope = NA,
		pval = mk.pval,
		mk.tau = mk.tau,
		bptest = NULL,
		method = "Spline")
	class(result) <- "Trend"
	return(result)
	### The function returns a list of class "Trend" with the following components:
	### \itemize{ 
	### \item{ \code{series} time series on which the trend was calculated. }
	### \item{ \code{trend} time series with the estimated trend component. }
	### \item{ \code{time} a vector of time steps. }
	### \item{ \code{pval} Mann-Kendall test p-value of the trend component. }
	### }
}, ex=function(){
# load a time series of NDVI (normalized difference vegetation index)
data(ndvi)
plot(ndvi)
	
# calculate trend on mean annual NDVI values
trd <- TrendSpline(ndvi)
trd
plot(trd, symbolic=TRUE)

})
