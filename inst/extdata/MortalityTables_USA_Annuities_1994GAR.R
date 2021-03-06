stopifnot(require(methods), require(utils), require(MortalityTables))

###############################################################################
### 1994 GAR/GAM group annuity tables, with improvement factors AA_x
###############################################################################

USA1994GAM.data = utils::read.csv(
    system.file("extdata",
                "USA_Annuities_1994GAR.csv",
                package = "MortalityTables"),
    col.names = c("age","qx", "AAx", "qy", "AAy", "qxBasic", "qyBasic"),
    skip = 3)

USA1994GAM.male.basic = mortalityTable.period (
    name = "USA 1994 GAM basic (unloaded), male",
    ages = USA1994GAM.data$age,
    deathProbs = USA1994GAM.data$qxBasic)

USA1994GAM.female.basic = mortalityTable.period (
    name = "USA 1994 GAM basic (unloaded), female",
    ages = USA1994GAM.data$age,
    deathProbs = USA1994GAM.data$qyBasic)


USA1994GAR.male = mortalityTable.improvementFactors (
    name = "USA 1994 GAR, male",
    ages = USA1994GAM.data$age,
    deathProbs = USA1994GAM.data$qx,
    improvement = USA1994GAM.data$AAx)

USA1994GAR.female = mortalityTable.improvementFactors (
    name = "USA 1994 GAR, female",
    ages = USA1994GAM.data$age,
    deathProbs = USA1994GAM.data$qy,
    improvement = USA1994GAM.data$AAy)

rm(USA1994GAM.data)

# plot(USA1994GAM.male.basic, USA1994GAR.male, Period = 1994)

