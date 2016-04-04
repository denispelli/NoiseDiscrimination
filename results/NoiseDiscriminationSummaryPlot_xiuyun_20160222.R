library(car)
library(MASS)
library(plyr)
library(ggplot2)
library(Hmisc)
library(reshape2)
library(magrittr)
library(cowplot)

options(digits=2)

mytheme <- theme_bw() +
  theme(panel.border=element_rect(color=NA), strip.background=element_rect(fill=NA),
        text=element_text(size=32), axis.text.x = element_text(angle = 60, hjust = 1))

setwd('~/Documents/Github/NoiseDiscrimination/results')
#setwd('/Users/xiuyunwu/NoiseDiscrimination/data')
pp = list()
csvFileName <- "krish_runs_2016328.csv"
csvFileName <- 'xiuyun_conditions_2016222_2.csv'
csvFileName <- 'krish_conditions_201641.csv'
observer <- str_sub(str_extract(csvFileName, '.*?_'),1,-2)

# csvFileName <- 'krish_runs_2016328_fineEccentricities1DegNoise.csv'
#T <- read.csv("xiuyun_conditionsN.csv")
# T <- read.csv("xiuyun_conditions_2015122.csv") # this uses exp for log transformation
# T <- read.csv("xiuyun_conditions_2016222.csv") # this file also includes data collected during 2015 fall and winter
# T <- read.csv("xiuyun_conditions_2016222_1.csv") # only includes 2015 fall and winter data
# T <- read.csv("xiuyun_conditions_2016222_2.csv") # only includes 2016 winter data
T <- read.csv(csvFileName) # only includes 2016 winter data

T$noiseDecayRadius = replace(T$noiseDecayRadius, T$noiseDecayRadius==Inf,32)
# T$noiseDecayRadius = replace(T$noiseDecayRadius, T$noiseDecayRadius==1.018875,1)
# T$noiseDecayRadius = replace(T$noiseDecayRadius, T$noiseDecayRadius==1.6302,1.73205080756888)
# T$noiseDecayRadius = replace(T$noiseDecayRadius, T$noiseDecayRadius==3.056625,3)
# T$noiseDecayRadius = replace(T$noiseDecayRadius, T$noiseDecayRadius==5.094375,5.19615242270663)
# T$noiseDecayRadius = replace(T$noiseDecayRadius, T$noiseDecayRadius==8.9661,9)

T$targetSize[abs(T$targetSize-2*sqrt(3)) < 1e-3] = 3.5 # fix for 2sqrt(3)
T$shiftedEccentricity = T$eccentricity + 0.05 # foveal critical spcaing
T$noiseDecayRadiusOverTargetSize = T$noiseDecayRadius/T$targetSize/2
T$noiseDecayRadiusOverTargetSize[T$noiseDecayRadiusOverTargetSize==0] = 0.05 # WITHOUT noice fix
if(str_detect(csvFileName, '.*_runs')){
  T$shiftedSquaredNoiseContrast = T$squaredNoiseContrast +0.005
  T$meanThreshold = 10^T$thresholdLogContrast
  T$sdThreshold = 10^T$thresholdContrastSD
}else if(str_detect(csvFileName, '.*_conditions')){
  # *_conditions_*.csv file specific processing
}

#noiseDecayRadius = factor(noiseDecayRadius, c(1,2,3,5,6,8,9,16))


# dat <- within(T, {
#   id = factor(S.No.)
#  letterSize = factor(letterSize, c(2,3,6))
#   eccentricity = factor(eccentricity, c(0,2,8,32))
#  Trials = factor(Trials, c(80, 100))
# })



noGrid <-
  theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(),panel.background=element_blank(),axis.line=element_line(colour='black'))


