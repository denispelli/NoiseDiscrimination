#clear the workspace
rm(list = ls())

# load the data
dat <- read.csv("xiuyun_conditions.csv")

# some transformations necessary for computation
dat$noise_decay_radius = replace(dat$noise_decay_radius, dat$noise_decay_radius==Inf,32)
dat$RadiusRelative2letter_size = dat$noise_decay_radius / (dat$letter_size/2)
dat <- subset(dat,dat$HardOrSoft=="soft")
dat <- subset(dat,dat$eccentricity==32)


# data used for our fitting (log fit)
test <- data.frame(x = log10(dat$RadiusRelative2letter_size), y = log10(dat$mean_threshold))

str(test)

# define the fit model
f.lrp <- function(x, a, b, t.x) ifelse(x > t.x, a + b * t.x, a + b * x)

# fit the model
logM.lrp <- nls(y ~ f.lrp(x, a, b, t.x), data = test, start = list(a = -2, b = 0.5, t.x = 1), trace = T, control = list(warnOnly = TRUE, minFactor = 1/2048) )
# show model fit
print(summary(logM.lrp))

coefficients(logM.lrp)

10^coefficients(logM.lrp)

max.yield <- coefficients(logM.lrp)["a"] + coefficients(logM.lrp)["b"] * coefficients(logM.lrp)["t.x"]

# compute the fit residuals
RSS.p <- sum(residuals(logM.lrp)^2)
TSS <- with(test, sum((y - mean(y))^2))
Rsquared <- 1 - (RSS.p/TSS)


# plot our result and the original data
plot(test$y ~ test$x, main = "Letter identification in a gaussian envelope of Noise Contrast: 0.16", xlab = "log10(Relative Radius: Decay Radius / Letter Radius)", ylab = "log10(Threshold Contrast)")

lines(x = c(min(test$x), coefficients(logM.lrp)["t.x"], max(test$x)), y = c(f.lrp(min(test$x), coef(logM.lrp)["a"], coef(logM.lrp)["b"], coef(logM.lrp)["t.x"]), max.yield, max.yield), lty = 1, col="red")
abline(v = coefficients(logM.lrp)["t.x"], lty = 4)
abline(h = max.yield, lty = 4)

text(x = rep(0.5, 5), y = seq(-0.4,-0.7, length.out = 5), labels = paste(c("max", "intercept", "slope", "saturation", "R^2"), round(c(max.yield, coef(logM.lrp), Rsquared), digits = 3), sep = " = "), adj = c(0,1))

# residual plot
#plot(residuals(logM.lrp))




##alternate linear fit
linearTest <- data.frame(x = dat$RadiusRelative2letter_size, y = dat$mean_threshold)

#fit the model
linM.lrp <- nls(y ~ f.lrp(x, a, b, t.x), data = linearTest, start = list(a = -2, b = 0.5, t.x = 1), trace = T, control = list(warnOnly = TRUE, minFactor = 1/2048) )

# show model fit
print(summary(linM.lrp))
coefficients(linM.lrp)

linMax.yield <- coefficients(linM.lrp)["a"] + coefficients(linM.lrp)["b"] * coefficients(linM.lrp)["t.x"]

# compute the fit residuals
lin.RSS.p <- sum(residuals(linM.lrp)^2)
lin.TSS <- with(linearTest, sum((y - mean(y))^2))
lin.Rsquared <- 1 - (RSS.p/TSS)


# plot our result and the original data
plot(linearTest$y ~ linearTest$x, log = "xy", main = "Noise Contrast: 0.16, Obs.: Xiuyun, Gaussian Pink Soft Noise", xlab = "Relative Radius: Decay Radius / Letter Radius", ylab = "Threshold Contrast")

lines(x = c(min(linearTest$x), coefficients(linM.lrp)["t.x"], max(linearTest$x)), y = c(f.lrp(min(linearTest$x), coef(linM.lrp)["a"], coef(linM.lrp)["b"], coef(linM.lrp)["t.x"]), linMax.yield, linMax.yield), lty = 1, col="red")
abline(v = coefficients(linM.lrp)["t.x"], lty = 4)
abline(h = linMax.yield, lty = 4)

text(x = rep(2, 20), y = seq(.45,.2, length.out = 5), labels = paste(c("max", "intercept", "slope", "saturation", "R^2"), round(c(linMax.yield, coef(linM.lrp), lin.Rsquared), digits = 3), sep = " = "), adj = c(0,1))

#power integration fit
xiuyunIntegrationFit <- read.csv("data/modelFit/xiuyunContrastFit.csv")
plot(linearTest$y ~ linearTest$x, log = "xy", main = "Noise Contrast: 0.16, Obs.: Xiuyun, Gaussian Pink Soft Noise", xlab = "Relative Radius: Decay Radius / Letter Radius", ylab = "Threshold Contrast")

matplot(linearTest$x,xiuyunIntegrationFit,add=T,type = 'l')
