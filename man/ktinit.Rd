\name{ktinit}
\alias{ktinit}
\title{
  Initialize Kerberos using a keytab file
}
\description{
  \code{ktinit} obtains a Kerberos ticket using a keytab file by
  issuing the corresponding \code{kinit} shell command.
}
\usage{
ktinit(keytab = "~/.keytab", user = Sys.getenv("USER"),
       realm = getOption("kerberos.realm"), force=FALSE)
}
\arguments{
  \item{keytab}{loaction of the Kerberos keytab file}
  \item{user}{name of the user}
  \item{realm}{Kerberos realm}
  \item{force}{logical, if \code{FALSE} then \code{ktinit()} first
  use \code{klist} to see if there are tickets in the cache and will
  not authenticate in that case. \code{TRUE} always forces an
  authentication.}
}
\details{
  This is essentially a front-end to
  \code{kinit USER@REALM -k -t ~/.keytab}
  shell command abstracting a few pieces so it's easier to configure
  in R. If \code{realm} is \code{NULL} then it is ommitted.
}
\value{
 \code{TRUE} on success, error on failure to authenticate for any reason.
}
\author{
Simon Urbanek
}
\note{
 Currently requires \code{kinit} and \code{klist} on the \code{PATH}.

 The user should create a keytab, e.g. by running the following in
 their home:

\preformatted{$ ktutil
ktutil:  }\kbd{  addent -password -p user@REALM -k 1 -e aes256-cts
}\preformatted{Password for user@REALM: 
ktutil:  }\kbd{wkt .keytab
}\preformatted{ktutil:  }\kbd{quit
}
}
\examples{
  (tryCatch(ktinit(), error=function(e) cat("FAILED:", e$message)))
}
\keyword{manip}
