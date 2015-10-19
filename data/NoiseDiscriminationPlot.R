library(car)
library(MASS)
library(plyr)
library(ggplot2)
library(Hmisc)
library(reshape2)
options(digits=2)

mytheme <- theme_bw() +
  theme(panel.border=element_rect(color=NA), strip.background=element_rect(fill=NA),
        text=element_text(size=32), axis.text.x = element_text(angle = 60, hjust = 1))


ylimits = aes(ymax = ThresholdContrast + ThresholdContrastSD, ymin=ThresholdContrast - ThresholdContrastSD)
y2limits = aes(ymax = ThresholdContrast^2 + ThresholdContrastSD^2, ymin=ThresholdContrast^2 - ThresholdContrastSD^2)
xbreaks = c(0.5, 1, 2, 3, 6, 9, 16, 32)
ybreaks = c(0.1, 0.15, 0.2, 0.3, 0.5, 0.7, 1, 1.5, 2.0)
pp = list()

T <- read.csv("XiuyunWeek123.csv")
T$NoiseDecayRadius = replace(T$NoiseDecayRadius, T$NoiseDecayRadius==Inf,32)
T$RadiusRelative2LetterSize = round(T$NoiseDecayRadius / T$LetterSize, digits = 2)
T$Eccentricity = T$Eccentricity - 0.45
#NoiseDecayRadius = factor(NoiseDecayRadius, c(1,2,3,5,6,8,9,16))


# dat <- within(T, {
#   id = factor(S.No.)
#  LetterSize = factor(LetterSize, c(2,3,6))
#   Eccentricity = factor(Eccentricity, c(0,2,8,32))
#  Trials = factor(Trials, c(80, 100))
# })


#t1<-ftable(xtabs(~cond+resp, dat))
#average=t1[,2]/(t1[,1]+t1[,2])

# a=c()
# t2<-ftable(xtabs(~cond+resp+id, dat))
# for (i in 1:4) {a=append(a, (t2[2*i,]/(t2[2*i-1,]+t2[2*i,])))}
# a=matrix(a, 4, 7, 1)
# rownames(a) = c("angry", "neutral", "happy", "baseline")
# colnames(a) = paste("id:", 1:7, sep="")
# print(cbind(a, b))
# A = melt(a)
# colnames(A)<-c("cond","id","OutwardFreq")
# A=subset(A, id!=3)
# A=subset(A, id!=2)




pp[[1]] <- ggplot(T, aes(x=NoiseDecayRadius, y=ThresholdContrast, size=factor(LetterSize), color=factor(NoiseContrast), linetype=factor(Eccentricity), shape=factor(Eccentricity) )) +
  geom_errorbar(ylimits)+
  geom_line()+
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=ybreaks)+
  scale_x_log10(breaks=xbreaks)+
  scale_linetype_manual(values=c("solid", "longdash", "dashed", "dotted"))+
  scale_size_discrete(range=c(1.5,4)) +
  #scale_color_brewer(type="div",  palette = 7)+
  theme(text=element_text(size=32))



pp[[2]] <- ggplot(T, aes(x=NoiseDecayRadius, y=ThresholdContrast, size=factor(LetterSize), color=factor(NoiseContrast), linetype=factor(Eccentricity), shape=factor(Eccentricity) )) +
  facet_grid(Eccentricity ~ .) +
  geom_errorbar(ylimits)+
  geom_line()+
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=c(1/4, 1/2,1,2))+
  scale_x_log10(breaks=xbreaks)+
  scale_linetype_manual(values=c("solid", "longdash", "dashed", "dotted"))+
  scale_size_discrete(range=c(1.5,4)) +
  #scale_color_brewer(type="div",  palette = 7)+
  theme(text=element_text(size=32))

print(pp[[2]])

pp[[3]] <- ggplot(T, aes(x=NoiseDecayRadius, y=ThresholdContrast, size=factor(LetterSize), color=factor(NoiseContrast), linetype=factor(Eccentricity), shape=factor(Eccentricity) )) +
  facet_grid(LetterSize ~ .) +
  geom_errorbar(ylimits)+
  geom_line()+
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=c(1/4, 1/2,1,2))+
  scale_x_log10(breaks=xbreaks)+
  scale_linetype_manual(values=c("solid", "longdash", "dashed", "dotted"))+
  scale_size_discrete(range=c(1.5,4)) +
  #scale_color_brewer(type="div",  palette = 7)+
  theme(text=element_text(size=32))

print(pp[[3]])

T$shiftedNoiseContrast = T$NoiseContrast + 0.08

