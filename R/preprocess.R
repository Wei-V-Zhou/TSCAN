#' preprocess
#' 
#' preprocess the raw single-cell data
#'
#' This function first takes logarithm of the raw data and then filters out genes/features in which too many cells are low expressed. 
#' It also filters out genes/features with low coefficient of variance which indicates the genes/features does not contain much information.
#' The default setting will first take log2 of the raw data after adding a pseudocount of 1. Then genes/features in which at least half of cells have expression values are greater than 1 and the coefficeints of variance across all cells are at least 1 are retained.
#'
#' @param data The raw single_cell data, which is a numeric matrix or data.frame. Rows represent genes/features and columns represent single cells.
#' @param clusternum The number of clusters for doing cluster, typically 5 percent of number of all genes. The clustering will be done after all the transformation and trimming. If NULL no clustering will be performed.
#' @param takelog Logical value indicating whether to take logarithm 
#' @param logbase Numeric value specifiying base of logarithm
#' @param pseudocount Numeric value to be added to the raw data when taking logarithm
#' @param minexpr_value Numeric value specifying the minimum cutoff of log transformed (if takelog is TRUE) value
#' @param minexpr_percent Numeric value specifying the lowest percentage of highly expressed cells (expression value bigger than minexpr_value) for the genes/features to be retained.
#' @param cvcutoff Numeric value specifying the minimum value of coefficient of variance for the genes/features to be retained.
#' @return Matrix or data frame with the same format as the input dataset.
#' @export
#' @author Zhicheng Ji, Hongkai Ji <zji4@@zji4.edu>
#' @examples
#' data(lpsdata)
#' procdata <- preprocess(lpsdata)

preprocess <- function(data, clusternum = NULL,takelog = TRUE, logbase = 2, pseudocount = 1, minexpr_value = 1, minexpr_percent = 0.5, cvcutoff = 1) {
      if (takelog) {
            data <- log(data + pseudocount) / log(logbase)
      }
      data <- data[rowMeans(data > minexpr_value) > minexpr_percent & apply(data,1,sd)/rowMeans(data) > cvcutoff, ]
      if (!is.null(clusternum)) {
            cname <- colnames(data)
            clures <- hclust(dist(data))
            cluster <- cutree(clures,clusternum)
            aggdata <- aggregate(data,list(cluster),mean)
            data <- as.matrix(aggdata[,-1])
            colnames(data) <- cname
      }
      data
}
