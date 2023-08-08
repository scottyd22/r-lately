library(shiny)
library(tidyverse)
library(lubridate)
library(rvest)
library(kableExtra)
library(shinyWidgets)
library(tidyRSS)
library(waiter)

ui <- fluidPage(
  title = 'R Lately',
  # custom style sheet
  theme = 'style.css',
  
  # content for initial loading
  use_waiter(),
  waiterPreloader(color = '#FFFFFF', 
                  fadeout = T,
                  html = paste0(
                    '<h1 style="family: Source Sans Pro; color: #404040;">',
                    'Welcome to <b><font style="color: #040F61; font-family: Arial Black; ">R</font> Lately!</b>',
                    '</h1>',
                    '<h4 style="family: Source Sans Pro; color: #404040;"><i>',
                    'Hang tight while blog and package data are gathered...',
                    '</i></h4>',
                    '<br><br><br>',
                    spin_hexdots()
                    )
                  ),
  
  # google font
  HTML("<style>
        @import url('https://fonts.googleapis.com/css2?family=Source+Sans+Pro&display=swap');
        </style>"
       ),

  # main content
  fluidRow(
    style = 'background-color: #FFFFFF;',
    uiOutput('final_layout')
    ),
  
  # footer
  br(),
  uiOutput('footer'),
  br()
  
)