# xbreaks = c(1, 2, 4, 8, 16, 32)
# ybreaks = c(0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 1, 1.5, 2.0)
# ylimits = aes(ymax = meanThreshold + sdThreshold, ymin=meanThreshold - sdThreshold)
# pp[[2]] <- ggplot(subset(T, T$targetKind=='gabor'), aes(x=targetSize, y=meanThreshold, color=factor(eccentricity), linetype=factor(noiseContrast) )) +


  # get rid of eccessive measurements using *gabors* with various noiseCheckDeg
  T = T[!(T$noiseSpectrum=='white' & T$noiseContrast==0.16 & T$eccentricity==0 & T$targetKind == 'gabor' & (T$targetSize==8 & abs(T$noiseCheckDeg-0.395) > 0.01)),]


  bakT <- T # before filter

  if(str_detect(csvFileName, '.*_runs')){
    # noiseSpectrum is still a number
    # white:0 pink:1
    T <- subset(T, T$noiseSpectrum==0
                & T$noiseContrast==0.16
                & noiseDecayRadius >= 16
  )} else if(str_detect(csvFileName, '.*_conditions')){
    # *_conditions_*.csv file specific processing
    T <- subset(T, T$noiseSpectrum=='white'
    & T$noiseContrast==0.16
    & noiseDecayRadius >= 16
    )} else {warning('Cannot understand .csv file type.')}


