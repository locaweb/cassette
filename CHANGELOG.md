# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.3] - 2016-05-13
## Changed
- Memoizes Faraday instances to keep the number of file descriptors down

## [1.1.2] - 2016-04-28
### Fixed
- Fixed an issue with sessions and RubyCAS helper

## [1.1.1] - 2016-04-15
### Fixed
- Fixed a `NoMethodError` caused by refactoring

## [1.1.0] - 2016-04-14
### Added
- added support to allow multiple services (see README and #10)
- added a role-checking routing contraint (see README and #7)

### Changed
- a lot more specs
- better separation of concerns, see #14

## [1.0.18] - 2015-08-25
### Fixed
- Fixed a bug regarding TGT caching, see #11

## [1.0.17] - 2015-06-26

Initial release.
