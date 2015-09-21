# Define the mandatory fiedls here
# which fields get saved 
fieldsAll <- c("user", "guess")

# which fields are mandatory
fieldsMandatory <- c("guess")

responsesDir <- file.path("responses")

# Password to login for this session
session_password <- "koelsch"

### Generate data here
### 
### 
### 
set.seed(1906)
n_rounds <- 2
n_flips <- 3
probs <- c(0.6,0.4)
prize <- 1
show_up <- 10
probas <- array(, c(n_rounds, 2))
true_state <- sample(c("Heads", "Tails"), n_rounds, replace = TRUE)
for(i in 1:n_rounds){
    if(true_state[i]=="Heads"){
        probas[i,] <- probs
    } else {
        probas[i,] <- probs[2:1]
    }
}

flips <- sapply(1:n_rounds, function(x) sample(c(1, -1), n_flips, 
                                               replace = TRUE, 
                                               prob = probas[x, ])
                )
flips <- data.frame(flips)

cascade <- function(x, thin){
    tmp <- rep(1, n_flips) %x% x
    dim(tmp) <- c(n_flips, n_flips)
    tmp[lower.tri(tmp)] <- NA
    tmp[tmp==1] <- "Heads"
    tmp[tmp!="Heads"] <- "Tails"
    if(thin > 1){
        tmp <- tmp[, seq(1, ncol(tmp), thin)]
    }
    return(tmp)
}

tmp <- lapply(flips, cascade, thin = 2)
flips <- do.call(cbind, tmp)

n_guesses <- ncol(flips)
guesses_per_round <- n_guesses/n_rounds

# add an asterisk to an input label
labelMandatory <- function(label) {
    tagList(
        label,
        span("*", class = "mandatory_star")
    )
}

# CSS to use in the app
appCSS <-  ".mandatory_star { color: red; }
.shiny-input-container { margin-top: 25px; }
.shiny-progress .progress-text {
font-size: 18px;
top: 50% !important;
left: 50% !important;
margin-top: -100px !important;
margin-left: -250px !important;
}"

# Helper functions
humanTime <- function() format(Sys.time(), "%d-%m-%Y-%H-%M-%S")

saveData <- function(data) {
    fileName <- sprintf("%s_%s.csv",
                        humanTime(),
                        digest::digest(data))
    
    write.csv(x = data, file = file.path(responsesDir, fileName),
              row.names = FALSE, quote = TRUE)
}

payoffRound <- function(user){
    set.seed(user)
    out <- sample(seq(1, n_guesses), 1)
    return(out)
}

epochTime <- function() {
    as.integer(Sys.time())
}
