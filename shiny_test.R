install.packages("shiny")
install.packages("DBI")
install.packages("dplyr")
install.packages("dbplyr")
install.packages("pool")
install.packages("RMySQL")

# get pool from GitHub, since it's not yet on CRAN
remotes::install_dev("glue")
devtools::install_github("rstudio/pool")

library(shiny)
library(DBI)
library(dplyr)
library(dbplyr)
library(pool)
library(RMySQL)

## First way

my_db <- dbPool(
  RMySQL::MySQL(), 
  dbname = "movie",
  host = "gureum.cp9olibn3ppn.ap-northeast-2.rds.amazonaws.com",
  username = "admin",
  password = "mastermaster"
)

my_db %>% tbl("Country") %>% head(5)


## Second way

conn <- dbConnect(
  drv = RMySQL::MySQL(),
  dbname = "movie",
  host = "gureum.cp9olibn3ppn.ap-northeast-2.rds.amazonaws.com",
  username = "admin",
  password = "mastermaster"
)

rs <- dbSendQuery(conn, "SELECT * FROM Country LIMIT 5;")

dbFetch(rs)
dbClearResult(rs)
dbDisconnect(conn)


## Third way

conn <- dbConnect(
  drv = RMySQL::MySQL(),
  dbname = "movie",
  host = "gureum.cp9olibn3ppn.ap-northeast-2.rds.amazonaws.com",
  username = "admin",
  password = "mastermaster"
)

dbGetQuery(conn, "SELECT * FROM Country LIMIT 5;")

## Fourth way

ui <- fluidPage(
  numericInput("nrows", "Enter the number of rows to display:", 5),
  tableOutput("tbl")
)

server <- function(input, output, session){
  output$tbl <- renderTable({
    conn <- dbConnect(
      drv = RMySQL::MySQL(),
      dbname = "movie",
      host = "gureum.cp9olibn3ppn.ap-northeast-2.rds.amazonaws.com",
      username = "admin",
      password = "mastermaster")
    on.exit(dbDisconnect(conn), add = TRUE)
    dbGetQuery(conn, paste0(
      "SELECT * FROM Country LIMIT ", input$nrows, ";"))
  })
}

shinyApp(ui, server)
