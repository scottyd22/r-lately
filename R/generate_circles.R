# generate circles
generate_circles = function(i, counter) {
  circle_style = "background-color: #FFFFFF; border: 1px solid gainsboro;"
  # change style when card selected
  if(i == counter) { circle_style = "background-color: #BEBEBE; border: 1px solid #B0B0B0;" }
  
  HTML(paste0('<span class="circle" style="', circle_style, '"></span>'))
}