TT <- T
T <- rbind(subset(bakT, noiseDecayRadius>0 & noiseSpectrum == 'white' & noiseContrast == 0.16),subset(bakT, noiseContrast==0))

  # Threshold vs. DecayRadius/TargetSize
  xbreaks = c(0.01, 0.25, 0.5,1, 2, 4, 8, 16, 32)
  ybreaks = c(0.01, 0.05, 0.1, 0.2)
  ylimits = aes(ymax = meanThreshold + sdThreshold, ymin=meanThreshold - sdThreshold)
  pp[[1]] <- ggplot(T, aes(x=noiseDecayRadiusOverTargetSize, y=meanThreshold,
                           size=factor(targetSize),
                           color=factor(shiftedEccentricity),
                           shape=factor(noiseContrast))) +
    # geom_errorbar(ylimits, width=0.05, alpha=0.6)+
    geom_line(alpha=0.6, size=1, aes(group=factor(targetSize)))+
    geom_point(alpha=0.6)+
    # geom_abline(intercept = 5e-5, slope = 0, color="black", size=5) +
    # geom_line(data=data.frame(x=seq(0.45, 32, 0.5),y=seq(0.45, 32, 0.5)), aes(x=x, y=y))+
    # geom_segment(aes(x = 1, y = 1e-6, xend = 10, yend = 1e-4), color="black", linetype="dashed", size=1.5)+
    scale_y_log10(breaks=ybreaks)+
    scale_x_log10(breaks=xbreaks, limits = c(NA,10), label=as.character(xbreaks))+
    # scale_y_log10() + scale_x_log10() +
    scale_linetype_manual(values=c("solid", "longdash"))+
    scale_size_discrete(range=c(4,8), name="Target Size (deg)") +
    # scale_color_discrete()+
    scale_shape_manual(values=c(18,16), name="Noise Contrast") +
    scale_color_brewer(name=expression(Eccentricity[shifted]~ (deg)), labels = sort(unique(bakT$eccentricity)),type="div",  palette = 7) +
    noGrid+
    # facet_grid(.~eccentricity)+
    labs(title = "Global Gaussian White Noise", x = "Noise Decay Radius / Target Size", y = 'Threshold Contrast')+
    # annotate("text", hjust=1, x = 8, y = 7e-3, label = c("Global Gaussian White Noise"), size=8) +
    annotate("text", hjust=1, x = 8, y = 7e-3, label = paste('Observer: ', observer), size=8) +
    guides(shape = guide_legend(override.aes = list(size=4))) +
    # theme_tufte() +
    theme(text=element_text(size=32), axis.text.x = element_text(angle = 45, hjust = 1))
  print(pp[[1]])


  # Threshold vs. DecayRadius/TargetSize
  xbreaks = c(0.01, 0.25, 0.5,1, 2, 4, 8, 16, 32)
  ybreaks = c(0.01, 0.05, 0.1, 0.2)
  ylimits = aes(ymax = meanThreshold + sdThreshold, ymin=meanThreshold - sdThreshold)
  pp[[2]] <- ggplot(T, aes(x=noiseDecayRadiusOverTargetSize, y=meanThreshold,
                           size=factor(targetSize),
                           color=factor(shiftedEccentricity),
                           shape=factor(noiseContrast))) +
    # geom_errorbar(ylimits, width=0.05, alpha=0.6)+
    geom_line(alpha=0.6, size=1, aes(group=factor(targetSize)))+
    geom_point(alpha=0.6)+
    # geom_abline(intercept = 5e-5, slope = 0, color="black", size=5) +
    # geom_line(data=data.frame(x=seq(0.45, 32, 0.5),y=seq(0.45, 32, 0.5)), aes(x=x, y=y))+
    # geom_segment(aes(x = 1, y = 1e-6, xend = 10, yend = 1e-4), color="black", linetype="dashed", size=1.5)+
    scale_y_log10(breaks=ybreaks)+
    scale_x_log10(breaks=xbreaks, label=as.character(xbreaks))+
    scale_linetype_manual(values=c("solid", "longdash"))+
    scale_size_discrete(range=c(4,8), name="Target Size (deg)") +
    # scale_color_discrete()+
    scale_shape_manual(values=c(18,16), name="Noise Contrast") +
    scale_color_brewer(name=expression(Eccentricity[shifted]~ (deg)), labels = sort(unique(bakT$eccentricity)),type="div",  palette = 7) +
    noGrid+
    facet_grid(.~eccentricity)+
    labs(title = "Global Gaussian White Noise", x = "Noise Decay Radius / Target Size", y = 'Threshold Contrast')+
    # annotate("text", hjust=1, x = 8, y = 7e-3, label = c("Global Gaussian White Noise"), size=8) +
    annotate("text", hjust=1, x = 8, y = 7e-3, label = paste(observer), size=8) +
    guides(shape = guide_legend(override.aes = list(size=4))) +
    # theme_tufte() +
    theme(text=element_text(size=32), axis.text.x = element_text(angle = 45, hjust = 1))
  print(pp[[2]])


  if(TRUE){
T <- TT
  # Threshold vs. Ecc
  xbreaks = c(1, 8, 16, 32)
  ybreaks = c(0.005, 0.03, 0.01, 0.05,0.1,0.15, 0.2)
  ylimits = aes(ymax = meanThreshold + sdThreshold, ymin=meanThreshold - sdThreshold)
  pp[[3]] <- ggplot(rbind(T, subset(bakT, noiseContrast==0)), aes(x=shiftedEccentricity, y=meanThreshold, color=factor(targetSize), shape=factor(noiseContrast))) +
    geom_errorbar(ylimits, width=0.1)+
    geom_line()+
    geom_point(alpha=0.6, size=8)+
    # geom_point(data=subset(bakT, noiseContrast==0), size=8, alpha=0.6, shape=18)+
    # geom_segment(aes(x = 1, y = 0.02, xend = 10, yend = 0.2), color="black", linetype="dashed", size=1.5)+
    scale_y_log10(breaks=ybreaks)+
    # scale_x_log10(breaks=xbreaks)+
    scale_x_continuous(breaks=xbreaks)+
    scale_linetype_manual(values=c("solid", "longdash"))+
    scale_size_discrete(range=c(0.7,2), name="Target Size (deg)") +
    scale_color_discrete(name="Target Size (deg)")+
    # scale_color_brewer(name="Target Size (deg)", type="div",  palette = 7) +
    scale_shape_manual(values=c(18,16), name="Noise Contrast") +
    noGrid+
    facet_grid(.~targetKind)+
    labs(title = "Object Identification", x =  expression(Eccentricity[shifted]~ (deg)), y = "Threshold Contrast")+
    # annotate("text", hjust=0, x = 0.5, y = 6e-3, label = c("Global Gaussian White Noise"), size=8) +
    # annotate("text", hjust=0, x = 0.5, y = 7e-3, label = c("Observer: Wu"), size=8) +
    theme(text=element_text(size=32))
  print(pp[[3]])



  # Neq vs. Ecc
  xbreaks = c(0.05, 1, 8, 16, 32)
  ybreaks = c(1e-06, 1e-05, 1e-04, 1e-03, 1e-02)
  ylimits = aes(ymax = meanNeq + sdNeq, ymin=meanNeq - sdNeq)
  pp[[4]] <- ggplot(T, aes(x=shiftedEccentricity, y=meanNeq, color=factor(targetSize), size=factor(targetSize))) +
    geom_errorbar(ylimits, width=0.1)+
    geom_line()+
    geom_point(alpha=0.6, size=8)+
    # geom_abline(intercept = 5e-5, slope = 0, color="black", size=5) +
    # geom_line(data=data.frame(x=seq(0.45, 32, 0.5),y=seq(0.45, 32, 0.5)), aes(x=x, y=y))+
    geom_segment(aes(x = 1, y = 1e-6, xend = 10, yend = 1e-4), color="black", linetype="dashed", size=1.5)+
    scale_y_log10(breaks=ybreaks)+
    scale_x_log10(breaks=xbreaks, label=as.character(xbreaks))+
    scale_linetype_manual(values=c("solid", "longdash"))+
    scale_size_discrete(range=c(0.7,2), name="Target Size (deg)") +
    scale_color_discrete(name="Target Size (deg)")+
    #scale_color_brewer(type="div",  palette = 7)
    noGrid+
    facet_grid(.~targetKind)+
    labs(title = "Object Identification", x = expression(Eccentricity[shifted]~ (deg)), y = expression(Neq~(deg^2)))+
    annotate("text", hjust=1, x = 32, y = 3e-7, label = c("log-log slope: 2"), size=8) +
    annotate("text", hjust=1, x = 32, y = 5e-7, label = c("Global Gaussian White Noise"), size=8) +
    annotate("text", hjust=1, x = 32, y = 7e-7, label = paste(observer), size=8) +
    theme(text=element_text(size=32))
  print(pp[[4]])


  # Neq vs. targetSize
  xbreaks = c(1, 2, 4, 6, 8, 16, 32)
  ybreaks = c(1e-06, 1e-05, 1e-04, 1e-03, 1e-02)
  ylimits = aes(ymax = meanNeq + sdNeq, ymin=meanNeq - sdNeq)
  pp[[5]] <- ggplot(T, aes(x=targetSize, y=meanNeq, color=factor(shiftedEccentricity))) +
    geom_errorbar(ylimits, width=0.1)+
    geom_line()+
    geom_point(alpha=0.6, size=8)+
    geom_segment(aes(x = 1, y = 1e-6, xend = 10, yend = 1e-4), color="black", linetype="dashed", size=1.5)+
    scale_y_log10(breaks=ybreaks)+
    scale_x_log10(breaks=xbreaks)+
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
  print(pp[[5]])


  # Eff vs. Ecc
  xbreaks = c(0.05, 1, 8, 16, 32)
  ybreaks = c(0.01,0.02,0.035,0.05,0.1, 0.15, 0.2,0.3)
  ylimits = aes(ymax = meanEfficiency + sdEfficiency, ymin=meanEfficiency - sdEfficiency)
  pp[[6]] <- ggplot(T, aes(x=shiftedEccentricity, y=meanEfficiency, color=factor(targetSize), size=factor(targetSize))) +
    geom_errorbar(ylimits, width=0.1)+
    geom_line()+
    geom_point(alpha=0.6, size=8)+
    scale_y_log10(breaks=ybreaks)+
    scale_x_log10(breaks=xbreaks, label=as.character(xbreaks))+
    scale_linetype_manual(values=c("solid", "longdash"))+
    scale_size_discrete(range=c(0.7,2), name="Target Size (deg)") +
    scale_color_discrete(name="Target Size (deg)")+
    #scale_color_brewer(type="div",  palette = 7)
    noGrid+
    facet_grid(.~targetKind)+
    labs(title = "Object Identification", x = expression(Eccentricity[shifted]~ (deg)), y = "Efficiency (%)")+
    annotate("text", hjust=0, x = 0.5, y = 6e-3, label = c("Global Gaussian White Noise"), size=8) +
    annotate("text", hjust=0, x = 0.5, y = 7e-3, label = paste(observer), size=8) +
    theme(text=element_text(size=32))
  print(pp[[6]])


  # Eff vs. target size
  xbreaks = c(1, 2, 4, 6, 8, 16, 32)
  ybreaks = c(0.01,0.02,0.035,0.05,0.1, 0.15, 0.2,0.3)
  ylimits = aes(ymax = meanEfficiency + sdEfficiency, ymin=meanEfficiency - sdEfficiency)
  pp[[7]] <- ggplot(T, aes(x=targetSize, y=meanEfficiency, color=factor(shiftedEccentricity))) +
    geom_errorbar(ylimits, width=0.1)+
    geom_line()+
    geom_point(alpha=0.6, size=8)+
    scale_y_log10(breaks=ybreaks)+
    scale_x_log10(breaks=xbreaks)+
    scale_linetype_manual(values=c("solid", "longdash"))+
    scale_size_discrete(range=c(0.7,2), name="Target Size (deg)") +
    scale_color_brewer(name=expression(Eccentricity[shifted]~ (deg)), labels = sort(unique(bakT$eccentricity)),type="div",  palette = 7) +
    #scale_color_brewer(type="div",  palette = 7)
    noGrid+
    facet_grid(.~targetKind)+
    labs(title = "Object Identification", x = "Target Size (deg)", y = "Efficiency (%)")+
    annotate("text", hjust=0, x = 0.5, y = 6e-3, label = c("Global Gaussian White Noise"), size=8) +
    annotate("text", hjust=0, x = 0.5, y = 7e-3, label = paste(observer), size=8) +
    theme(text=element_text(size=32))
  print(pp[[7]])


  # R vs. H/Ecc
  xbreaks = c(0.01, 0.1, 1, 10)
  ybreaks = c(1e-06, 1e-05, 1e-04, 1e-03, 1e-02)
  # ylimits = aes(ymax = meanNeq + sdNeq, ymin=meanNeq - sdNeq)
  pp[[8]] <- ggplot(T, aes(x=targetSize/shiftedEccentricity, y=targetSize^2/meanNeq, color=factor(shiftedEccentricity), size=factor(targetSize))) +
    # geom_errorbar(ylimits, width=0.1)+
    geom_point(alpha=0.8)+
    geom_segment(aes(x = .1, y = 1e5, xend = 1, yend = 1e7), color="black", linetype="dashed", size=1.5)+
    # geom_segment(aes(x = 1, y = 1e4, xend = 10, yend = 1e6), color="black", linetype="dashed", size=1.5)+
    scale_y_log10()+
    scale_x_log10(breaks=xbreaks)+
    scale_linetype_manual(values=c("solid", "longdash"))+
    scale_color_brewer(name=expression(Eccentricity[shifted]~ (deg)), labels = sort(unique(bakT$eccentricity)),type="div",  palette = 7) +
    # scale_color_brewer(type="div",  palette = 7)+
    scale_size_discrete(range=c(4,10), name="Target Size (deg)") +
    noGrid+
    facet_grid(.~targetKind)+
    # labs(title = "Object Identification", x = expression(Eccentricity[shifted]/Target~ Size), y = "Poisson Rate (Target Area/Neq)")+
    labs(title = "Object Identification", x = expression(Target~ Size/Eccentricity[shifted]), y = "Poisson Rate (Target Area/Neq)")+
    annotate("text", hjust=0, x = 5e-2, y = 0.7e4, label = c("log-log slope: 2"), size=8) +
    annotate("text", hjust=0, x = 5e-2, y = 1.0e4, label = c("Global Gaussian White Noise"), size=8) +
    annotate("text", hjust=0, x = 5e-2, y = 1.4e4, label = paste(observer), size=8) +
    theme(text=element_text(size=32))
  print(pp[[8]])


}





