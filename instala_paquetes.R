install_all_p <- function() { 
	dependencies <- unique(c(
	  	"dplyr",
	  	"tidyr",
	  	"reshape2",
	  	"ggplot2",
	  	"ggvis",
	  	"ggthemes",
	  	"lubridate",
	  	"devtools",
	  	"haven",
	  	"foreign",
	  	"leaflet",
	  	"ggmap",
	  	"rgdal",
	  	'maptools',
	  	'sp',
	  	'raster',
	  	'rgeos',
	  	'doMC',
		'maps',
		'mapproj',
		'tseries',
		"stargazer",
		'dismo',
		"Hmisc",
	  	"shiny",
	  	"shinydashboard",
	  	"RCurl",
	  	"jsonlite",
	  	"scales",
	  	"RGoogleAnalytics",
	  	"DT",
	  	"knitr",
	  	"rmarkdown", 
	  	"evaluate",
	  	"readr",
		"readxl",
 		"WriteXLS",
	  	"stringr",
	  	"stringi",
	  	"rvest",
	  	"xtable",
	  	"RPostgreSQL", 
	  	"tufte" )) ;
  installed_packages <- rownames( installed.packages() )  
  lapply( dependencies, function(x){ 
    	if (!(x %in% installed_packages)){ 
      		install.packages(x, repos= "http://cran.itam.mx/") 
    	} 
   }) 
} 

install_all_p()

cat(rownames(installed.packages()))