# define the fit model
modelNeq <- function(p, dat) (p[1]*max(dat$targetSize/2, p[2]*dat$eccentricity) )^2

modelNeq <- function(p, dat) p[1]*( (dat$targetSize/2)^2 + (p[2]*(dat$eccentricity+0.15))^2 + p[3])
f.lrp <- function(p, dat) sqrt(mean( log10(dat$meanNeq/modelNeq(p, dat) )^2))
p.optim <- optim(c(1e-6,0.1, 1), f.lrp, dat=subset(T, T$noiseContrast>0), control = list(maxit = 1e8, trace = TRUE,REPORT= 500))
T$fitNeq <- T$meanNeq
T$fitNeq[T$noiseContrast==0] <- NaN
T$fitNeq[T$noiseContrast>0] <- modelNeq(p.optim$par, subset(T, T$noiseContrast>0))
print(p.optim)

xbreaks = c(0.5, 1, 2, 4, 6, 8, 16, 32)
ybreaks = c(1e-06, 1e-05, 1e-04, 1e-03, 1e-02)
ylimits = aes(ymax = meanNeq + sdNeq, ymin=meanNeq - sdNeq)
ppfit <- ggplot(subset(T, T$noiseContrast>0), aes(x=targetSize, y=meanNeq, color=factor(shiftedEccentricity))) +
  geom_errorbar(ylimits, width=0.1)+
  geom_line(aes(y=fitNeq))+
  geom_point(alpha=0.6, size=8)+
  geom_segment(aes(x = 1, y = 1e-6, xend = 10, yend = 1e-4), color="black", linetype="dashed", size=1.5)+
  scale_y_log10(breaks=ybreaks, limits = c(3e-7, 5e-4))+
  scale_x_log10(breaks=xbreaks, label=as.character(xbreaks))+
  scale_linetype_manual(values=c("solid", "longdash"))+
  scale_color_brewer(name=expression(Eccentricity[shifted]~ (deg)), labels = sort(unique(bakT$eccentricity)),type="div",  palette = 7) +
  #scale_color_brewer(type="div",  palette = 7)
  noGrid+
  facet_grid(.~targetKind)+
  labs(title = "Object Identification", x = "Target Size (deg)", y = expression(Neq~(deg^2)))+
  annotate("text", hjust=1, x = 16, y = 3e-7, label = c("log-log slope: 2"), size=8) +
  annotate("text", hjust=1, x = 16, y = 5e-7, label = c("Global Gaussian White Noise"), size=8) +
  annotate("text", hjust=1, x = 16, y = 7e-7, label = paste(observer), size=8) +
  theme(text=element_text(size=32))
print(ppfit)
ggsave('lastfit.png', ppfit, width = 30, height = 20, units = "cm")
#
# [1] 2.7e-06 1.2e-01
#
# $value
# [1] 0.12
#
# $par
# [1] 1.5e-06 1.6e-01
#
# $value
# [1] 0.19
