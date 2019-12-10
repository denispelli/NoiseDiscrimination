library(tidyverse)
library(ggthemes)
jsonlite::fromJSON('/media/hdd/home/hyiltiz/Dropbox-pellilab-darshan/data/EfficiencyConservation.json') %>%
  as_tibble() %>% tidyr::unnest() -> dat


dat$targetSizeDeg <- round(dat$targetHeightDeg,0)
dat$targetSizeDeg[dat$targetSizeDeg==0]=0.5
dat %>% filter(targetSizeDeg!=1) -> dat


# dat %>% mutate(EOverN=case_when( # pattern matching
#   conditionName=='letter' ~ 3,
#   conditionName=='gabor' ~ 13, # read off values from E/N plot
# )) -> dat
# dat[dat$observer=='ideal', "E"]=1

pp <- list()
# plot each observer separately
pp[[1]] <- ggplot(dat, aes(y=efficiency, x=eccentricityDeg+0.16, shape=factor(targetSizeDeg), color=observer)) +
  facet_grid(conditionName~targetSizeDeg) +
  stat_summary(geom='point') + stat_summary(geom='line') +
  scale_x_log10() + scale_y_log10()+
  labs(title='Efficiency vs. Eccentricity (log), panels for size, gabor vs. letters')

dat %>% filter(observer!='ideal') %>%
  na.omit() %>%
  group_by(conditionName, eccentricityDeg, targetSizeDeg) %>%
  summarize(n=n(),
            efficiency.mean=mean(efficiency),
            efficiency.se=sd(efficiency)/sqrt(n/2)
            ) -> dat.efficiency.summary

pp[[2]] <- ggplot(dat.efficiency.summary,
                  aes(y=efficiency.mean, x=eccentricityDeg+0.15,
                      ymin=efficiency.mean-efficiency.se,
                      ymax=efficiency.mean+efficiency.se,
                      color=factor(targetSizeDeg)
                      )) +
  facet_grid(~conditionName) +
  geom_errorbar(width=.2) + geom_point() + geom_line()+
  scale_x_log10() +
  scale_y_log10(breaks=c(0.01, 0.05, 0.25, 1), limits=c(0.01, 1))+
  labs(title='Average efficiency vs. Eccentricity (log)',
       color='Size (deg)',
       x='Eccentricity+0.15 (deg)',
       y='Efficiency')+
  theme_tufte()

pp[[2.1]] <- ggplot(dat.efficiency.summary,
       aes(y=efficiency.mean, x=targetSizeDeg+0.15,
           ymin=efficiency.mean-efficiency.se,
           ymax=efficiency.mean+efficiency.se,
           color=factor(eccentricityDeg)
       )) +
  facet_grid(~conditionName) +
  geom_errorbar(width=.2) + geom_point() + geom_line()+
  scale_x_log10() +
  scale_y_log10(breaks=c(0.01, 0.05, 0.25, 1), limits=c(0.01, 1))+
  labs(title='Average efficiency vs. size (log)',
       color='Size (deg)',
       x='Target height+0.15 (deg)',
       y='Efficiency')+
  theme_tufte()

# ideal observer threshold energy
pp[[3]] <- ggplot(dat %>% filter(observer=='ideal'), aes(y=E/N, x=eccentricityDeg+0.16, shape=factor(targetSizeDeg))) +
  facet_grid(conditionName~targetSizeDeg) +
  stat_summary() + stat_summary(geom='line') +
  scale_x_log10() + scale_y_log10()+
  labs(title='ideal observer threshold energy vs. Eccentricity (log)')

# dat %>% pivot_longer(
#   cols = one_of('E', 'E0'),
#   names_to = 'E.type', values_to = 'E'
#   ) -> dat.long


pp[[4]] <- ggplot(dat, aes(y=E, x=eccentricityDeg+0.16, shape=factor(noiseSD), color=observer)) +
  facet_grid(conditionName~targetSizeDeg) +
  geom_point() + geom_line()+
  scale_x_log10() + scale_y_log10() + scale_shape_manual(values = c(1,16))+
  labs(title='threshold energies (log) vs. Eccentricity (log)')

pp[[5]] <- ggplot(dat, aes(y=E, x=eccentricityDeg+0.16, shape=factor(noiseSD), color=factor(targetSizeDeg))) +
  facet_grid(~conditionName) +
  stat_summary() + stat_summary(geom='line') +
  scale_x_log10() + scale_y_log10() + scale_shape_manual(values = c(1,16))+
  labs(title='threshold energies (log) vs. Eccentricity (log)')


pp[[6]] <- ggplot(dat, aes(y=efficiency, x=targetSizeDeg+0.1, color=factor(eccentricityDeg))) +
  facet_grid(~conditionName) +
  stat_summary() + stat_summary(geom='line') +
  scale_x_log10() + scale_y_log10() +
  labs(title='Average efficiency vs. size (log)')

pp[[7]] <- ggplot(dat %>% filter(observer=='Ashley Feng'),
                  aes(y=-contrast, x=eccentricityDeg+0.16, shape=factor(noiseSD), color=factor(targetSizeDeg))) +
  facet_grid(~conditionName) +
  geom_point() + geom_line()+
  scale_x_log10() + scale_y_log10() + scale_shape_manual(values = c(1,16))+
  labs(title='threshold contrast (log) vs. Eccentricity (log); observer: Ashley Feng')


pp[[8]] <- ggplot(dat%>% filter(observer=='ideal'), aes(y=abs(contrast), x=eccentricityDeg+0.16, shape=factor(noiseSD), color=factor(targetSizeDeg))) +
  facet_grid(~conditionName) +
  geom_point() + geom_line() +
  scale_x_log10() + scale_y_log10() + scale_shape_manual(values = c(1,16))+
  labs(title='threshold contrast (log) vs. Eccentricity (log); observer: ideal')

pp[[9]] <- ggplot(dat,
                  aes(y=-contrast, x=eccentricityDeg+0.16, shape=factor(noiseSD), color=factor(targetSizeDeg))) +
  facet_grid(conditionName~observer) +
  geom_point() + geom_line()+
  scale_x_log10() + scale_y_log10() + scale_shape_manual(values = c(1,16))+
  labs(title='threshold contrast (log) vs. Eccentricity (log); observer: Ashley Feng')

pp[[10]] <- ggplot(dat, aes(y=Neq, x=eccentricityDeg+0.16, color=factor(targetSizeDeg))) +
  facet_grid(~conditionName) +
  stat_summary() + stat_summary(geom='line') +
  scale_x_log10() + scale_y_log10() +
  labs(title='Average Neq vs. Eccentricity (log)')


cairo_ps("EfficiencyConservation.ps", width = 10, height = 5, onefile = TRUE, fallback_resolution = 1200)
for (p in pp) print(p)
dev.off()

