f.lrp <- function(x, a, b, t.x) {
  ifelse(x > t.x, a + b * t.x, a + b * x)
   }

dat <- read.csv("xiuyun_conditions.csv")
dat$noise_decay_radius = replace(dat$noise_decay_radius, dat$noise_decay_radius==Inf,32)
dat$RadiusRelative2letter_size = dat$noise_decay_radius / (dat$letter_size/2)
dat <- subset(dat, dat$noise_contrast == 0.16)

test <- data.frame(x = log10(dat$RadiusRelative2letter_size), y = log10(dat$mean_threshold))

# f.lvls <- seq(0, 120, by = 10)
# a.0 <- 2
# b.0 <- 0.05
# t.x.0 <- 70
# test <- data.frame(x = f.lvls, y = f.lrp(f.lvls, a.0,
                                         # b.0, t.x.0))
# test <- rbind(test, test, test)
# set.seed <- 619
# test$y <- test$y + rnorm(length(test$y), 0, 0.2)
str(test)

# (max.yield <- a.0 + b.0 * t.x.0)

# lines(x = c(0, t.x.0, 120), y = c(a.0, max.yield, max.yield), lty = 2)
# abline(v = t.x.0, lty = 3)
# abline(h = max.yield, lty = 3)


# test$rep <- as.factor(rep(1:3, each = length(test$y)/3))
# str(test)

# by(test$y, test$rep, mean)

m.lrp <- nls(y ~ f.lrp(x, a, b, t.x), data = test, start = list(a = -2, b = 0.5, t.x = 1), trace = T, control = list(warnOnly = TRUE, minFactor = 1/2048) )
summary(m.lrp)
coefficients(m.lrp)


# lines(x = c(0, t.x.0, 120), y = c(a.0, max.yield, max.yield), lty = 2, col = "blue")
# abline(v = t.x.0, lty = 3, col = "blue")
# abline(h = max.yield, lty = 3, col = "blue")
max.yield <- coefficients(m.lrp)["a"] + coefficients(m.lrp)["b"] * coefficients(m.lrp)["t.x"]

RSS.p <- sum(residuals(m.lrp)^2)
TSS <- with(test, sum((y - mean(y))^2))
Rsquared <- 1 - (RSS.p/TSS)


plot(test$y ~ test$x, main = "Noise Contrast: 0.16, Obs.: Xiuyun, Gaussian Pink Soft Noise", xlab = "Relative Radius: Decay Radius / Letter Radius (Log10)", ylab = "Threshold Contrast (Log10)")

lines(x = c(min(test$x), coefficients(m.lrp)["t.x"], max(test$x)), y = c(f.lrp(min(test$x), coef(m.lrp)["a"], coef(m.lrp)["b"], coef(m.lrp)["t.x"]), max.yield, max.yield), lty = 1, col="red")
abline(v = coefficients(m.lrp)["t.x"], lty = 4)
abline(h = max.yield, lty = 4)

text(x = rep(0.5, 5), y = seq(-0.4,-0.7, length.out = 5), labels = paste(c("max", "intercept", "slope", "saturation", "R^2"), round(c(max.yield, coef(m.lrp), Rsquared), digits = 3), sep = " = "), adj = c(0,1))

plot(m.lrp)
