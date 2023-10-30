# Load required libraries
library(shiny)
library(readr)
library(rmarkdown)

# Define the UI
ui <- fluidPage(
  titlePanel("File Verification and Report Generator"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose a CSV file", multiple = FALSE, accept = ".csv"),
      actionButton("verifyButton", "Verify File")
    ),
    mainPanel(
      textOutput("verificationResult"),
      downloadButton("downloadReport", "Download Report")
    )
  )
)

# Define the server logic
server <- function(input, output) {
  # Read the csv file
  data <- reactive({
    inFile <- input$file
    if (is.null(inFile)) return(NULL)
    read.csv(inFile$datapath)
  })
  
  # verification
  verify_file <- eventReactive(input$verifyButton, {
    if (is.null(data())) {
      return("Please select a CSV file first.")
    }
    if (ncol(data()) == 3) {
      return("File verification successful.")
    } else {
      return("File verification failed. Expected 3 columns.")
    }
  })
  
  output$verificationResult <- renderText({
    verify_file()
  })

  # Report
  output$downloadReport <- downloadHandler(
    filename = function() 'myreport.pdf',
    
    content = function(file) {
      src <- normalizePath('report.Rmd')
      
      # temporarily switch to the temp dir, in case you do not have write
      # permission to the current working directory
      owd <- setwd(tempdir())
      on.exit(setwd(owd))
      file.copy(src, 'report.Rmd', overwrite = TRUE)
      
      out <- render('report.Rmd', output_format = 'pdf_document')
      file.rename(out, file)
    }
  )
}

# Run the Shiny app
shinyApp(ui, server)

