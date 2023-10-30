library(rvest)

# https://www.snipes.ch/robots.txt does not mention /shoes*
# I cannot find ToS on the website
# => webscraping seems to be tolerated

# web scrape sneakers snipes
url <- "https://www.snipes.ch/fr/c/shoes?srule=Standard&prefn1=isSale&prefv1=true&openCategory=true&sz=48"

# check webpage
website <- read_html(url) 

# name of the product
product <- website %>% html_nodes("span.b-product-tile-link.js-product-tile-link") %>% html_text()

# name of the brand
# read_html(url) %>% html_nodes("span") %>% html_attr("data-brand") %>% html_text()
brand <- website %>% html_nodes("span.b-product-tile-brand") %>% html_text()
brand <- gsub("\n","",brand) # remove "\n"

# original price
price <- website %>% html_nodes("span.b-product-tile-price-item--line-through") %>% html_text()
price <- gsub("\n","",price) # remove "\n"
price <- gsub("CHF ","",price) # remove "CHF"
price <- as.double(gsub(",",".",price)) # replace "," by "." and coerce to double

# discounted price
discount <- website %>% html_nodes("span.b-product-tile-price-outer.b-product-tile-price-outer--line-through+.b-product-tile-price-outer .b-product-tile-price-item") %>% html_text()
discount <- gsub("\n","",discount) # remove "\n"
discount <- gsub("CHF ","",discount) # remove "CHF"
discount <- as.double(gsub(",",".",discount)) # replace "," by "." and coerce to double

# create a data frame with difference price - discount
snipes <- data.frame(product = product, brand = brand, price = price, discount = discount, difference = discount - price)

# plot price vs difference
library(ggplot2)
ggplot(snipes, 
       aes(x = price, y = difference, color = brand))+ 
  geom_point() +
  geom_jitter()+
  ylab("Absolute Discount")+
  xlab("Original price") + theme_minimal()
