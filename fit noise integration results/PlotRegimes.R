library(evd)

xPoints = c(0, 2, 3, 7, 10)
names(xPoints) <- c("LetterCenter", "LetterSize", "AcuityRange", "CombiningField", "Inf")

yPoints = 5
names(yPoints) <- c("BestPerformance")

kLine = 1
fCrowding = 1
#pweibull(20-5*(X - xPoints[2]), shape=4, scale=8)+yPoints[1]-kLine*xPoints[2]-1)*ifelse(X>=xPoints[2] & X<=xPoints[4], 1, 1)}) +

pp <- ggplot(data.frame(x = range(xPoints)), aes(x)) +
  stat_function(color="red", fun = function(X) {(-kLine*X+yPoints[1])*ifelse(X>=xPoints[1] & X<=xPoints[2], 1, NA)}) +
  stat_function(color="blue", fun = function(X) {(-fCrowding * pfrechet(5*(X - xPoints[2]), shape=4, scale=8)+yPoints[1]-kLine*xPoints[2])*ifelse(X>=xPoints[2] & X<=xPoints[4], 1, NA)}) +
  ylim(c(0, yPoints[1])) +
  xlim(range(xPoints)) +
  ylab('Threshold Contrast') +
  xlab('Noise Outer Radius') +
  scale_x_discrete(breaks=xPoints, labels=names(xPoints)) +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

print(pp)