# Homework 3

## Snipes Data Web Scraping and Analysis 🕸️📊

### Introduction 📝

This notebook aims to scrape data from the Snipes website, specifically focusing on discounted shoes. We'll extract key information, create a data frame and visualise the discounts in relation to the original prices.

### Pre-requisites 📦

Load the necessary R packages.

```r
library(rvest)
library(ggplot2)
```

### Legal and Ethical Check 📜

Before proceeding with web scraping, ensure to check the website's robots.txt and terms of service.

```r
# https://www.snipes.ch/robots.txt
# The website's robots.txt does not mention /shoes*
# Terms of Service are not clearly listed
# Thus, web scraping appears to be tolerated
```

### Web Scraping 👨‍💻

#### Fetching Website Data 🌐

Connect to the Snipes website and read the HTML content.

```r
url <- "https://www.snipes.ch/fr/c/shoes?srule=Standard&prefn1=isSale&prefv1=true&openCategory=true&sz=48"
website <- read_html(url) 
```

#### Extracting Product Information 🏷️

We'll extract the following information: product name, brand, original price, and discounted price.

##### Product Name

```r
product <- website %>% html_nodes("span.b-product-tile-link.js-product-tile-link") %>% html_text()
```

##### Brand Name

```r
brand <- website %>% html_nodes("span.b-product-tile-brand") %>% html_text()
brand <- gsub("\n", "", brand) # Remove "\n"
```

##### Original Price

```r
price <- website %>% html_nodes("span.b-product-tile-price-item--line-through") %>% html_text()
price <- gsub("\n", "", price) # Remove "\n"
price <- gsub("CHF ", "", price) # Remove "CHF"
price <- as.double(gsub(",", ".", price)) # Replace "," by "." and coerce to double
```

##### Discounted Price

```r
discount <- website %>% html_nodes("span.b-product-tile-price-outer.b-product-tile-price-outer--line-through+.b-product-tile-price-outer .b-product-tile-price-item") %>% html_text()
discount <- gsub("\n", "", discount) # Remove "\n"
discount <- gsub("CHF ", "", discount) # Remove "CHF"
discount <- as.double(gsub(",", ".", discount)) # Replace "," by "." and coerce to double
```

### Data Aggregation and Analysis 📊

#### Creating Data Frame 📋

Aggregate the scraped data into a data frame, also adding a column for the difference between the original price and discounted price.

```r
snipes <- data.frame(product = product, brand = brand, price = price, discount = discount, difference = discount - price)
```

#### Data Visualisation 📉

Plotting the original price against the discount offered for each brand.

```r
ggplot(snipes, 
       aes(x = price, y = difference, color = brand)) + 
  geom_point() +
  geom_jitter() +
  ylab("Absolute Discount") +
  xlab("Original price") + 
  theme_minimal()
```

![snipes2](snipes2.png)

#### Save data frame to CSV 📄

Will be helpful for future analysis.

```r
snipes %>% 
    dplyr::select(discount, brand, price) %>% 
    readr::write_csv("data/snipes.csv")
```

---

## File Verification and Report Generation Using Shiny 🌟📑

### Introduction 📝

This notebook outlines how to build a Shiny app to verify CSV files and generate downloadable PDF reports. The app will verify that the uploaded CSV file has exactly 3 columns.

### Pre-requisites 📦

Load the necessary R packages.

```r
library(shiny)
library(readr)
library(rmarkdown)
```

### User Interface (UI) 🖥️

The user interface of our Shiny app comprises a sidebar for file input and verification and a main panel for displaying the verification result and the download button for the report.

```r
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
```

### Server Logic 🖥️⚙️

Here, we define the server logic that dictates how the Shiny app will function.

#### File Reading 📖

This section reads the uploaded CSV file.

```r
data <- reactive({
  inFile <- input$file
  if (is.null(inFile)) return(NULL)
  read.csv(inFile$datapath)
})
```

#### File Verification ✅❌