pp[[4]] <- ggplot(subset(T, T$LetterSize==2), aes(x=shiftedNoiseContrast, y=ThresholdContrast, size=factor(LetterSize), color=factor(NoiseDecayRadius), linetype=factor(Eccentricity), shape=factor(Eccentricity) )) +
  facet_grid(Eccentricity ~ .) +
  geom_errorbar(ylimits)+
  geom_line()+
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=c(1/4, 1/2,1,2))+
  scale_x_log10(breaks=c(0.08, 0.1, 0.16, 0.2, 0.35))+
  scale_linetype_manual(values=c("solid", "longdash", "dashed", "dotted"))+
  scale_size_discrete(range=c(1.5,4)) +
  #scale_color_brewer(type="div",  palette = 7)+
  theme(text=element_text(size=32))

pp[[5]] <- ggplot(T, aes(x=RadiusRelative2LetterSize, y=ThresholdContrast, color=factor(NoiseContrast))) +
  #geom_errorbar(ylimits)+
  geom_line(position = position_jitter())+
  facet_grid(Eccentricity ~ .) +
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=ybreaks)+
  scale_x_log10(breaks=unique(T$RadiusRelative2LetterSize))+
  scale_linetype_manual(values=c("solid", "longdash", "dashed", "dotted"))+
  scale_size_discrete(range=c(1.5,4)) +
 # scale_color_brewer(type="seq",  palette = 8)+
  theme(text=element_text(size=32), axis.text.x = element_text(angle = 45, hjust = 1), axis.text.y = element_text(size=18))

pp[[6]] <- ggplot(subset(T,  (T$Eccentricity %in% c(0,32))), aes(x=RadiusRelative2LetterSize, y=ThresholdContrast, color=factor(NoiseContrast), linetype=factor(Eccentricity) )) +
  #geom_errorbar(ylimits, size=2, alpha=1)+
  stat_summary(fun.y=mean, ylimits, geom="smooth", size = 2) +
  #geom_line(size=2, aes(linetype=factor(Eccentricity)))+
  geom_point(size=7, alpha=0.5, aes(shape=factor(LetterSize)))+
  scale_y_log10(breaks=ybreaks)+
  scale_x_log10(breaks=unique(T$RadiusRelative2LetterSize))+
  scale_linetype_manual(values=c("solid", "dotted", "dashed", "longdash"))+
  scale_size_discrete(range=c(1.5,4)) +
  #scale_color_brewer(type="seq",  palette = 8)+
  ggtitle( expression(Eccentricity %in% group("{", list(0,32), "}") )) +
  theme(text=element_text(size=32), axis.text.x = element_text(angle = 45, hjust = 1, size=18), axis.text.y = element_text(size=18))

pp[[7]] <-ggplot(subset(T, T$LetterSize==2), aes(x=shiftedNoiseContrast, y=ThresholdContrast, size=factor(LetterSize), color=factor(RadiusRelative2LetterSize), linetype=factor(Eccentricity), shape=factor(LetterSize) )) +
  #facet_grid(Eccentricity ~ .) +
  geom_errorbar(ylimits, width=0.03)+
  geom_line()+
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=ybreaks)+
  scale_x_log10(breaks=unique(T$shiftedNoiseContrast))+
  scale_linetype_manual(values=c("solid", "longdash", "dashed", "dotted"))+
  scale_size_discrete(range=c(1.5,4)) +
  #scale_color_brewer(type="div",  palette = 7)+
  theme(text=element_text(size=32))

pp[[8]] <- ggplot(subset(T, T$LetterSize==2), aes(x=shiftedNoiseContrast^2, y=ThresholdContrast^2, size=factor(LetterSize), color=factor(RadiusRelative2LetterSize), linetype=factor(Eccentricity), shape=factor(LetterSize) )) +
  #facet_grid(Eccentricity ~ .) +
  #geom_errorbar(y2limits, width=0.03)+
  geom_line(alpha=0.6)+
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=ybreaks)+
  scale_x_log10(breaks=unique(T$shiftedNoiseContrast^2))+
  scale_linetype_manual(values=c("solid", "longdash", "dashed", "dotted"))+
  scale_size_discrete(range=c(1.5,4)) +
  #scale_color_brewer(type="div",  palette = 7)+
  theme(text=element_text(size=32), axis.text.x = element_text(angle = 45, hjust = 1, size=18), axis.text.y = element_text(size=18))


print(pp[[8]])

if(TRUE){
  cat('Saving figures to disk...\n')
ii = 0;
for (i in pp){
  ii = ii + 1
  cat('Saving figure ', ii, '.png.\n', sep="")
  png(paste(as.character(ii), '.png', sep=""), width=1024, height = 768)
  print(i)
  dev.off()
}
}