# GHGfromFADN: GHG emissions from FADN data

## Table of contents
* [General infos](#general-infos)
* [Technology](#technology)
* [Intallation](#installation)
* [GHG emissions equations](#ghg-emissions-equations)

## General infos

GHGfromFADN is an R library to estimate GHG emissions from the main productions of the FADN data (Farm Accountancy Data Network). 

Emissions are expressed in kgCO2eq for each production at the farm level. For now, only main field crop productions and no animal products are included. 

## Technology

This R package was built using R 4.1.1 and depends on R >= 3.5.0

## Installation

**Step 1: Install the devtools package**

`install.packages("devtools")`

**Step 2: Install GHGfromFADN**

`library(devtools)`

`install_github("sarahkleclerc/GHGfromFADN")`

**Step 2: Load GHGfromFADN**

`library(GHGfromFADN)`

## GHG emissions equations

Greenhouse gas emissions are estimated based on IPCC tiers 1 guidelines and emission factors (2006 and 2019 refinements) for most of the emission sources as described in Table 1. The system boundaries are cradle to farm gate: feed production and farming operations are included. Table 1 describes the emission sources included in our estimator for crops. We should add emission sources for animals as well. Most of our data is only available at the farm level and we are interested in the impact at the individual product level. Following LCA principles, we estimate emissions at product level whenever possible (eg. emissions from crop residues are attributed to the relevant crop, emissions from heating are attributed to the relevant animals). For sources of emissions for which an estimate is only possible at a higher level (eg. fertilizers, tractor fuels), the impacts are allocated to the relevant products in proportion to their economic value (International Reference Life Cycle Data System (ILCD) Handbook: General guide for Life Cycle Assessmen, 2010).


| Emission sources                 | FADN data             | IPCC equations    | Emission factor sources            |
|----------------------------------|-----------------------|-------------------|------------------------------------|
| *Direct*                         |                       |                   |                                    |
| Use of synthetic fertilisers     | N fertilisers         | Equation 11.1 *   | IPCC 2019, table 2A.2              |
| Crop residues management         | Crop area, production | Equation 11.1 *   | Tables 11.1, 11.2, 11.3 *          |
| *Indirect*                       |                       |                   |                                    |
| Atmospheric deposition           | N fertilisers         | Equation 11.9 *   | Table 11.3 *                       |
| Leaching and run-off             | N fertilisers         | Equation 11.10 *  | Table 11.3 *                       |
| Synthetic fertilisers production | N fertilisers         |                   | Carbon Footprint Calculator (2018) |
| Energy use (inc. production)     | Fuel                  | Equation 3.3.1 ** | Table 3.3.1 **                     |

&#42; IPCC 2006, vol. 4
&#42; &#42; IPCC 2006, vol. 2
