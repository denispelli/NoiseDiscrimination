require(ggplot2)
require(cowplot)

# load the data
dat <- read.csv("xiuyun_conditions.csv")

# some transformations necessary for computation
dat$noise_decay_radius = replace(dat$noise_decay_radius, dat$noise_decay_radius==Inf,32)
dat$RadiusRelative2letter_size = dat$noise_decay_radius / (dat$letter_size/2)
dat <- subset(dat, dat$noise_contrast == 0.16 & dat$HardOrSoft == "soft")



# data used for our fitting
# test <- data.frame(x = log10(dat$RadiusRelative2letter_size), y = log10(dat$mean_threshold), letter_size)
dat$x <- log10(dat$RadiusRelative2letter_size)
dat$y <- log10(dat$mean_threshold)
dat$X <- (dat$RadiusRelative2letter_size)
dat$Y <- (dat$mean_threshold)


str(dat)

# define the fit model
f.lrp <- function(x, a, b, t.x) ifelse(x > t.x, a + b * t.x, a + b * x)


# fit the model
m.lrp <- nls(y ~ f.lrp(x, a, b, t.x), data = dat, start = list(a = -2, b = 0.5, t.x = 1), trace = T, control = list(warnOnly = TRUE, minFactor = 1/2048) )

# show model fit
print(summary(m.lrp))

coefficients(m.lrp)

10^coefficients(m.lrp)

max.yield <- coefficients(m.lrp)["a"] + coefficients(m.lrp)["b"] * coefficients(m.lrp)["t.x"]


# compute the fit residuals
RSS.p <- sum(residuals(m.lrp)^2)
TSS <- with(dat, sum((y - mean(y))^2))
Rsquared <- 1 - (RSS.p/TSS)


# plot our result and the original data
with(dat, plot(y ~ x, pch = NA, bty = 'n'))
with(subset(dat, eccentricity == 0), points(y ~ x, pch = 0))
with(subset(dat, eccentricity == 32), points(y ~ x, pch = 1))
title(main = "Noise Contrast: 0.16, Obs.: Xiuyun, Gaussian Pink Soft Noise", xlab = "Relative Radius: Decay Radius / Letter Radius (Log10)", ylab = "Threshold Contrast (Log10)")

lines(x = c(min(dat$x), coefficients(m.lrp)["t.x"], max(dat$x)), y = c(f.lrp(min(dat$x), coef(m.lrp)["a"], coef(m.lrp)["b"], coef(m.lrp)["t.x"]), max.yield, max.yield), lty = 1, col="red")
abline(v = coefficients(m.lrp)["t.x"], lty = 4)
abline(h = max.yield, lty = 4)

text(x = rep(0.5, 5), y = seq(-0.4,-0.7, length.out = 5), labels = paste(c("max", "intercept", "slope", "saturation", "R^2"), round(c(max.yield, coef(m.lrp), Rsquared), digits = 3), sep = " = "), adj = c(0,1))
legend(1.15, -0.4, c("0", "32"), title = "Eccentricity", pch = c(0, 1))

# residual plot
plot(m.lrp)

ggplotRegression <- function (fit) {

  require(ggplot2)

  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) +
    geom_point() +
    stat_smooth(method = "nls", col = "red")
#     labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
#                        "Intercept =",signif(fit$coef[[1]],5 ),
#                        " Slope =",signif(fit$coef[[2]], 5),
#                        " P =",signif(summary(fit)$coef[2,4], 5)))
}



ylimits <- aes(ymax = log10(mean_threshold + sd_threshold), ymin=log10(mean_threshold - sd_threshold))
noGrid <- theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(), axis.line = element_line(colour = "black"))
mytheme <- theme_bw() +
  theme(panel.border=element_rect(color=NA), strip.background=element_rect(fill=NA),
        text=element_text(size=32), axis.text.x = element_text(angle = 60, hjust = 1))
niceLegend <- theme(legend.key = element_rect(colour = 'NA', fill = 'NA', size = 0.5), legend.background = element_rect(color = "black"), legend.justification = 'right', legend.position=c(1,0.6))

# Or using ggplot2
pp <- ggplot(dat, aes(x = x, y = y, shape = factor(eccentricity))) +
geom_point(size = 5) +
  geom_errorbar(ylimits, size = 1) +
stat_smooth(method = "nls",
            formula = y ~ f.lrp(x, a, b, t.x),
            start =  list(a = -2, b = 0.5, t.x = 1),
            se = FALSE, color = "red") +
  labs(title = "Noise Contrast: 0.16, Obs.: Xiuyun, Gaussian Pink Soft Noise", x = "Relative Radius: Decay Radius / Letter Radius (Log10)", y = "Threshold Contrast (Log10)") +
  scale_shape(solid = FALSE, name = "Eccentricity")


pp1 <- pp + noGrid + niceLegend

print(pp)