# xbreaks = c(1, 16, 32)
# ybreaks = c(0.01,0.02,0.035,0.05,0.1, 0.15, 0.2,0.3)
# ylimits = aes(ymax = meanEfficiency + sdEfficiency, ymin=meanEfficiency - sdEfficiency)
# pp[[4]] <- ggplot(subset(T, T$noiseSpectrum=='white'&T$noiseContrast==0.16), aes(x=shiftedEccentricity, y=meanEfficiency, color=factor(targetSize), shape=factor(targetKind))) +
#   geom_errorbar(ylimits)+
#   geom_line()+
#   geom_point(size=12, alpha=0.6)+
#   scale_y_log10(breaks=ybreaks)+
#   scale_x_log10(breaks=xbreaks)+
#   scale_linetype_manual(values=c("solid", "longdash"))+
#   scale_size_discrete(range=c(0.5,2)) +
#   #scale_color_brewer(type="div",  palette = 7)
#   facet_grid(targetKind ~.)+
#   noGrid+
#   labs(title = "Gabor(targetHeight/20)&Letter, Noise Contrast 0.16, Gaussian white", x = "shiftedEccentricity(+0.45deg)", y = "Efficiency")+
#   theme(text=element_text(size=32))

# xbreaks = c(1, 16, 32)
# ybreaks = c(0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 1, 1.5, 2.0)
# ylimits = aes(ymax = meanThreshold + sdThreshold, ymin=meanThreshold - sdThreshold)
# pp[[5]] <- ggplot(subset(T, T$targetKind=='gabor'), aes(x=shiftedEccentricity, y=meanThreshold, color=factor(targetSize), linetype=factor(noiseContrast) )) +
#   geom_errorbar(ylimits)+
#   geom_line()+
#   geom_point(size=12, alpha=0.6)+
#   scale_y_log10(breaks=ybreaks)+
#   scale_x_log10(breaks=xbreaks)+
#   scale_linetype_manual(values=c("solid", "longdash"))+
#   scale_size_discrete(range=c(0.5,2)) +
#   #scale_color_brewer(type="div",  palette = 7)
#   noGrid+
#   # facet_grid(letter_size ~.)+
#   labs(title = "Gabor, Gaussian white", x = "shiftedEccentricity(+0.45deg)", y = "Threshold_Contrast")+
#   theme(text=element_text(size=32))