We verify if the file has exactly 3 columns.

```r
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
```

#### Display Results 📋

Display the verification result in the main panel.

```r
output$verificationResult <- renderText({
  verify_file()
})
```

#### Report Generation 📊📑

Generate a downloadable PDF report.

```r
output$downloadReport <- downloadHandler(
  filename = function() 'myreport.pdf',
  
  content = function(file) {
    src <- normalizePath('report.Rmd')
    
    owd <- setwd(tempdir())
    on.exit(setwd(owd))
    file.copy(src, 'report.Rmd', overwrite = TRUE)
    
    out <- render('report.Rmd', output_format = 'pdf_document')
    file.rename(out, file)
  }
)
```

### Run the Shiny App 🚀

Execute the code to run the Shiny app.

```r
shinyApp(ui, server)
```

---

## Corporate Performance Analysis: An Object-Oriented Approach

### Libraries 📚

First, we load the necessary libraries. These will help us with data manipulation (`tidyverse`), data display (`knitr`), and improved table styling (`kableExtra`).

```r
library(tidyverse)
library(knitr)
library(kableExtra)
```

### Data import 📤

We start by importing our dataset. The `read_csv` function from the `tidyverse` package is used to read the `employee_data.csv` file into R. We then display the first few rows of the dataset to get a glimpse of its structure and contents.

```r
data <- read_csv(
  file = "data/employee_data.csv",
  col_types = "iccccdd"
)

data %>%
  head(n = 12) %>% 
  kable(
    caption = "Preview of Employee Data", 
    format = "html",
    col.names = c("Employee ID", "Name", "Department", "Designation", "Month", "Monthly Sales", "Monthly Customer Feedback Score")
  ) %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"))

```

### Class creation 🛠

#### Employee Class 🧑‍💼

##### Employee: Constructor 🏗️

The Employee class represents individual employees. We begin by defining a constructor function, `create_employee`, which ensures that each employee object has the correct attributes and that these attributes meet our specifications.

```r
# Constructor function for the Employee class
create_employee <- function(Employee_ID, Name, Department, Designation, Monthly_Sales, Monthly_Customer_Feedback_Score) {
  
  # Checks for Employee
  if (!is.integer(Employee_ID) || Employee_ID < 0) stop("Employee_ID should be a non-negative integer.")
  if (!is.character(Name) || Name == "") stop("Name should be a non-empty string.")
  if (!is.character(Department) || Department == "") stop("Department should be a non-empty string.")
  if (!is.character(Designation) || Designation == "") stop("Designation should be a non-empty string.")
  if (!is.numeric(Monthly_Sales) || any(Monthly_Sales < 0)) stop("Monthly_Sales should be a non-negative numeric vector.")
  if (!is.numeric(Monthly_Customer_Feedback_Score) || any(Monthly_Customer_Feedback_Score < 0) || any(Monthly_Customer_Feedback_Score > 10)) 
    stop("Monthly_Customer_Feedback_Score should be a numeric vector with values between 0 and 10.")
  
  # Object creation using structure
  employee <- structure(
    list(
      Employee_ID = Employee_ID,
      Name = Name,
      Department = Department,
      Designation = Designation,
      Monthly_Sales = Monthly_Sales,
      Monthly_Customer_Feedback_Score = Monthly_Customer_Feedback_Score
    ),
    class = "Employee"
  )
  
  return(employee)
}
```

##### Employee: Methods 🛠

Next, we define methods for the `Employee` class. These methods will allow us to interact with and analyse individual employee objects. We include methods to print the employee's details (`print`), calculate their overall performance score (`performance`), summarise their yearly performance (`summary`), and visualise their monthly sales trend (`plot`).

