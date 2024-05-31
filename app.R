library(shiny)
library(bslib)
library(colorspace)
library(ggplot2)

# Find subset of columns that are suitable for scatter plot

source("Mutation-drift_plot.R")


ui <- page_sidebar(
  h1("Mutation-Drift Equilibrium"),
  sidebar = sidebar(
  sliderInput("nalleles","Initial allel number:",min = 1,max = 4,value = 2),
  numericInput("n", "Population size (2n):", value = 10 , min = 6,max = 60,step = 2),
  numericInput("ngen", "Generations:", value = 50, min = 5,max = 100,step = 1),
  numericInput("mutation", "Mutation rate:", value = 0.05,min = 0,max = 1,step = 0.001),
  checkboxInput("ordered","Order"),
  actionButton("rerun","Plot",)),
  fluidPage(
   plotOutput("Mutation_drift_plot"),
   plotOutput("Allele_freq_Plot"),
   plotOutput("hz_plot")
  )
    )


server <- function(input, output, session) {
#  out_matrix <- reactive({mutation_drift_matrix(mutation = input$mutation,n=input$n,ngen = input$ngen,nallels=input$nalleles)})
#  a_freq<-reactive({mde_frec(out_matrix)})
  
  
  seed<-eventReactive(input$rerun,{runif(1,0,100000)})
  
  matrix_out <- eventReactive(input$rerun,{
    
    set.seed(seed())
    
    a<-mutation_drift_matrix(mutation = input$mutation,n=(input$n*2),ngen = input$ngen,nallels=input$nalleles,ordered = input$ordered)
    
    b<-a_freq<-mde_frec(a)
    
    d<-mde_hz_frec(a)
    
    out_list<-list("a"=a,"b"=b,"d"=d)
    
    return(out_list)    
    })
  
  output$Mutation_drift_plot <- renderPlot({
    input$rerun
    mde_plot(matrix_out()[[1]])
  },res = 100)
  
  output$Allele_freq_Plot<- renderPlot({
    input$rerun
    mde_fplot(matrix_out()[[2]])
  },res = 100)
  
  output$hz_plot<- renderPlot({
    input$rerun
    mde_hz_plot(matrix_out()[[3]])
  },res = 100)
  
  
}

shinyApp(ui, server)
