# Localmotive

A macOS tool for easy modification and management of localizable strings files.

### Features

For a given set of strings files:

- View a list of all string keys
- View a list of localized strings for each string key
- Search for strings and string keys
- Add, Edit and Remove strings and string keys all in one place
- Add new localizations for different languages
- Generate a Swift class for easy compiler checked access to the localized strings in swift projects

### Expected File Structure

In order for Localmotive to recognize a set of strings files, each strings file must be located in the file structure using the following format:

`{containing-directory}/{language-code}.lproj/{strings-file-name}.strings`

To open a set of strings files, simply open one of them, and Localmotive will find the rest.

### Notes about the generated Swift class

- For each string key, a static property, named the same as the string key, is added to the class that returns the localized string.
- Only string keys that are valid Swift identifiers are added to this class.
- If a string key has a localized string that contains a `%@`, a class method will instead be created that takes a list of string arguments and substitutes each `%@` in the localized string.
