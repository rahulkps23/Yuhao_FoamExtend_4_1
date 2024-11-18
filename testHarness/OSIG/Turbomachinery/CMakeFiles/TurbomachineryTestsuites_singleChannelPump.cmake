# /*---------------------------------------------------------------------------*\
#   =========                 |
#   \\      /  F ield         | foam-extend: Open Source CFD
#    \\    /   O peration     |
#     \\  /    A nd           | For copyright notice see file Copyright
#      \\/     M anipulation  |
# -------------------------------------------------------------------------------
# License
#     This file is part of foam-extend.
#
#     foam-extend is free software: you can redistribute it and/or modify it
#     under the terms of the GNU General Public License as published by the
#     Free Software Foundation, either version 3 of the License, or (at your
#     option) any later version.
#
#     foam-extend is distributed in the hope that it will be useful, but
#     WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with foam-extend.  If not, see <http://www.gnu.org/licenses/>.
#
# Description
#        CMake/CTest script for running the Turbomachinery OSIG testsuites
#        for the Single Channel Pump
#
# Author
#        Martin Beaudoin, Hydro-Quebec, 2010. All rights reserved
#
# \*---------------------------------------------------------------------------*/

# Take care of tests specific variables
IF(NOT DEFINED testIdSuffix)
    SET(testIdSuffix "_full")
ENDIF(NOT DEFINED testIdSuffix)

SET(testRunTimeDirectory "TurbomachineryTestSuites${testIdSuffix}/singleChannelPump")

# Use the current directory for running the test cases
SET (TEST_CASE_DIR $ENV{PWD}/${testRunTimeDirectory}
    CACHE INTERNAL "Single Channel Pump test case directory."
    )

# Create the runTime test cases
MESSAGE("Removing the old test directory: ${TEST_CASE_DIR}")
file(REMOVE_RECURSE ${TEST_CASE_DIR})
MESSAGE("Creation of the new test directory: ${TEST_CASE_DIR}")
file(COPY ${TURBOMACHINERY_OSIG_ROOT}/singleChannelPump DESTINATION ${TEST_CASE_DIR}/..)

# Iterate over each case:
# We are looking for a tutorial with an Allrun case.
# If this file is present, we add this case to the list of cases to run.
#

# Subdirectory for the test cases
SET(TESTCASES_SUBDIR "Pump")

# No need for a global Allclean script, we will invoke the Allclean command before each
# Allrun.* file
#SET(testId "SCP_Allclean_cases${testIdSuffix}")
#ADD_TEST(${testId} bash -c "cd ${TEST_CASE_DIR}/${TESTCASES_SUBDIR}; ./Allclean")

# Next, recurse through the case root directory,
# find all the Allrun files, and execute them
FILE(GLOB_RECURSE listofCasesWithAllrun ${TEST_CASE_DIR}/${TESTCASES_SUBDIR}/Allrun.*)
LIST(SORT listofCasesWithAllrun)

FOREACH(caseWithAllrun ${listofCasesWithAllrun})
  #Grab the name of the directory containing the file Allrun
  get_filename_component(thisCasePath ${caseWithAllrun} PATH)
  get_filename_component(thisCaseAllrunName ${caseWithAllrun} NAME)

  # We need to skip the global Allrun file
  IF(NOT ${thisCasePath} MATCHES ${TEST_CASE_DIR}/${TESTCASES_SUBDIR}/.svn*)
    MESSAGE("Found Allrun file in directory: ${thisCasePath}")

    # Grab the parent name of the case directory
    string(REPLACE ${TEST_CASE_DIR}/ "" caseParentPath ${caseWithAllrun})

    # Construct the testId
    string(REPLACE "/" "_" testId ${caseParentPath})
    SET(testId SCP_${testId}${testIdSuffix})

    # Add the test to the test harness
    MESSAGE("Adding test: ${testId}")
    ADD_TEST(${testId} bash -c "cd ${thisCasePath}; ./Allclean; ./${thisCaseAllrunName}")
    # Use this entry instead for testing
    #ADD_TEST(${testId} bash -c "cd ${thisCasePath}; true")

  ENDIF(NOT ${thisCasePath} MATCHES ${TEST_CASE_DIR}/${TESTCASES_SUBDIR}/.svn*)
ENDFOREACH(caseWithAllrun)

# Modify the cases Allrun file for additional shell functions
MESSAGE("${testRunTimeDirectory}: Modifying the Allrun files for additional shell functions in directory: ${TEST_CASE_DIR}/${TESTCASES_SUBDIR}")
EXECUTE_PROCESS(
    COMMAND $ENV{FOAM_TEST_HARNESS_DIR}/scripts/prepareCasesForTestHarness.sh ${TEST_CASE_DIR}/${TESTCASES_SUBDIR} $ENV{FOAM_TEST_HARNESS_DIR}/scripts/AdditionalRunFunctions
    WORKING_DIRECTORY .
    )

# That's it.
#
