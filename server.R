library(shiny)
require(digest)
require(dplyr)

source('helpers.R')

shinyServer(
    function(input, output, session) {
        
        output$plot <- renderPlot({
            hist(faithful$eruptions, probability = TRUE, breaks = as.numeric(input$n_breaks),
                 xlab = "Duration (minutes)", main = "Geyser eruption duration")
            
            dens <- density(faithful$eruptions, adjust = input$bw_adjust)
            lines(dens, col = "blue")
        })
        
        # When the Login button is clicked, check whether user name is in list
        observeEvent(input$login, {
            
            # User-experience stuff
            shinyjs::disable("login")
            
            # Check whether user name is correct
            # Fix me: test against a session-specific password here, not username
            user_ok <- input$password==session_password
            
            # If credentials are valid push user into experiment
            if(user_ok){
                shinyjs::hide("login_page")
                shinyjs::show("interactive_chart")
            } else {
                # If credentials are invalid throw error and prompt user to try again
                shinyjs::reset("login_page")
                shinyjs::show("login_error")
                shinyjs::enable("login")
            }
            
        })
    }
)