```r
# Print method for Employee class
print.Employee <- function(x, ...) {
  cat("Employee ID:", x$Employee_ID, "\n")
  cat("Name:", x$Name, "\n")
  cat("Department:", x$Department, "\n")
  cat("Designation:", x$Designation, "\n")
  cat("Monthly Sales:", toString(x$Monthly_Sales), "\n")
  cat("Monthly Customer Feedback Score:", toString(x$Monthly_Customer_Feedback_Score), "\n")
  invisible(x)
}

performance.Employee <- function(employee) {
  avg_sales <- mean(employee$Monthly_Sales)
  avg_feedback <- mean(employee$Monthly_Customer_Feedback_Score)
  
  standardized_sales <- avg_sales / 500
  performance_score <- (standardized_sales + avg_feedback) / 2
  return(performance_score)
}

# Summary method for Employee class
summary.Employee <- function(x, ...) {
  avg_sales <- mean(x$Monthly_Sales)
  avg_feedback <- mean(x$Monthly_Customer_Feedback_Score)
  total_sales <- sum(x$Monthly_Sales)
  
  standardized_sales <- avg_sales / 500
  performance_score <- (standardized_sales + avg_feedback) / 2
  
  cat("Average Monthly Sales:", round(avg_sales, 2), "\n")
  cat("Average Monthly Customer Feedback Score:", round(avg_feedback, 2), "\n")
  cat("Total Sales for the Year:", total_sales, "\n")
  cat("Overall Performance Score:", round(performance_score, 2), "\n")
  invisible(x)
}


# Plot method for Employee class
plot.Employee <- function(x, type="o", main = "Monthly Sales Trend", xlab="Month", ylab="Sales", col="blue", ylim=c(min(x$Monthly_Sales) - 10, max(x$Monthly_Sales) + 10), ...) {
  plot(x$Monthly_Sales, type=type, main=main,
       xlab=xlab, ylab=ylab, col=col, ylim = ylim, ...)
  invisible(x)
}
```

#### Designation Class 🏢

##### Designation: Constructor 🏗

The `Designation` class represents a collection of employees that share the same job title. We define a constructor function, `create_designation`, to ensure that each designation object contains the required attributes and that these attributes are valid.

```r
# Constructor function for the Designation class
create_designation <- function(Designation_Name, List_of_Employees) {
  
  # Checks for Designation
  if (!is.character(Designation_Name) || Designation_Name == "") stop("Designation_Name should be a non-empty string.")
  if (!all(sapply(List_of_Employees, function(e) inherits(e, "Employee")))) stop("List_of_Employees should contain only Employee objects.")
  
  # Object creation using structure
  designation <- structure(
    list(
      Designation_Name = Designation_Name,
      List_of_Employees = List_of_Employees
    ),
    class = "Designation"
  )
  
  return(designation)
}
```

##### Designation: Methods 🛠

Now, we define methods for the `Designation` class. These methods allow us to interact with and analyse groups of employees based on their job title. We include methods to print the details of all employees within a designation (`print`), summarise the performance metrics of the designation (`summary`), and visualise the cumulative monthly sales trend of the designation (`plot`).

```r
# Print method for Designation class
print.Designation <- function(x, ...) {
  cat("Designation Name:", x$Designation_Name, "\n")
  cat("Number of Employees:", length(x$List_of_Employees), "\n")
  
  # Loop through each employee, print their details, and then print a separator
  for (emp in x$List_of_Employees) {
    # cat("---------------------------------------------------\n")
    cat("---\n")
    print.Employee(emp)
  }
  
  invisible(x)
}

# Summary method for Designation class
summary.Designation <- function(x, ...) {
  avg_sales <- mean(unlist(lapply(x$List_of_Employees, function(e) mean(e$Monthly_Sales))))
  avg_feedback <- mean(unlist(lapply(x$List_of_Employees, function(e) mean(e$Monthly_Customer_Feedback_Score))))
  
  top_performer <- x$List_of_Employees[[which.max(unlist(lapply(x$List_of_Employees, performance.Employee)))]]
  
  cat("Average Monthly Sales for Designation:", round(avg_sales, 2), "\n")
  cat("Average Monthly Customer Feedback Score for Designation:", round(avg_feedback, 2), "\n")
  cat("Top Performing Employee in Designation:", top_performer$Name, "\n")
  cat("Performance Score:", round(performance.Employee(top_performer), 2), "\n")
  invisible(x)
}

# Plot method for Designation class
plot.Designation <- function(x, type="o", main="Cumulative Monthly Sales Trend",
       xlab="Month", ylab="Total Sales", col="blue", ...) {
  total_monthly_sales <- colSums(do.call(rbind, lapply(x$List_of_Employees, function(e) e$Monthly_Sales)))
  plot(total_monthly_sales, type=type, main=paste("Cumulative Monthly Sales Trend for", x$Designation_Name),
       xlab=xlab, ylab=ylab, col=col, ...)
  invisible(x)
}
```

