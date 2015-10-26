
# load the data
dat <- read.csv("xiuyun_conditions.csv")

# some transformations necessary for computation
dat$noise_decay_radius = replace(dat$noise_decay_radius, dat$noise_decay_radius==Inf,32)
dat$RadiusRelative2letter_size = dat$noise_decay_radius / (dat$letter_size/2)
dat <- subset(dat, dat$noise_contrast == 0.16)


# data used for our fitting
test <- data.frame(x = log10(dat$RadiusRelative2letter_size), y = log10(dat$mean_threshold))
str(test)

# define the fit model
f.lrp <- function(x, a, b, t.x) ifelse(x > t.x, a + b * t.x, a + b * x)


# fit the model
m.lrp <- nls(y ~ f.lrp(x, a, b, t.x), data = test, start = list(a = -2, b = 0.5, t.x = 1), trace = T, control = list(warnOnly = TRUE, minFactor = 1/2048) )

# show model fit
print(summary(m.lrp))

coefficients(m.lrp)

10^coefficients(m.lrp)

max.yield <- coefficients(m.lrp)["a"] + coefficients(m.lrp)["b"] * coefficients(m.lrp)["t.x"]


# compute the fit residuals
RSS.p <- sum(residuals(m.lrp)^2)
TSS <- with(test, sum((y - mean(y))^2))
Rsquared <- 1 - (RSS.p/TSS)


# plot our result and the original data
plot(test$y ~ test$x, main = "Noise Contrast: 0.16, Obs.: Xiuyun, Gaussian Pink Soft Noise", xlab = "Relative Radius: Decay Radius / Letter Radius (Log10)", ylab = "Threshold Contrast (Log10)")

lines(x = c(min(test$x), coefficients(m.lrp)["t.x"], max(test$x)), y = c(f.lrp(min(test$x), coef(m.lrp)["a"], coef(m.lrp)["b"], coef(m.lrp)["t.x"]), max.yield, max.yield), lty = 1, col="red")
abline(v = coefficients(m.lrp)["t.x"], lty = 4)
abline(h = max.yield, lty = 4)

text(x = rep(0.5, 5), y = seq(-0.4,-0.7, length.out = 5), labels = paste(c("max", "intercept", "slope", "saturation", "R^2"), round(c(max.yield, coef(m.lrp), Rsquared), digits = 3), sep = " = "), adj = c(0,1))

# residual plot
plot(m.lrp)
