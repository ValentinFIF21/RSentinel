% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import_theia_download.R
\name{import_theia_download}
\alias{import_theia_download}
\title{Import theia_download python module}
\usage{
import_theia_download(with_aria2 = TRUE, ...)
}
\arguments{
\item{with_aria2}{(optional) Logical: if TRUE (default), the presence of
aria2 is checked; if FALSE, only Wget and python are checked.}

\item{...}{Optional parameters of \code{\link[reticulate]{import}}}
}
\value{
\code{theia_download} python module
}
\description{
\href{https://github.com/pobsteta/theia_download}{theia_download} is
a collection of python scripts used to download
and correct Sentinel-2 images, and it is required by this package.
This internal function check if their dependences (python, wget and aria2)
are installed, and imports the module.
}
\note{
License: GPL 3.0
}
\author{
Pascal Obstetar (20178 \email{pascal.obstetar@gmail.com}
}