### Data Wrangling 📊

With our classes defined, we now transform our dataset into a format suitable for object-oriented analysis. We start by converting the long-format dataset into individual `Employee` objects. Then, we group these employee objects by their designation to create `Designation` objects.

```r
data_nested <- data %>%
  select(-Month) %>% 
  chop(c(Monthly_Sales, Monthly_Customer_Feedback_Score))

# List to hold Employee objects
list_of_employees <- vector("list", nrow(data_nested))

# Create Employee objects for each row in the grouped data
for (i in 1:nrow(data_nested)) {
  emp <- create_employee(
    Employee_ID = data_nested$Employee_ID[i],
    Name = data_nested$Name[i],
    Department = data_nested$Department[i],
    Designation = data_nested$Designation[i],
    Monthly_Sales = data_nested$Monthly_Sales[[i]],
    Monthly_Customer_Feedback_Score = data_nested$Monthly_Customer_Feedback_Score[[i]]
  )
  list_of_employees[[i]] <- emp
}

# Group Employee objects by Designation to create Designation objects
designations <- unique(data_nested$Designation)
list_of_designations <- vector("list", length(designations))
names(list_of_designations) <- designations

for (desig in designations) {
  desig_employees <- list_of_employees[sapply(list_of_employees, function(e) e$Designation == desig)]
  desig_obj <- create_designation(Designation_Name = desig, List_of_Employees = desig_employees)
  list_of_designations[[desig]] <- desig_obj
}
```

### Analysis 🔍

Now that our data is structured into `Employee` and `Designation` objects, we can perform our analysis. We'll start by examining the performance metrics of each designation. Next, we identify and analyse the top-performing employee within each designation.

```r
# For each designation, invoke the print and summary methods to understand its performance metrics.
lapply(list_of_designations, function(desig) {
  cat("---------------------------------------------------\n")
  print(desig)
  cat("---------------------------------------------------\n")
  summary(desig)
  cat("---------------------------------------------------\n\n")
})

# Identify the best employee in each designation.
# For the top employee in each designation, invoke their print, summary, and plot methods to showcase their performance.
lapply(list_of_designations, function(desig) {
  top_employee <- desig$List_of_Employees[[which.max(unlist(lapply(desig$List_of_Employees, performance.Employee)))]]
  
  cat("---------------------------------------------------\n")
  cat("Top Employee from the", desig$Designation_Name, "Designation:\n")
  cat("---------------------------------------------------\n")
  
  print(top_employee)
  summary(top_employee)
  plot(top_employee, main = paste("Monthly Sales Trend:", top_employee$Name))
  
  cat("---------------------------------------------------\n\n")
})
```

### Conclusions 📝

Based on our analysis, we can draw several conclusions regarding the performance of different designations and their top-performing employees.

As we can see, the **Sales Manager** designation ended the year with the highest average monthly sales, with **Gabriel Brunner** as the most extraordinary employee achieving a stunning 11.62 performance! Good job!

![top_performance](top_performance.png)

Honorable mention goes to **Sarah Frei** from the **Sales Executive** designation with a performance of 9.59. Well done!

![montly_sales](montly_sales.png)
