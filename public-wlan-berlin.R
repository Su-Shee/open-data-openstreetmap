library(ggmap)
library(mapproj)

file <- 'public-wlan-berlin.csv'
csv  <- read.csv(file, header = TRUE, sep = ';')

names  = c(csv$location)
longis = c(csv$longitude)
latis  = c(csv$latitude)

# Center of the map (whatever you want it to be)
center = c(13.379, 52.517)

# Basic data
access_points <- data.frame(name = csv$charge, longitude = longis, latitude = latis)

# Fetch the map - higher zoom, greater detail, less points displayed
berlin = get_map(location = center, zoom = 12)

# Draw the map
berlinmap = ggmap(berlin)

# Add a title 
berlinmap <- berlinmap + ggtitle('Öffentliches WLan in Berlin')

# Add the locations
berlinmap <- berlinmap + geom_point(data = access_points, 
                                    aes(x = longitude, y = latitude, colour = csv$location), 
                                    size = 6) 

# Add labels to the location
berlinmap <- berlinmap + geom_text(data = access_points, 
                                   aes(label = name, x = longitude + .002, y = latitude), 
                                   size = 4, srt = 25)

# Removes axis ticks, axis labels and the legend
berlinmap <- berlinmap + theme(legend.position = "none", 
                               plot.title      = element_text(face = "bold", vjust = 1.5, size = 14),
                               axis.title.x    = element_blank(), 
                               axis.title.y    = element_blank(), 
                               axis.ticks      = element_blank(), 
                               axis.text.x     = element_blank(), 
                               axis.text.y     = element_blank())
