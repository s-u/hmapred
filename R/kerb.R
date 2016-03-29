ktinit <- function(keytab="~/.keytab", user=Sys.getenv("USER"), realm=getOption("kerberos.realm")) {
  if (!file.exists(keytab))
    stop("Kerberos keytab file `", keytab, "' doesn't exist!")
  if (!is.null(realm)) user <- paste0(user, "@", realm)
  if (system(paste("kinit", shQuote(user), "-k -t ~/.keytab")) != 0)
    stop("kinit failed for ", user)
  invisible(TRUE)
}
