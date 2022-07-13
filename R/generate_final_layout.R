# generate final layout
generate_final_layout = function() {
  
  fluidRow(
    # header
    fluidRow(uiOutput('header')),
    
    # rstudio row
    fluidRow(style = 'margin-top: 100px;',
             # rstudio detail
             column(5,
                    style = 'background-color: #FFFFFF; color: #040F61; height: 500px;',
                    class = 'bigDescriptions',
                    uiOutput('rstudio_description')
             ),
             
             # rstudio carousel
             column(7, style = 'padding-top: 20px;',
                    HTML('<center>'),
                    tags$div(uiOutput('rstudio_prev', class = 'inline'),
                             uiOutput('rstudio_cards', class = 'inline'),
                             uiOutput('rstudio_next', class = 'inline'),
                             uiOutput('rstudio_circles')
                    ),
                    HTML('</center>')
             )
    ),
    
    br(),
    br(),
    
    # ropensci row
    fluidRow(
      # ropensci detail
      column(5,
             style = 'background-color: whitesmoke; color: #040F61; height: 500px;',
             class = 'bigDescriptions',
             uiOutput('ropensci_description')
      ),
      
      # ropensci carousel
      column(7, style = 'padding-top: 20px; background-color: whitesmoke; color: #040F61; height: 500px;',
             HTML('<center>'),
             tags$div(uiOutput('ropensci_prev', class = 'inline'),
                      uiOutput('ropensci_cards', class = 'inline'),
                      uiOutput('ropensci_next', class = 'inline'),
                      uiOutput('ropensci_circles')
             ),
             HTML('</center>')
      )
    ),
    
    br(),
    br(),
    
    # appsilon row
    fluidRow(
      # appsilon detail
      column(5,
             style = 'background-color: #FFFFFF; color: #040F61; height: 500px;',
             class = 'bigDescriptions',
             uiOutput('appsilon_description')
      ),
      
      # appsilon carousel
      column(7, style = 'padding-top: 20px; background-color: #FFFFFF; color: #040F61; height: 500px;',
             HTML('<center>'),
             tags$div(uiOutput('appsilon_prev', class = 'inline'),
                      uiOutput('appsilon_cards', class = 'inline'),
                      uiOutput('appsilon_next', class = 'inline'),
                      uiOutput('appsilon_circles')
             ),
             HTML('</center>')
      )
    ),
    
    br(),
    br(),
    
    # cran row
    fluidRow(
      # cran detail
      column(5,
             style = 'padding-top: 20px; background-color: whitesmoke; color: #FFFFFF; height: 500px;',
             class = 'bigDescriptions',
             uiOutput('cran_description', style = 'color: #040F61;')
      ),
      
      # cran carousel
      column(7, style = 'padding-top: 20px; background-color: whitesmoke; height: 500px;',
             HTML('<center>'),
             tags$div(uiOutput('cran_prev', class = 'inline'),
                      uiOutput('cran_cards', class = 'inline'),
                      uiOutput('cran_next', class = 'inline'),
                      uiOutput('cran_circles')
             ),
             HTML('</center>')
      )
    ),
    
    br()
  )
  
}