# xbreaks = c(1, 16, 32)
# ybreaks = c(1e-06, 1e-05, 1e-04, 1e-03, 1e-02)
# ylimits = aes(ymax = meanNeq + sdNeq, ymin=meanNeq - sdNeq)
# pp[[6]] <- ggplot(subset(T, T$noiseSpectrum=='white'& T$noiseContrast==0.16), aes(x=shiftedEccentricity, y=meanNeq, color=factor(targetSize), shape=factor(targetKind) )) +
#   geom_errorbar(ylimits)+
#   geom_line()+
#   geom_point(size=12, alpha=0.6)+
#   scale_y_log10(breaks=ybreaks)+
#   scale_x_log10(breaks=xbreaks)+
#   scale_linetype_manual(values=c("solid", "longdash"))+
#   scale_size_discrete(range=c(1.5,2)) +
#   #scale_color_brewer(type="div",  palette = 7)
#   noGrid+
#   facet_grid(targetKind ~.)+
#   labs(title = "Gabor(targetHeight/20)&Letter, Noise Contrast 0.16, Gaussian white", x = "shiftedEccentricity(+0.45deg)", y = "Neq")+
#   theme(text=element_text(size=32))

# xbreaks = c(1, 2, 4, 8, 16, 32)
# ybreaks = c(0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 1, 1.5, 2.0)
# ylimits = aes(ymax = meanThreshold + sdThreshold, ymin=meanThreshold - sdThreshold)
# pp[[2]] <- ggplot(subset(T,T$noiseSpectrum=='white'), aes(x=targetSize, y=meanThreshold, color=factor(eccentricity), linetype=factor(noiseContrast) )) +
#   geom_errorbar(ylimits)+
#   geom_line()+
#   geom_point(size=12, alpha=0.6)+
#   scale_y_log10(breaks=ybreaks)+
#   scale_x_log10(breaks=xbreaks)+
#   scale_linetype_manual(values=c("solid", "longdash"))+
#   scale_size_discrete(range=c(0.5,2)) +
#   #scale_color_brewer(type="div",  palette = 7)
#   noGrid+
#   facet_grid(targetKind ~.)+
#   labs(title = "Gabor, Gaussian white", x = "Target Size", y = "ThresholdContrast")+
#   theme(text=element_text(size=32))


if(TRUE){
  cat('Saving figures to disk...\n')
  ii = 0;
  pdf(paste(csvFileName, '.pdf', sep=""), width = 12, height = 8)
  bquiet = lapply(pp, print)
  dev.off()

  for (i in pp){
    ii = ii + 1
    cat('Saving figure ', csvFileName, ii, '.png.\n', sep="")
    # png(paste(csvFileName, '_', as.character(ii), '.png', sep=""), width=1366, height = 768)
    # print(i)
    ggsave(paste(csvFileName, '_', as.character(ii), '.png', sep=""), i, width = 30, height = 20, units = "cm")
    # print(i)
    # dev.off()
  }
}
