
### set *your* working directory
setwd("")

### download data
urls <- c("https://ourworldindata.org/progress-lgbt-rights",
          "https://ourworldindata.org/grapher/population")

# this will open the urls in your browser
for(i in 1:2){
  browseURL(urls[i])
}

### read in data
x <- read.csv("population.csv")
a <- read.csv("marriage-same-sex-partners-equaldex.csv")
b <- read.csv("right-to-change-legal-gender-equaldex.csv")
c <- read.csv("same-sex-sexual-acts-equaldex.csv")
d <- read.csv("third-gender-recognition-equaldex.csv")

##### clean and merge data #####

### define outcomes
a$ssm <- ifelse(a$Same.sex.marriage..historical. == "Legal", 1, 0)
b$gender_trans <- ifelse(grepl("Legal", b[,4]), 1, 0)
c$sex_acts <- ifelse(c[,4] == "Legal", 1, 0)
d$non_binary <- ifelse(d[,4] == "Recognized", 1, 0)

### merge outcomes
x$ssm <- a$ssm[match(paste(x$Entity, x$Year), paste(a$Entity, a$Year))]
x$gender_trans <- b$gender_trans[match(paste(x$Entity, x$Year), paste(b$Entity, b$Year))]
x$sex_acts <- c$sex_acts[match(paste(x$Entity, x$Year), paste(c$Entity, c$Year))]
x$non_binary <- d$non_binary[match(paste(x$Entity, x$Year), paste(d$Entity, d$Year))]

### begin sample
x <- x[x$Year >= 1950,]

### deal with NAs
x[, 5:8][is.na(x[, 5:8])] <- 0

### exclude countries that we don't observe any LGBTQ policy
x <- x[x$Code %in% unique(c(a[,2], b[,2], c[,2], d[,2])),]

##### plot 1 prep #####

z <- aggregate(x[,4], list(x$Year), sum)
colnames(z) <- c("year", "population")
for(i in 5:8){
  z1 <- aggregate(x[x[,i] == 1,4], list(x$Year[x[,i] == 1]), sum)
  z <- cbind(z, z1$x[match(z$year, z1$Group.1)])
  colnames(z)[i-2] <- colnames(x)[i]
  z[,i-2][is.na(z[,i-2])] <- 0
  z[,i-2] <- z[,i-2] / z[,2]
}

##### plot share_pop_lgbt_rights #####

### prep image
png("share_pop_lgbt_rights.png", width = 1920, height = 1080, res = 96)
par(mar = c(5, 5, 1, 1))
plot(z$year, z$ssm,
     ylim = c(0, 1), type = "l",
     ylab = "Share of World Population", xlab = "Year",
     cex.lab = 2, cex.axis = 2)

### pride flag background
pride_colors <- c("#FF6666", "#FFB366", "#FFFF66", "#66FF66", "#66B2FF", "#B366FF")
lighten_color <- function(color, factor = 0.6) {
  rgb_color <- col2rgb(color) / 255
  white <- c(1, 1, 1)
  light_color <- rgb_color * (1 - factor) + white * factor
  rgb(light_color[1], light_color[2], light_color[3])
}
pride_colors <- sapply(pride_colors, lighten_color)
usr <- par("usr")
for (i in 1:6) {
  polygon(c(usr[1], usr[2], usr[2], usr[1]), 
          c(usr[3] + (6-i)*(usr[4] - usr[3])/6, usr[3] + (6-i)*(usr[4] - usr[3])/6, 
            usr[3] + (7-i)*(usr[4] - usr[3])/6, usr[3] + (7-i)*(usr[4] - usr[3])/6), 
          col = pride_colors[i], border = NA)
}

### add lines
lines(smooth.spline(z$year, z$sex_acts, spar = 0.5), lwd = 16, col = "darkred", lty = 1)
lines(smooth.spline(z$year, z$gender_trans, spar = 0.5), lwd = 16, col = "darkblue", lty = 2)
lines(smooth.spline(z$year, z$ssm, spar = 0.5), lwd = 16, col = "darkgreen", lty = 3)
lines(smooth.spline(z$year, z$non_binary, spar = 0.5), lwd = 16, col = "black", lty = 4)

### legend
legend("topleft",
       legend = c("Legal Same-Sex Sexual Acts",
                  "Gender Marker Change",
                  "Marriage for Same-Sex Partners",
                  "Non-Binary Gender Option"),
       lwd = 8, lty = 1:4,
       col = c("darkred", "darkblue", "darkgreen", "black"),
       bty = 'n', cex = 3)

# autograph
text(1960, 1.03, 
     "Graph made by @JoshMartinEcon using data from OurWorldInData", 
     pos = 1, col = "darkgrey", cex = 1)

### finish
dev.off()

##### plot 2 prep #####

x$one <- 1

z <- aggregate(x[,9], list(x$Year), sum)
colnames(z) <- c("year", "population")
for(i in 5:8){
  z1 <- aggregate(x[x[,i] == 1,9], list(x$Year[x[,i] == 1]), sum)
  z <- cbind(z, z1$x[match(z$year, z1$Group.1)])
  colnames(z)[i-2] <- colnames(x)[i]
  z[,i-2][is.na(z[,i-2])] <- 0
  z[,i-2] <- z[,i-2] / z[,2]
}

##### plot 2 share_countries_lgbt_rights #####

### prep image
png("share_countries_lgbt_rights.png", width = 1920, height = 1080, res = 96)
par(mar = c(5, 5, 1, 1))
plot(z$year, z$ssm,
     ylim = c(0, 1), type = "l",
     ylab = "Share of Countries", xlab = "Year",
     cex.lab = 2, cex.axis = 2)

### pride flag background
pride_colors <- c("#FF6666", "#FFB366", "#FFFF66", "#66FF66", "#66B2FF", "#B366FF")
lighten_color <- function(color, factor = 0.6) {
  rgb_color <- col2rgb(color) / 255
  white <- c(1, 1, 1)
  light_color <- rgb_color * (1 - factor) + white * factor
  rgb(light_color[1], light_color[2], light_color[3])
}
pride_colors <- sapply(pride_colors, lighten_color)
usr <- par("usr")
for (i in 1:6) {
  polygon(c(usr[1], usr[2], usr[2], usr[1]), 
          c(usr[3] + (6-i)*(usr[4] - usr[3])/6, usr[3] + (6-i)*(usr[4] - usr[3])/6, 
            usr[3] + (7-i)*(usr[4] - usr[3])/6, usr[3] + (7-i)*(usr[4] - usr[3])/6), 
          col = pride_colors[i], border = NA)
}

# autograph
text(1960, 1.03, 
     "Graph made by @JoshMartinEcon using data from OurWorldInData", 
     pos = 1, col = "darkgrey", cex = 1)

### add lines
lines(smooth.spline(z$year, z$sex_acts, spar = 0.5), lwd = 16, col = "darkred", lty = 1)
lines(smooth.spline(z$year, z$gender_trans, spar = 0.5), lwd = 16, col = "darkblue", lty = 2)
lines(smooth.spline(z$year, z$ssm, spar = 0.5), lwd = 16, col = "darkgreen", lty = 3)
lines(smooth.spline(z$year, z$non_binary, spar = 0.5), lwd = 16, col = "black", lty = 4)

### legend
legend("topleft",
       legend = c("Legal Same-Sex Sexual Acts",
                  "Gender Marker Change",
                  "Marriage for Same-Sex Partners",
                  "Non-Binary Gender Option"),
       lwd = 8, lty = 1:4,
       col = c("darkred", "darkblue", "darkgreen", "black"),
       bty = 'n', cex = 3)

### finish
dev.off()