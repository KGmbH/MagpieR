# magpieR

Generate JavaScript code for magpie experiments with automatic Latin square counterbalancing.

## Installation

```r
devtools::install_github("KGmbH/magpieR")
```

## What it does

This package takes your experimental items and automatically:

1. Generates Latin square designs for perfect counterbalancing
2. Rotates items across conditions according to the Latin square
3. Formats everything as clean JavaScript code for magpie experiments
4. Validates your experimental design to catch errors
5. Saves output to files ready for use

No more manual Latin square creation, rotation logic, or JavaScript formatting.

## Why use this package?

**Before magpieR:**
```r
# Manual Latin square creation (error-prone!)
latin_square <- matrix(c(1,2,3,4, 2,3,4,1, 3,4,1,2, 4,1,2,3), nrow=4, byrow=TRUE)

# Manual assignment logic
exp_lists <- vector("list", 4)
for(list_num in 1:4) {
  exp_lists[[list_num]] <- vector("character", 24)
}

# Manual rotation and formatting... 50+ lines of repetitive code
```

**With magpieR:**
```r
# One simple function call
generate_magpie_experiment(items = my_items, conditions = 4)
```

## Basic usage

```r
library(magpieR)

# Define your items
items <- list(
  item1 = c("Condition A", "Condition B", "Condition C", "Condition D"),
  item2 = c("Test A", "Test B", "Test C", "Test D")
)

# Generate JavaScript
result <- generate_magpie_experiment(
  items = items,
  conditions = 4,
  output_file = "custom_functions.js"
)
```

## Real example

```r
# Psycholinguistic experiment
item1 <- c(
  "The angry professor keeps interrupting during the meeting!",
  "The rude professor keeps interrupting during the meeting!",
  "The angry student keeps interrupting during the meeting!",
  "The rude student keeps interrupting during the meeting!"
)

item2 <- c(
  "The aggressive manager speaks over everyone in meetings!",
  "The impatient manager speaks over everyone in meetings!",
  "The aggressive intern speaks over everyone in meetings!",
  "The impatient intern speaks over everyone in meetings!"
)

items <- list(item1 = item1, item2 = item2)

result <- generate_magpie_experiment(
  items = items,
  conditions = 4,
  output_file = "my_experiment.js"
)
```

This automatically creates perfect counterbalancing:

```
Generated Latin Square Design:
List A: 1 2 3 4
List B: 2 3 4 1  
List C: 3 4 1 2
List D: 4 1 2 3
```

Each condition appears exactly once in each list and each position across lists.

## JavaScript output

The package generates JavaScript like this:

```javascript
var syn = {
  "Item1" : {
    "A" : "The angry professor keeps interrupting during the meeting!",
    "B" : "The rude professor keeps interrupting during the meeting!",
    "C" : "The angry student keeps interrupting during the meeting!",
    "D" : "The rude student keeps interrupting during the meeting!"
  },
  "Item2" : {
    "A" : "The impatient manager speaks over everyone in meetings!",
    "B" : "The aggressive intern speaks over everyone in meetings!",
    "C" : "The impatient intern speaks over everyone in meetings!",
    "D" : "The aggressive manager speaks over everyone in meetings!"
  }
};
```

Note how Item2 is automatically rotated according to the Latin square.

## Functions

### generate_magpie_experiment()

Main function that does everything automatically.

```r
generate_magpie_experiment(
  items,                    # Your experimental items (required)
  conditions,               # Number of conditions (required)  
  variable_name = "syn",    # JavaScript variable name
  output_file = NULL        # Save to file (optional)
)
```

**Arguments:**
- **items**: Named list where each element contains condition variants (required)
- **conditions**: Number of conditions - creates NxN Latin square automatically (required)  
- **variable_name**: Name of the JavaScript variable in output (default: "syn")
- **output_file**: File path to save JavaScript output (optional)

**Returns:** JavaScript code as character string

**Examples:**

```r
# Basic usage
result <- generate_magpie_experiment(items = items, conditions = 4)

# With custom variable name and file output
result <- generate_magpie_experiment(
  items = items,
  conditions = 4,
  variable_name = "stimuli",
  output_file = "my_experiment.js"
)
```

### create_latin_square()

Helper function for advanced users who want to inspect Latin square designs.

```r
create_latin_square(
  conditions,               # Number of conditions (required)
  lists = conditions        # Number of lists (optional)
)
```

**Arguments:**
- **conditions**: Number of conditions (required)
- **lists**: Number of lists - defaults to square design (optional)

**Returns:** Matrix representing the Latin square design

**Examples:**

```r
# Standard 4x4 Latin square
latin_4x4 <- create_latin_square(4)

# Non-square design: 6 lists, 4 conditions  
latin_6x4 <- create_latin_square(conditions = 4, lists = 6)
```

## Input format

Items must be provided as a named list where:
- Each element represents one experimental item
- Each element contains a vector of condition variants
- All items must have the same number of conditions

```r
# Correct format
items <- list(
  item1 = c("Condition 1", "Condition 2", "Condition 3", "Condition 4"),
  item2 = c("Test 1", "Test 2", "Test 3", "Test 4"),
  item3 = c("Sample 1", "Sample 2", "Sample 3", "Sample 4")
)
```

## Different Latin square sizes

The package works with any number of conditions:

```r
# 3x3 Latin square
items_3 <- list(
  item1 = c("Condition A", "Condition B", "Condition C"),
  item2 = c("Test A", "Test B", "Test C")
)

result <- generate_magpie_experiment(items = items_3, conditions = 3)
```

```r
# 2x2 Latin square
items_2 <- list(
  item1 = c("Version A", "Version B"),
  item2 = c("Test A", "Test B")
)

result <- generate_magpie_experiment(items = items_2, conditions = 2)
```

## Large-scale experiments

```r
# Create 24 items automatically (typical for psycholinguistic experiments)
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
```

## Error handling

The package validates your input and provides helpful error messages:

```r
# This produces a clear error message
bad_items <- list(
  item1 = c("Only", "Two"),           # 2 conditions
  item2 = c("Four", "Different", "Conditions", "Here")  # 4 conditions
)

generate_magpie_experiment(items = bad_items, conditions = 4)
# Error: Item 1 has 2 conditions, but expected 4
```

## Advanced usage

### Custom variable names

```r
result <- generate_magpie_experiment(
  items = items,
  conditions = 4,
  variable_name = "my_stimuli",
  output_file = "experiment.js"
)
```

This creates JavaScript with `var my_stimuli = {...}` instead of `var syn = {...}`

### Inspecting Latin squares

```r
# See the Latin square design before applying it
my_design <- create_latin_square(4)
print(my_design)

# Then use with your items
result <- generate_magpie_experiment(items = items, conditions = 4)
```

## Using in magpie experiments

Include the generated JavaScript file in your magpie experiment. The items will be available as:

```javascript
// Access items in your magpie experiment
syn.Item1[coin]  // where 'coin' determines the list (A, B, C, or D)
syn.Item2[coin]
// etc.
```

## Typical workflow

1. Define all experimental items with their condition variants
2. Combine into a named list
3. Run generate_magpie_experiment() with desired number of conditions
4. Use the generated JavaScript file in your magpie experiment

## Requirements

- R (>= 3.5.0)
- devtools package (for installation)

No other dependencies. Uses only base R functions.

## License

MIT
