library(shinyjs)

source('helpers.R')


shinyUI(fluidPage(
    useShinyjs(),
    div( 
        id = "login_page",
        titlePanel("Welcome to the experiment!"),
        br(),
        sidebarLayout(
            
            sidebarPanel(
                h2("Login"),
                p("Welcome to today's experiment. Please use the user name provided on the instructions to login into the experiment."),
                hidden(
                    div(
                        id = "login_error",
                        span("Your user name is invalid. Please check for typos and try again.", style = "color:red")
                    )
                )
            ),
            
            mainPanel(
                textInput("user", "User", "123"),
                textInput("password", "Password", ""),
                actionButton("login", "Login", class = "btn-primary")
            )
        )
    ),
    
    hidden(
        div( id = "instructions",
            h3("Here we post instructions for subjects..."),
            p("In this experiment you will have to guess in wich direction
              a coin that is tossed repeatedly is biased. You will observe whether
              the coin landed heads or tails over several tosses. "),
            actionButton("confirm", label = "Ok, I got it... let's start")
        )
    ),
    
    hidden(
        div( 
            id = "form",
            titlePanel("Main experimental screen"),
        
            sidebarLayout(
            
                sidebarPanel(
                    p("Indicate whether you think the coin that was tossed is more likely to land heads or tails based on the throws shown to you on the left."),
                    radioButtons("guess", 
                                 label = h3("Your based on the tosses so far"),
                                 choices = list("Heads" = "Heads", "Tails" = "Tails"), 
                                 selected = NULL),
                    actionButton("submit", "Submit", class = "btn-primary")
                ),
        
                mainPanel(
                    h4(textOutput("round_info")),
                    dataTableOutput(outputId="table")
                )
            )
        )
    ),
    
    hidden(
        div( 
        id = "end",
        titlePanel("Thank you!"),
        
        sidebarLayout(
            
            sidebarPanel(
                p("You have reached the end of the experiment. Thank you for your participation."),
                h4("Your payoff details:"),
                textOutput("round")
            ),
            
            mainPanel(
                h4("Overview over your choices"),
                dataTableOutput(outputId="results")
            )
        )
    )
    )
)
)