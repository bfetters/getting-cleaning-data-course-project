# Getting And Cleaning Data - Course Project

## Introduction

This is the final project for the Getting and Cleaning Data course as part of the Data Science Specialization on Coursera.

The purpose of this project is to demonstrate an ability to collect, work with, and clean a data set that can be used for later analysis.

## Usage

The `run_analysis.R` script will perform the following tasks:

1. [UCI HAR Dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
2. Merge all relevant data files into single dataset
3. Transform data by getting average of each variable for each activity and subject
4. Write newly transformed data to output file name `uci_har_tidy.txt`

To run: `Rscipt run_analysis.R`
