magpieR Package Documentation
Overview
magpieR is an R package for generating JavaScript code for magpie experiments. It automates the creation of Latin square designs, applies counterbalancing rotation to experimental items, and outputs properly formatted JavaScript files for use in magpie experiments.
What This Package Does
The package takes your experimental items (with multiple conditions per item) and automatically:

Generates Latin Square Designs - Creates balanced experimental designs where each condition appears equally across lists
Applies Counterbalancing - Rotates items across conditions according to the Latin square
Formats for Magpie - Outputs clean JavaScript code ready for magpie experiments
Handles File Output - Saves formatted JavaScript to files for direct use

Installation
Local Installation (No GitHub Required)
r# Install development tools if you haven't already
install.packages("devtools")

# Install your local package
devtools::install()  # Run this in your magpieR project folder
Installing from Package File
r# If someone gives you the package file
devtools::install("path/to/magpieR")

# Or from a .tar.gz file
install.packages("path/to/magpieR_0.1.0.tar.gz", repos = NULL, type = "source")
Quick Start
rlibrary(magpieR)

# Define your experimental items
item1 <- c("Condition A", "Condition B", "Condition C", "Condition D")
item2 <- c("Test A", "Test B", "Test C", "Test D")
items <- list(item1 = item1, item2 = item2)

# Generate magpie experiment
result <- generate_magpie_experiment(
  items = items,
  conditions = 4,
  output_file = "custom_functions.js"
)
Functions
generate_magpie_experiment()
Main function - Generates complete magpie experiment JavaScript with automatic Latin square counterbalancing.
Arguments
ArgumentTypeDefaultDescriptionitemsnamed listrequiredList of experimental items, where each element contains condition variantsconditionsintegerrequiredNumber of conditions (creates NxN Latin square automatically)variable_namecharacter"syn"Name of the JavaScript variable in outputoutput_filecharacterNULLOptional file path to save JavaScript output
Returns

Character string containing formatted JavaScript code
Side effects: Prints Latin square design and summary to console
File output: Saves JavaScript to file if output_file specified

Examples
r# Basic usage
items <- list(
  item1 = c("Version A", "Version B", "Version C", "Version D"),
  item2 = c("Test A", "Test B", "Test C", "Test D")
)

result <- generate_magpie_experiment(items = items, conditions = 4)

# With custom variable name and file output
result <- generate_magpie_experiment(
  items = items,
  conditions = 4,
  variable_name = "stimuli",
  output_file = "my_experiment.js"
)

# 3x3 Latin square design
items_3 <- list(
  item1 = c("Condition A", "Condition B", "Condition C"),
  item2 = c("Test A", "Test B", "Test C")
)

result <- generate_magpie_experiment(items = items_3, conditions = 3)
create_latin_square()
Helper function - Creates Latin square designs for advanced users who want to inspect or modify the design before applying it.
Arguments
ArgumentTypeDefaultDescriptionconditionsintegerrequiredNumber of conditionslistsintegerconditionsNumber of lists (defaults to square design)
Returns

Matrix representing the Latin square design

Examples
r# Standard 4x4 Latin square
latin_4x4 <- create_latin_square(4)

# Non-square design: 6 lists, 4 conditions  
latin_6x4 <- create_latin_square(conditions = 4, lists = 6)
Input Format
Items Structure
Items must be provided as a named list where:

Each element represents one experimental item
Each element contains a vector of condition variants
All items must have the same number of conditions

r# Correct format
items <- list(
  item1 = c("Condition 1", "Condition 2", "Condition 3", "Condition 4"),
  item2 = c("Test 1", "Test 2", "Test 3", "Test 4"),
  item3 = c("Sample 1", "Sample 2", "Sample 3", "Sample 4")
)

# Each item has exactly 4 conditions
Real-World Example
r# Typical psycholinguistic experiment
item1 <- c(
  "The [slur] Mia keeps interrupting during the faculty meeting!",
  "The [neutral] Mia keeps interrupting during the faculty meeting!",
  "The [slur] Nathan keeps interrupting during the faculty meeting!",
  "The [neutral] Nathan keeps interrupting during the faculty meeting!"
)

item2 <- c(
  "The [slur] Emma always speaks over everyone in team meetings!",
  "The [neutral] Emma always speaks over everyone in team meetings!",
  "The [slur] Marcus always speaks over everyone in team meetings!",
  "The [neutral] Marcus always speaks over everyone in team meetings!"
)

items <- list(item1 = item1, item2 = item2)

result <- generate_magpie_experiment(items = items, conditions = 4)
Output Format
JavaScript Structure
The package generates JavaScript in this format:
javascriptvar syn = {
  "Item1" : {
    "A" : "Condition 1 text for Item1",
    "B" : "Condition 2 text for Item1", 
    "C" : "Condition 3 text for Item1",
    "D" : "Condition 4 text for Item1"
  },
  "Item2" : {
    "A" : "Condition 2 text for Item2",  // Note: rotated!
    "B" : "Condition 3 text for Item2",
    "C" : "Condition 4 text for Item2", 
    "D" : "Condition 1 text for Item2"
  }
};
Latin Square Counterbalancing
The package automatically applies Latin square counterbalancing:
Generated Latin Square Design:
List A: 1 2 3 4
List B: 2 3 4 1  
List C: 3 4 1 2
List D: 4 1 2 3
This ensures:

Each condition appears exactly once in each list
Each condition appears in each position across lists
Perfect counterbalancing for between-subjects designs

Typical Workflow
1. Prepare Your Items
r# Define all experimental items
item1 <- c("Condition 1", "Condition 2", "Condition 3", "Condition 4")
item2 <- c("Test 1", "Test 2", "Test 3", "Test 4")
# ... add more items

# Combine into list
all_items <- list(
  item1 = item1,
  item2 = item2
  # ... add all items
)
2. Generate Experiment
rlibrary(magpieR)

result <- generate_magpie_experiment(
  items = all_items,
  conditions = 4,
  output_file = "custom_functions.js"
)
3. Use in Magpie
Include the generated custom_functions.js file in your magpie experiment. The items will be available as:
javascript// Access items in your magpie experiment
syn.Item1[coin]  // where 'coin' determines the list (A, B, C, or D)
syn.Item2[coin]
// etc.
Error Handling
The package includes validation to catch common errors:
r# This will produce an error - mismatched conditions
bad_items <- list(
  item1 = c("Only", "Two", "Conditions"),      # 2 conditions
  item2 = c("Four", "Different", "Conditions", "Here")  # 4 conditions  
)

generate_magpie_experiment(items = bad_items, conditions = 4)
# Error: Item 1 has 2 conditions, but expected 4
Advanced Usage
Large-Scale Experiments
r# For experiments with many items (e.g., 24 items)
large_items <- list()
for(i in 1:24) {
  large_items[[paste0("item", i)]] <- c(
    paste("Condition 1 for item", i),
    paste("Condition 2 for item", i),
    paste("Condition 3 for item", i), 
    paste("Condition 4 for item", i)
  )
}

result <- generate_magpie_experiment(
  items = large_items,
  conditions = 4,
  output_file = "large_experiment.js"
)
Non-Square Designs
r# Use custom Latin squares for non-square designs
latin_custom <- create_latin_square(conditions = 3, lists = 6)

# Then use with generate_magpie_experiment()
# (Note: Currently requires manual implementation for non-square designs)
Package Information

Version: 0.1.0
License: MIT
Dependencies: Base R only
Year: 2025
