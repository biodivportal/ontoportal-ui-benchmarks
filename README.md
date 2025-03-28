## Context
This is a script to run benchmarks on the OntoPortal API. It will run a series of queries and measure the time it takes to get a response.
For now it checks:
- homepage
- browse page
- take a sample of 10 ontologies and get their summary page
- take a sample of 10 ontologies and get their classes page

## Results
See the CSV files in this repository.
And summary [here](https://docs.google.com/spreadsheets/d/1OiXE29O3WtGsFkW5kDvcfE-8cAtO82SnRnNKkPiB5-c)

## How to use
```bash
bundle exec ruby main.rb -u <ontoportal api url> -k <apikey> --output-name <name of csv to generate>
```
