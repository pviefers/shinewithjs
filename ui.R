library(shinyjs)

shinyUI(fluidPage(
    useShinyjs(),
    div( 
        id = "login_page",
        titlePanel("Welcome"),
        br(),
        sidebarLayout(
            
            sidebarPanel(
                h2("Login"),
                p("Please enter user name and password."),
                hidden(
                    div(
                        id = "login_error",
                        span("Invalid. Please check for typos and try again.", style = "color:red")
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
        div( id = "interactive_chart",
             selectInput("n_breaks", label = "Number of bins:",
                         choices = c(10, 20, 35, 50), selected = 20),
             
             sliderInput("bw_adjust", label = "Bandwidth adjustment:",
                         min = 0.2, max = 2, value = 1, step = 0.2),
             plotOutput("plot")
        )
    )
)
)