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


ylimits = aes(ymax = mean_threshold + sd_threshold, ymin=mean_threshold - sd_threshold)
y2limits = aes(ymax = mean_threshold^2 + sd_threshold^2, ymin=mean_threshold^2 - sd_threshold^2)
xbreaks = c(0.5, 1, 2, 3, 6, 9, 16, 32)
ybreaks = c(0.1, 0.15, 0.2, 0.3, 0.5, 0.7, 1, 1.5, 2.0)
pp = list()
T <- read.csv("xiuyun_conditions.csv")
T$noise_decay_radius = replace(T$noise_decay_radius, T$noise_decay_radius==Inf,32)
T$RadiusRelative2letter_size = round(T$noise_decay_radius / T$letter_size, digits = 2)
T$eccentricity = T$eccentricity - 0.45
#noise_decay_radius = factor(noise_decay_radius, c(1,2,3,5,6,8,9,16))


# dat <- within(T, {
#   id = factor(S.No.)
#  letter_size = factor(letter_size, c(2,3,6))
#   eccentricity = factor(eccentricity, c(0,2,8,32))
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




pp[[1]] <- ggplot(T, aes(x=noise_decay_radius, y=mean_threshold, size=factor(letter_size), color=factor(noise_contrast), linetype=factor(eccentricity), shape=factor(eccentricity) )) +
  geom_errorbar(ylimits)+
  geom_line()+
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=ybreaks)+
  scale_x_log10(breaks=xbreaks)+
  scale_linetype_manual(values=c("solid", "longdash", "dashed", "dotted"))+
  scale_size_discrete(range=c(1.5,4)) +
  #scale_color_brewer(type="div",  palette = 7)+
  theme(text=element_text(size=32))



pp[[2]] <- ggplot(T, aes(x=noise_decay_radius, y=mean_threshold, size=factor(letter_size), color=factor(noise_contrast), linetype=factor(eccentricity), shape=factor(eccentricity) )) +
  facet_grid(eccentricity ~ .) +
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

pp[[3]] <- ggplot(T, aes(x=noise_decay_radius, y=mean_threshold, size=factor(letter_size), color=factor(noise_contrast), linetype=factor(eccentricity), shape=factor(eccentricity) )) +
  facet_grid(letter_size ~ .) +
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

T$shiftednoise_contrast = T$noise_contrast + 0.08

pp[[4]] <- ggplot(subset(T, T$letter_size==2), aes(x=shiftednoise_contrast, y=mean_threshold, size=factor(letter_size), color=factor(noise_decay_radius), linetype=factor(eccentricity), shape=factor(eccentricity) )) +
  facet_grid(eccentricity ~ .) +
  geom_errorbar(ylimits)+
  geom_line()+
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=c(1/4, 1/2,1,2))+
  scale_x_log10(breaks=c(0.08, 0.1, 0.16, 0.2, 0.35))+
  scale_linetype_manual(values=c("solid", "longdash", "dashed", "dotted"))+
  scale_size_discrete(range=c(1.5,4)) +
  #scale_color_brewer(type="div",  palette = 7)+
  theme(text=element_text(size=32))

pp[[5]] <- ggplot(T, aes(x=RadiusRelative2letter_size, y=mean_threshold, color=factor(noise_contrast))) +
  #geom_errorbar(ylimits)+
  geom_line(position = position_jitter())+
  facet_grid(eccentricity ~ .) +
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=ybreaks)+
  scale_x_log10(breaks=unique(T$RadiusRelative2letter_size))+
  scale_linetype_manual(values=c("solid", "longdash", "dashed", "dotted"))+
  scale_size_discrete(range=c(1.5,4)) +
 # scale_color_brewer(type="seq",  palette = 8)+
  theme(text=element_text(size=32), axis.text.x = element_text(angle = 45, hjust = 1), axis.text.y = element_text(size=18))

pp[[6]] <- ggplot(subset(T,  (T$eccentricity %in% c(0,32))), aes(x=RadiusRelative2letter_size, y=mean_threshold, color=factor(noise_contrast), linetype=factor(eccentricity) )) +
  #geom_errorbar(ylimits, size=2, alpha=1)+
  stat_summary(fun.y=mean, ylimits, geom="smooth", size = 2) +
  #geom_line(size=2, aes(linetype=factor(eccentricity)))+
  geom_point(size=7, alpha=0.5, aes(shape=factor(letter_size)))+
  scale_y_log10(breaks=ybreaks)+
  scale_x_log10(breaks=unique(T$RadiusRelative2letter_size))+
  scale_linetype_manual(values=c("solid", "dotted", "dashed", "longdash"))+
  scale_size_discrete(range=c(1.5,4)) +
  #scale_color_brewer(type="seq",  palette = 8)+
  ggtitle( expression(eccentricity %in% group("{", list(0,32), "}") )) +
  theme(text=element_text(size=32), axis.text.x = element_text(angle = 45, hjust = 1, size=18), axis.text.y = element_text(size=18))

pp[[7]] <-ggplot(subset(T, T$letter_size==2), aes(x=shiftednoise_contrast, y=mean_threshold, size=factor(letter_size), color=factor(RadiusRelative2letter_size), linetype=factor(eccentricity), shape=factor(letter_size) )) +
  #facet_grid(eccentricity ~ .) +
  geom_errorbar(ylimits, width=0.03)+
  geom_line()+
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=ybreaks)+
  scale_x_log10(breaks=unique(T$shiftednoise_contrast))+
  scale_linetype_manual(values=c("solid", "longdash", "dashed", "dotted"))+
  scale_size_discrete(range=c(1.5,4)) +
  #scale_color_brewer(type="div",  palette = 7)+
  theme(text=element_text(size=32))

pp[[8]] <- ggplot(subset(T, T$letter_size==2), aes(x=shiftednoise_contrast^2, y=mean_threshold^2, size=factor(letter_size), color=factor(RadiusRelative2letter_size), linetype=factor(eccentricity), shape=factor(letter_size) )) +
  #facet_grid(eccentricity ~ .) +
  #geom_errorbar(y2limits, width=0.03)+
  geom_line(alpha=0.6)+
  geom_point(size=9, alpha=0.6)+
  scale_y_log10(breaks=ybreaks)+
  scale_x_log10(breaks=unique(T$shiftednoise_contrast^2))+
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