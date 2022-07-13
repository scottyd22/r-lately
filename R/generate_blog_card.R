# generate blog card
generate_blog_card = function(i, blogs) {
  bgColor = '#FFFFFF'
  
  df = blogs[i,]
  df$blog_name = deparse(substitute(blogs))
  
  # add Logos if no image is available
  if(is.na(df$image) & str_detect(df$blog_name, 'rstudio')) {df$image = 'rstudio_logo.PNG'}
  if(is.na(df$image) & str_detect(df$blog_name, 'ropensci')) {df$image = 'ropensci_logo.PNG'}
  if(is.na(df$image) & str_detect(df$blog_name, 'appsilon')) {df$image = 'appsilon_logo.PNG'}
  
  # add 'by' if an author exists
  if(!is.na(df$author) & !df$author %in% c('', '')) {df$author = paste0('by ', df$author)}
  
  # truncate summary if too long (more than 50 words)
  if(str_count(df$summary, '\\w+') > 50) {df$summary = paste0(word(df$summary, 1, 50), ' ...')}
  
  HTML(paste0('<div class="card" style="background-color: ', bgColor, '";>
                <img src=', df$image, ' alt="" style="max-height:200px; width:400px;"/>
                <hr>
                <div>
                  <p style="float:left; margin-left: 5px; color: gray; margin-top: 5px margin-bottom: 0px; display: inline-block;">', df$blog, '</p>
                  <p style="float:right; margin-right: 5px; color: gray; margin-bottom: 0px; display: inline-block;">', df$date, '</p>
                </div>
                <br>
                <h4><b><a href="', df$link,'" target="_blank">', df$title, '&nbsp;<i class="fas fa-external-link-alt"></i></a></b></h4>
                <h5>', df$author, '</h5>
                <div style="margin-left: 10px; margin-right: 10px;"><font class="summary">', df$summary, '</font></div>
              </div>'
              )
       )
}