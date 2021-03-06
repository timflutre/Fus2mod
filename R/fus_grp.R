group_fl2 <- function(response, regressors, group, group_by =NULL, uniq_modal = NULL, modal, seq.a = NULL,
                      lambda = NULL, mina = 0.1, nfold = 5, nrep= 10,
                      nb.cores = 3, plot = TRUE, a = 1, nlambda = 100){


  p  <- ncol(regressors)
  X  <- model.matrix(~modal + modal:regressors - 1)
  if(is.null(colnames(regressors))) colnames(regressors) <- paste0('regressors', 1:p)
  X2  <- cbind(X,regressors)

  if (is.null(group)){
    Gr <- colnames(X2) %>%
            as.tibble() %>%
      separate(value, c('Class',"Loc"," Type"), sep = ":", fill = "left")

    grp <- paste(Gr$Class, Gr$Loc)
    grp <- as.numeric(factor(grp, levels = unique(grp)))

  }
  ord <- order(grp)
  print(grp[order(grp)])
  nb <- (max(grp) - 1) / 3

  # grp <- c(1,1,group, group + nb, group + 2 * nb)
  b <- (3 * nb - a * nb + 2) / (2 * nb )
  print(b)
  mod <- gglasso(x = X2[,ord], group= grp[ord], loss = 'ls', y = response,
                pf = c(0, rep(b, 2 * nb), rep(a, nb)),
                intercept = F, lambda = lambda, nlambda = nlambda)
  return(list(mod= mod,grp=  grp,ord = ord, Est = X2[,ord] %*% mod$beta))

}



group_fl2_adaptive <- function(response, regressors, group, group_by =NULL, uniq_modal = NULL, modal, seq.a = NULL,
                      lambda = NULL, mina = 0.1, nfold = 5, nrep= 10,
                      nb.cores = 3, plot = TRUE, a = 1, nlambda = 100){


  p  <- ncol(regressors)
  X  <- model.matrix(~modal + modal:regressors - 1)
  if(is.null(colnames(regressors))) colnames(regressors) <- paste0('regressors', 1:p)
  X2  <- cbind(X,regressors)

  if (is.null(group)){
    Gr <- colnames(X2) %>%
      as.tibble() %>%
      separate(value, c('Class',"Loc"," Type"), sep = ":", fill = "left")

    grp <- paste(Gr$Class, Gr$Loc)
    grp <- as.numeric(factor(grp, levels = unique(grp)))

  }
  ord <- order(grp)
  nb <- (max(grp) - 1) / 3

  # grp <- c(1,1,group, group + nb, group + 2 * nb)
  b <- (3 * nb - a * nb + 2) / (2 * nb )
  bOLSr <- lm.ridge(response ~ X2[,ord] -1, lambda = 0.1)$coef
  bOLSgr <- tapply(bOLSr,grp[ord],function(x){sqrt(sum(x^2))})

  mod <- gglasso(x = X2[,ord], group= grp[ord], loss = 'ls', y = response,
                 pf = n * c(0, rep(b, 2 * nb), rep(a, nb)) / bOLSgr ,
                 intercept = F, lambda = lambda, nlambda = nlambda)
  return(list(mod= mod,grp=  grp,ord = ord, Est = X2[,ord] %*% mod$beta,
              grp_ord=grp[ord],bOLSgr=bOLSgr))

}

gFL2 <- function(response, X2,
                      lambda = NULL, a, nb){

  mod <- gglasso(x = X2[,ord], group= grp[ord], loss = 'ls', y = response,
                 pf = c(0, rep(b, 2 * nb), rep(a, nb)),
                 intercept = F, lambda = lambda, nlambda = nlambda)
  return(list(mod= mod,grp=  grp,ord = ord))

}




fus_grp <-  function(response, regressors, grp, group_by =NULL, uniq_modal = NULL, modal, seq.a = NULL,
                                 lambda = NULL, mina = 0.1, nfold = 5, nrep= 10,
                                 nb.cores = 3, plot = TRUE, a = 1, nlambda = 100){


  p  <- ncol(regressors)
  X  <- model.matrix(~modal + modal:regressors - 1)
  if(is.null(colnames(regressors))) colnames(regressors) <- paste0('regressors', 1:p)
  X2  <- cbind(X,regressors)

  if (is.null(grp)){
    Gr <- colnames(X2) %>%
      as.tibble() %>%
      separate(value, c('Class',"Loc"," Type"), sep = ":", fill = "left")

    grp <- paste(Gr$Class, Gr$Loc)
    grp <- as.numeric(factor(gr, levels = unique(gr)))

  }
  ord <- order(grp)
  print(grp[order(grp)])
  nb <- (max(grp) - 1) / 3
  if (is.null(seq.a)) seq.a <- seq(mina, ((3 * nb + 2) / (2 * nb)) - 0.001,len=20)
  X2 <- X2[,ord]
  grp <- grp[ord]
  mod <- seq.a %>%
           as.tibble() %>%
           mutate(Model = map(value, ~ gglasso(x = X2, group= grp, loss = 'ls', y = response,
                                               pf = c(0, rep(((3 * nb - . * nb + 2) / (2 * nb )), 2 * nb), rep(., nb)),
                                               intercept = F, lambda = lambda, nlambda = nlambda))) %>%
           mutate(Coefficients = map(Model,~.$beta))
  return(list(mod= mod,grp =  grp,ord = ord, X2 = X2))

}
