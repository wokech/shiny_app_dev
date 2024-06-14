# ShinyUiEditor
# https://www.appsilon.com/post/prototyping-with-shinyuieditor
# https://rstudio.github.io/shinyuieditor/

# Install packages and load library
install.packages("remotes")
remotes::install_github("rstudio/shinyuieditor")

# Troubleshoot
install.packages("withr")

withr::with_envvar(
  list( GITHUB_PAT = gitcreds::gitcreds_get()$password ),
  remotes::install_github('rstudio/shinyuieditor')
)

library(ShinyUiEditor)

# Load app

