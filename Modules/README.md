# Modules

Our project is made of multiple frameworks - or Modules, as we call them - and are not to be confused with Git Submodule modules. All Modules are stored within the `Modules` directory, grouped by "feature" or by "horizontal" function. Each Module "group" has a `README` file explaining the purpose of the Module and its API.

# Notes

Module `ComposableArchitectureKit` exists so that our `Modules` can access the `ComposableArchitecture` framework which is linked via SPM.
