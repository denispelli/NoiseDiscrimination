rm(list = ls())


require(ggplot2)
require(cowplot)
require(Hmisc)

# load the data
dat <- read.csv("xiuyun_conditions.csv")

if (FALSE){
dat <- read.csv("XiuyunWeek123.csv")
dat$noise_decay_radius <- dat$NoiseDecayRadius
dat$letter_size <- dat$LetterSize
dat$noise_contrast <- dat$NoiseContrast
dat$mean_threshold <- dat$ThresholdContrast
dat$eccentricity <- round(dat$Eccentricity - 0.45,digits = 2)
}

# some transformations necessary for computation
dat$noise_decay_radius <- replace(dat$noise_decay_radius, dat$noise_decay_radius==Inf,32)
dat$RadiusRelative2letter_size <- dat$noise_decay_radius / (dat$letter_size/2)
dat <- subset(dat, dat$noise_contrast == 0.16 & dat$HardOrSoft == "soft")
# dat <- subset(dat, dat$noise_contrast %in% c(0.1) & eccentricity %in% c(0,2,8))



# data used for our fitting
# test <- data.frame(x = log10(dat$RadiusRelative2letter_size), y = log10(dat$mean_threshold), letter_size)
dat$x <- log10(dat$RadiusRelative2letter_size)
dat$y <- log10(dat$mean_threshold)
dat$X <- (dat$RadiusRelative2letter_size)
dat$Y <- (dat$mean_threshold)


#str(dat)

# define the fit model
f.lrp <- function(x, a, b, t.x) ifelse(x > t.x, a + b * t.x, a + b * x)


# fit the model
m.lrp <- nls(y ~ f.lrp(x, a, b, t.x), data = dat, start = list(a = -0.5, b = 0.64, t.x = .5), trace = T, control = list(warnOnly = TRUE, minFactor = 1/2048) )

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
with(dat, plot(y ~ x, pch = NA, bty = 'n', axes = FALSE, xlab = NA, ylab = NA))
# with(subset(dat, eccentricity == 0), points(y ~ x, pch = 0))
# with(subset(dat, eccentricity == 32), points(y ~ x, pch = 1))
with(subset(dat, eccentricity == 0), points(y ~ x, pch = 0))
if (FALSE){
with(subset(dat, eccentricity == 2), points(y ~ x, pch = 1))
with(subset(dat, eccentricity == 8), points(y ~ x, pch = 2))
}
with(subset(dat, eccentricity == 32), points(y ~ x, pch = 1))
title(main = "Gaussian Pink Noise Contrast: 0.16", xlab = "Log Decay Radius / Letter Radius", ylab = "Log Threshold Contrast")

lines(x = c(min(dat$x), coefficients(m.lrp)["t.x"], max(dat$x)), y = c(f.lrp(min(dat$x), coef(m.lrp)["a"], coef(m.lrp)["b"], coef(m.lrp)["t.x"]), max.yield, max.yield), lty = 1, col="red")
# abline(v = coefficients(m.lrp)["t.x"], lty = 4)
# abline(h = max.yield, lty = 4)

text(x = rep(0.5, 5), y = seq(-0.4,-0.7, length.out = 5), labels = paste(c("max", "intercept", "slope", "saturation", expression(R^2)), round(c(10^max.yield, 10^coef(m.lrp), Rsquared), digits = 3), sep = " = "), adj = c(0,1))
legend(1.15, -0.4, paste(c(0,32), "deg"), title = "Eccentricity", pch = c(0, 1))

axis.log <- function(whichAxis=1, x, nBreak, nTicks, Digits=2)
{

  Labels <- pretty(log10(x), nBreak)
  Ticks <- pretty(log10(x), nBreak*nTicks)
  isLabels <- Ticks %in% Labels
  Str = c()
  Str[isLabels] <- format(round(10^Labels, digits = Digits), digits = Digits)
  Str[!isLabels] <- NA
  axis(whichAxis, at = Ticks, labels = Str)
}

axis(1, at = axTicks(1), labels = format(round(10^axTicks(1), digits = 2), digits = 2))
axis(2, at = axTicks(2), labels = format(round(10^axTicks(2), digits = 2), digits = 2))

# NOT used
minor.ticks.axis <- function(ax,n,t.ratio=0.5,mn,mx,...){

  lims <- par("usr")
  if(ax %in%c(1,3)) lims <- lims[1:2] else lims[3:4]

  major.ticks <- pretty(lims,n=5)
  if(missing(mn)) mn <- min(major.ticks)
  if(missing(mx)) mx <- max(major.ticks)

  major.ticks <- major.ticks[major.ticks >= mn & major.ticks <= mx]

  labels <- sapply(major.ticks,function(i)
    as.expression(bquote(10^ .(i)))
  )
  axis(ax,at=major.ticks,labels=labels,...)

  n <- n+2
  minors <- log10(pretty(10^major.ticks[1:2],n))-major.ticks[1]
  minors <- minors[-c(1,n)]

  minor.ticks = c(outer(minors,major.ticks,`+`))
  minor.ticks <- minor.ticks[minor.ticks > mn & minor.ticks < mx]


  axis(ax,at=minor.ticks,tcl=par("tcl")*t.ratio,labels=FALSE)
}
# minor.ticks.axis(1, 9, -0.5, 1.5)

minor.tick(5)


# residual plot
# plot(m.lrp)
<<<<<<< HEAD
if (FALSE) {
=======
if (TRUE) {
>>>>>>> 121f24975578011928e6b920a78e0d8068afe44e

ggplotRegression <- function (fit) {
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
pp <- ggplot(dat, aes(x = x, y = y, shape = factor(eccentricity), color = factor(LetterSize))) +
geom_point(size = 5) +
  geom_errorbar(ylimits, size = 1) +
stat_smooth(method = "nls",
            formula = y ~ f.lrp(x, a, b, t.x),
            start =  list(a = -2, b = 0.5, t.x = 1),
            se = FALSE, color = "red") +
  labs(title = "Gaussian Pink Noise Contrast: 0.16", x = "Log Decay Radius / Letter Radius", y = "Log Threshold Contrast") +
  scale_shape(solid = FALSE, name = "Eccentricity")



pp1 <- pp + noGrid + niceLegend

print(pp)

}
