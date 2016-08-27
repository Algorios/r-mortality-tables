#' @include valuationTable.R valuationTable.period.R valuationTable.ageShift.R valuationTable.trendProjection.R valuationTable.improvementFactors.R valuationTable.mixed.R
NULL

#' Return the (cohort) death probabilities of the life table given the birth year (if needed)
#'
#' @param object The life table object (class inherited from valuationTable)
#' @param ... Other parameters (currently unused)
#' @param YOB The birth year for which the death probabilities should be calculated
#'
#' @exportMethod deathProbabilities
setGeneric("deathProbabilities", function(object, ..., YOB = 1975) standardGeneric("deathProbabilities"));

#' @describeIn deathProbabilities Return the (cohort) death probabilities of the
#'                                life table given the birth year (if needed)
setMethod("deathProbabilities", "valuationTable.period",
          function(object, ..., YOB = 1975) {
              object@modification(object@deathProbs * (1 + object@loading));
          })

#' @describeIn deathProbabilities Return the (cohort) death probabilities of the
#'                                life table given the birth year (if needed)
setMethod("deathProbabilities","valuationTable.ageShift",
          function (object,  ..., YOB = 1975) {
              qx=object@deathProbs * (1 + object@loading);
              shift = ageShift(object, YOB);
              if (shift>0) {
                  qx = c(qx[(shift+1):length(qx)], rep(qx[length(qx)], shift));
              } else if (shift<0) {
                  qx = c(rep(0, -shift), qx[1:(length(qx)-(-shift))])
              }
              object@modification(qx)
          })

#' @describeIn deathProbabilities Return the (cohort) death probabilities of the
#'                                life table given the birth year (if needed)
setMethod("deathProbabilities","valuationTable.trendProjection",
          function (object,  ..., YOB = 1975) {
              qx=object@deathProbs * (1 + object@loading);
              if (is.null(object@trend2) || length(object@trend2) <= 1) {
                  ages = 0:(length(qx)-1);
                  damping = sapply(
                      ages,
                      function (age) { object@dampingFunction(YOB + age - object@baseYear) }
                  );
                  finalqx = exp(-object@trend * damping) * qx;
              } else {
                  # dampingFunction interpolates between the two trends:
                  weights = sapply(YOB + 0:(length(qx)-1), object@dampingFunction);
                  finalqx = qx * exp(
                      -(object@trend * (1 - weights) + object@trend2 * weights) *
                          (YOB + 0:(length(qx)-1) - object@baseYear))
              }
              object@modification(finalqx)
          })

#' @describeIn deathProbabilities Return the (cohort) death probabilities of the
#'                                life table given the birth year (if needed)
setMethod("deathProbabilities","valuationTable.improvementFactors",
          function (object,  ..., YOB = 1975) {
              qx = object@deathProbs * (1 + object@loading);
              finalqx = (1 - object@improvement)^(YOB + 0:(length(qx) - 1) - object@baseYear) * qx;
              object@modification(finalqx)
          })

#' @describeIn deathProbabilities Return the (cohort) death probabilities of the
#'                                life table given the birth year (if needed)
setMethod("deathProbabilities","valuationTable.mixed",
          function (object,  ..., YOB = 1975) {
              qx1 = deathProbabilities(object@table1, ..., YOB) * (1 + object@loading);
              qx2 = deathProbabilities(object@table2, ..., YOB) * (1 + object@loading);
              mixedqx = (object@weight1 * qx1 + object@weight2 * qx2)/(object@weight1 + object@weight2);
              object@modification(mixedqx)
          })