server <- function(input, output, session) {
  
  # load data ----
  observe({
    posit$d = gather_posit_blogs(30)
    ropensci$d = gather_ropensci_blogs2(30)
    appsilon$d = gather_appsilon_blogs(30)
    cran$d = gather_cran_data(6)
  })
  
  # header ----
  output$header = renderUI({
    
    # title bar ----
    absolutePanel(top = 0, left = 0, height = '100px', width = '100%', fixed = T, draggable = F,
                  br(),
                  
                  # R Lately label 
                  HTML('<h1 style="color:#040F61; display: inline-block; margin-left: 40px; font-family: Arial Black;"><b>R</b></h1><h1 style="display: inline-block;"><b>&nbsp;&nbsp;Lately</b></h1>'),
                  
                  # information button
                  div(
                    dropdownButton(
                      circle = T, 
                      icon = icon('info'),
                      right = T, 
                      width = '325px',
                      tooltip = tooltipOptions(title = 'Additional info', placement = 'left'),
                      
                      uiOutput('reference')
                      ),
                    style = 'float:right; display: inline-block; vertical-align: middle; margin-right: 60px;'
                    ),
                  
                  # panel style
                  # style = 'background-color: whitesmoke; opacity: 90%; z-index: 19000;'
                  style = 'background-color: #FFFFFF; opacity: 100%; z-index: 19000;'
                  )
  })
  
  # about info ----
  output$reference = renderUI({
    
    HTML(paste0(
      '<h4><font style="color: #040F61; font-family: Arial Black; ">R</font><b> Lately</b> consolidates current R content into one location.',
      '<br><br>',
      'When the app is launched, various R-inspired blogs/RSS feeds are gathered and CRAN events searched for the most up-to-date information.',
      '<br><br>',
      'Packages used to create this app include:</h4>',
      '<h5>',
      '<a href="https://shiny.rstudio.com/" target="_"><code>shiny</code></a> <a href="https://www.tidyverse.org/" target="_"><code>tidyverse</code></a> <a href="https://lubridate.tidyverse.org/" target="_" ><code>lubridate</code></a>',
      '<br><br>',
      '<a href="https://rvest.tidyverse.org/" target="_"><code>rvest</code></a> <a href="https://cran.r-project.org/web/packages/kableExtra/vignettes/awesome_table_in_html.html" target="_"><code>kableExtra</code></a> <a href="https://github.com/dreamRs/shinyWidgets" target="_"><code>shinyWidgets</code></a>',
      '<br><br>',
      '<a href="https://github.com/r-hub/pkgsearch" target="_"><code>pkgsearch</code></a> <a href="https://xml2.r-lib.org/" target="_"><code>xml2</code></a> <a href="https://github.com/RobertMyles/tidyRSS" target="_"><code>tidyRSS</code></a> <a href="https://waiter.john-coene.com/#/" target="_"><code>waiter</code></a>',
      '</h5>',
      '<br><br>'
    ))
    
  })
  
  # posit ----
  ## posit data ----
  posit = reactiveValues(d = NULL)

  ## posit counter ----
  posit_counter = reactiveVal(1)

  ## posit prev,next buttons and actions ----
  output$posit_prev = renderUI({
      actionButton('positPrev', label = NULL, icon = icon(name = 'arrow-left', lib = 'font-awesome'),
                   class = 'button')
  })

  output$posit_next = renderUI({
      actionButton('positNext', label = NULL, icon = icon(name = 'arrow-right', lib = 'font-awesome'),
                   class = 'button')
  })

  observeEvent(input$positPrev,{
    # if at the beginning, cycle to the last entry
    if(posit_counter() == 1) {
      posit_counter(nrow(posit$d))
    # otherwise just decrement by 1
    } else {
      posit_counter(posit_counter() - 1)
    }
  })

  observeEvent(input$positNext,{
    # if at the end, cycle to the first entry
    if(posit_counter() == nrow(posit$d)) {
      posit_counter(1)
      # otherwise just increase by 1
    } else {
      posit_counter(posit_counter() + 1)
    }
  })

  ## posit description ----
  output$posit_description = renderUI({

    HTML('<div style="margin-left: 40px; margin-right: 40px;">
                <b>Check out the latest from Posit!</b>
                <br><br>
                Content published in the last <b>30 days</b> is gathered from the
                <i><a href="https://posit.co/blog/" target="_blank" style="color: #337ab7;">Posit Blog &nbsp;<i class="fas fa-external-link-alt"></i></a></i>,
                
                <i><a href="https://rviews.rstudio.com/" target="_blank" style="color: #337ab7;">R Views Blog &nbsp;<i class="fas fa-external-link-alt"></i></a></i>,
                
                <i><a href="https://www.tidyverse.org/blog/" target="_blank" style="color: #337ab7;">Tidyverse Blog &nbsp;<i class="fas fa-external-link-alt"></i></a></i>,

                <i><a href="https://blogs.rstudio.com/tensorflow/" target="_blank" style="color: #337ab7;">Posit AI Blog  &nbsp;<i class="fas fa-external-link-alt"></i></a></i>, and

                <i><a href="https://shiny.posit.co/blog/index.html" target="_blank" style="color: #337ab7;">Shiny Blog &nbsp;<i class="fas fa-external-link-alt"></i></a></i>.
                </div>')

  })


  ## posit cards ----
  output$posit_cards = renderUI({
    lapply(posit_counter(), generate_blog_card, blogs = posit$d)
    })

  ## posit circles ----
  output$posit_circles = renderUI({
    HTML(paste0(
      '<div style="margin-top: 20px;">',
      lapply(1:nrow(posit$d), generate_circles, counter = posit_counter()) |> paste(collapse = ' '),
      '</div>'
      ))
  })
  
  # ropensci ----
  ## ropensci data ----
  ropensci = reactiveValues(d = NULL)

  ## ropensci counter ----
  ropensci_counter = reactiveVal(1)

  ## ropensci prev,next buttons and actions ----
  output$ropensci_prev = renderUI({
    actionButton('ropensciPrev', label = NULL, icon = icon(name = 'arrow-left', lib = 'font-awesome'),
                 class = 'button')
  })

  output$ropensci_next = renderUI({
    actionButton('ropensciNext', label = NULL, icon = icon(name = 'arrow-right', lib = 'font-awesome'),
                 class = 'button')
  })

  observeEvent(input$ropensciPrev,{
    # if at the beginning, cycle to the last entry
    if(ropensci_counter() == 1) {
      ropensci_counter(nrow(ropensci$d))
      # otherwise just decrement by 1
    } else {
      ropensci_counter(ropensci_counter() - 1)
    }
  })

  observeEvent(input$ropensciNext,{
    # if at the end, cycle to the first entry
    if(ropensci_counter() == nrow(ropensci$d)) {
      ropensci_counter(1)
      # otherwise just increase by 1
    } else {
      ropensci_counter(ropensci_counter() + 1)
    }
  })

  ## ropensci description ----
  output$ropensci_description = renderUI({

    HTML('<div style="margin-left: 40px; margin-right: 40px;">
                <b>Explore what\'s new from rOpenSci!</b>
                <br><br>
                Blogs published in the last <b>30 days</b> are gathered from the
                <i><a href="https://ropensci.org/blog/" target="_blank" style="color: #337ab7;">rOpenSci Blog &nbsp;<i class="fas fa-external-link-alt"></i></a></i>.
                </div>')

  })

  ## ropensci cards ----
  output$ropensci_cards = renderUI({
    lapply(ropensci_counter(), generate_blog_card, blogs = ropensci$d)
  })

  ## ropensci circles ----
  output$ropensci_circles = renderUI({
    HTML(paste0(
      '<div style="margin-top: 20px;">',
      lapply(1:nrow(ropensci$d), generate_circles, counter = ropensci_counter()) |> paste(collapse = ' '),
      '</div>'
    ))
  })
  
  # appsilon ----
  ## appsilon data ----
  appsilon = reactiveValues(d = NULL)
  
  ## appsilon counter ----
  appsilon_counter = reactiveVal(1)
  
  ## appsilon prev,next buttons and actions ----
  output$appsilon_prev = renderUI({
    actionButton('appsilonPrev', label = NULL, icon = icon(name = 'arrow-left', lib = 'font-awesome'),
                 class = 'button')
  })
  
  output$appsilon_next = renderUI({
    actionButton('appsilonNext', label = NULL, icon = icon(name = 'arrow-right', lib = 'font-awesome'),
                 class = 'button')
  })
  
  observeEvent(input$appsilonPrev,{
    # if at the beginning, cycle to the last entry
    if(appsilon_counter() == 1) {
      appsilon_counter(nrow(appsilon$d))
      # otherwise just decrement by 1
    } else {
      appsilon_counter(appsilon_counter() - 1) 
    }
  })
  
  observeEvent(input$appsilonNext,{
    # if at the end, cycle to the first entry
    if(appsilon_counter() == nrow(appsilon$d)) {
      appsilon_counter(1)
      # otherwise just increase by 1
    } else {
      appsilon_counter(appsilon_counter() + 1) 
    }
  })
  
  ## appsilon description ----
  output$appsilon_description = renderUI({
    
    HTML('<div style="margin-left: 40px; margin-right: 40px;">
                <b>See recent articles from Appsilon!</b>
                <br><br>
                Blogs published in the last <b>30 days</b> are gathered from the
                <i><a href="https://appsilon.com/blog/" target="_blank" style="color: #337ab7;">Appsilon Blog &nbsp;<i class="fas fa-external-link-alt"></i></a></i>. 
                </div>')
    
  })
  
  ## appsilon cards ----
  output$appsilon_cards = renderUI({
    lapply(appsilon_counter(), generate_blog_card, blogs = appsilon$d)
  })
  
  ## appsilon circles ----
  output$appsilon_circles = renderUI({
    HTML(paste0(
      '<div style="margin-top: 20px;">',
      lapply(1:nrow(appsilon$d), generate_circles, counter = appsilon_counter()) |> paste(collapse = ' '),
      '</div>'
    ))
  })
  
  # cran ----
  ## cran data ----
  cran = reactiveValues(d = NULL)
  
  ## cran counter ----
  cran_counter = reactiveVal(1)
  
  ## cran prev,next buttons and actions ----
  output$cran_prev = renderUI({
    actionButton('cranPrev', label = NULL, icon = icon(name = 'arrow-left', lib = 'font-awesome'),
                 class = 'button')
  })
  
  output$cran_next = renderUI({
    actionButton('cranNext', label = NULL, icon = icon(name = 'arrow-right', lib = 'font-awesome'),
                 class = 'button')
  })
  
  observeEvent(input$cranPrev,{
    # if at the beginning, cycle to the last entry
    if(cran_counter() == 1) {
      cran_counter(length(unique(cran$d$date)))
      # otherwise just decrement by 1
    } else {
      cran_counter(cran_counter() - 1) 
    }
  })
  
  observeEvent(input$cranNext,{
    # if at the end, cycle to the first entry
    if(cran_counter() == length(unique(cran$d$date))) {
      cran_counter(1)
      # otherwise just increase by 1
    } else {
      cran_counter(cran_counter() + 1) 
    }
  })
  
  ## cran description ----
  output$cran_description = renderUI({
    
    HTML('<div style="margin-left: 40px; margin-right: 40px;">
                <b>New packages/versions released on CRAN!</b>
                <br><br>
                Packages released over the last <b>7 days</b> are gathered using the <a href="https://github.com/r-hub/pkgsearch" target="_blank"><code>pkgsearch</code></a> &nbsp;<i class="fas fa-cube"></i>.
         </div>')
    
  })
  
  ## cran cards ----
  output$cran_cards = renderUI({
    lapply(cran_counter(), generate_cran_card, cran = cran$d)
  })
  
  ## cran circles ----
  output$cran_circles = renderUI({
    HTML(paste0(
      '<div style="margin-top: 20px;">',
      lapply(1:length(unique(cran$d$date)), generate_circles, counter = cran_counter()) |> paste(collapse = ' '),
      '</div>'
    ))
  })
  
  # footer ----
  output$footer = renderUI({
    
    HTML('<footer>
          <center>
          <p>Created by Scott Davis, July 2022<p>
          <a href="https://twitter.com/scottyd22" target="_blank"><i class="fa fa-twitter"></i></a> 
          &nbsp;<a href="https://www.linkedin.com/in/sadavis05/" target="_blank"><i class="fa fa-linkedin"></i></a> 
          &nbsp;<a href="https://github.com/scottyd22" target="_blank"><i class="fa fa-github"></i></a> 
          &nbsp;<a href="https://datascott.com/" target="_blank"><i class="fa fa-globe"></i></a>
          </center>
          </footer>'
         )
    
  })
  
  # final layout ----
  output$final_layout <- renderUI({ generate_final_layout() })
  
}

shinyApp(ui, server)
