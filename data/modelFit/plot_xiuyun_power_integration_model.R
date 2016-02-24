library("ggplot2")
library("reshape2")
library('scales')

load('xiuyunECC0degconditionsWithFit.Rda')
load('xiuyunECC32degconditionsWithFit.Rda')

zerodeg.fit.plot <- ggplot(data=xiuyunECC0degconditionsWithFit,
                         aes(x=radius_relative_to_letter_radius, y=contrastFit, colour=eccentricity)) + geom_line()

thirtytwodeg.fit.plot <- geom_line(data =xiuyunECC32degconditionsWithFit,aes(x=radius_relative_to_letter_radius,y=contrastFit))

zerodeg.data.plot <- geom_point(data = xiuyunECC0degconditionsWithFit, aes(x=radius_relative_to_letter_radius,y=mean_threshold))

thirtytwodeg.data.plot <- geom_point(data = xiuyunECC32degconditionsWithFit, aes(x=radius_relative_to_letter_radius,y=mean_threshold))


#final plot
zerodeg.fit.plot + thirtytwodeg.fit.plot + zerodeg.data.plot + thirtytwodeg.data.plot + ylab('Threshold contrast') + xlab('Relative decay radius (decay radius/letter radius)')+ scale_y_continuous(trans=log2_trans())+scale_x_continuous(trans=log2_trans())

