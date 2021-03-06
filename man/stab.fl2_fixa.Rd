% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stab.fl2_fixa.R
\name{stab.fl2_fixa}
\alias{stab.fl2_fixa}
\title{Stability selection for fuse lasso}
\usage{
stab.fl2_fixa(response, regressors, group, a, lambda = NULL, nrep = 1000,
  nb.cores = 3, plot = TRUE)
}
\arguments{
\item{response}{a vector response variable}

\item{regressors}{a quantitative matrix of regressor}

\item{group}{a vector with two levels. (The group of the ANCOVA)}

\item{a}{the parameters that indicate how much the coefficients will be fused}

\item{lambda}{if the user wants to use it owns values of lambdas}
}
\value{
The coefficients of the fused lasso ANCOVA for the different value of lambda
}
\description{
Cross-validation for lambda followed by stability selection, a being known.
}
\examples{
B <- c(1, -1, 1.5, 1.5, rep(0, 6), 2, 0, 2, 0)
group <- c(rep('M1', 10), rep('M2', 10))
regressors <- matrix(rnorm(6*20), ncol = 6)
X  <- model.matrix(~group + group:regressors - 1)
y <- X\%*\%B + rnorm(20)
y <- scale(y)
mod1 <- bic.fl2(y, regressors, group)
mod <- stab.fl2_fixa(y, regressors, group, a = mod1[[3]])
coef(mod, s='lambda.min')
}
\seealso{
\code{\link{cv.fl2}}, \code{\link{cv_fl2_fixa}}
}
