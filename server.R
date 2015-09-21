library(shiny)
require(digest)
require(dplyr)

source('helpers.R')

shinyServer(
    function(input, output, session) {
        values <- reactiveValues(round = 1)
        values$df <- NULL
        
        # Gather all the form inputs (and add timestamp)
        formData <- reactive({
            data <- sapply(fieldsAll, function(x) input[[x]])
            data <- c(round = values$round-1, data, timestamp = humanTime(), payoff = NA)
            data <- t(data)
            data
        }) 
        
        output$table <- renderDataTable({
            if(values$round > 1 && values$round <= n_guesses){
                withProgress(message = 'Flipping the coin.',
                             detail = 'Please wait...', value = 0, {
                                 for (i in 1:15) {
                                     incProgress(1/15)
                                     Sys.sleep(0.05)
                                 }
                             })
            }
            idx.row <- sum(!is.na(flips[, min(values$round, n_guesses)]))
            idx.col <- min(values$round, n_guesses)
            data.frame(Wurf = seq(1, idx.row), Seite= flips[1:idx.row, idx.col])
        },
            options = list(paging = FALSE, 
                       searching = FALSE,
                       ordering = FALSE
            )
        )
        
        # This renders the table of choices made by a participant that is shown
        # to them on the final screen
        output$results <- renderDataTable({
            out <- data.frame(Round = rep(seq(1,n_rounds), each = guesses_per_round),
                              Guess = seq(1, n_guesses),
                              choice = values$df[,3],
                              actual = rep(true_state, each = guesses_per_round)
                              )
            colnames(out) <- c("Round", "Guess no.", "Your choice", "Correct/True value")
            out
        },
            options = list(paging = FALSE, 
                       searching = FALSE,
                       ordering = FALSE
            )
        )
        
        output$round_info <- renderText({
            paste0("Round ", ceiling(values$round/guesses_per_round), " of ", n_rounds)
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
                shinyjs::show("instructions")
                
                # Save username to write into data file
                output$username <- renderText({input$user})
            } else {
                # If credentials are invalid throw error and prompt user to try again
                shinyjs::reset("login_page")
                shinyjs::show("login_error")
                shinyjs::enable("login")
            }
            
        })
        
        observeEvent(input$confirm, {
            hide("instructions")
            show("form")
        })

        # When the Submit button is clicked, submit the response
        observeEvent(input$submit, {
            isolate({
                values$round <- values$round +1 
            })
            
            newLine <- isolate(formData())
            isolate({
                values$df <- rbind(values$df, newLine)
            })
            
            if(values$round > n_guesses){
                isolate(values$payroll <- payoffRound(as.numeric(input$user)))
                output$round <- renderText({
                    paste0("The computer selected your guess number ", values$payroll, 
                           ". Because you guessed ",ifelse(values$df[values$payroll, 3]==true_state[values$payroll], "correctly ", "incorrectly "),
                           "we will add ", ifelse(values$df[values$payroll, 3]==true_state[values$payroll], prize, 0),
                           " Euro to your show-up fee. Your total payoff will therefore equals ",
                           ifelse(values$df[values$payroll, 3]==true_state[values$payroll], prize, 0) + show_up, " Euro.")
                })
                isolate(values$df[, 5] <- ifelse(values$df[values$payroll, 3]==true_state[values$payroll], prize, 0) + show_up)
                saveData(values$df)
#                 reset(id = "form")
                hide(id = "form")
                show(id = "end")
            }
        })

    }
)