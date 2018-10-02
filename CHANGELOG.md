# Change Log
All notable changes to this project will be documented in this file.  
This project adheres to [Semantic Versioning](http://semver.org/).

## UNRELEASED
### Fixed
- Restore compatibility with Rails 3

## [1.2.2] - 2018-01-15
### Fixed
- Circular reference load warning on errors

## [1.2.1] - 2017-12-20
### Changed
- ST validation requests http method has been changed from POST to GET

## [1.1.5] - 2017-12-20
### Changed
- ST validation requests http method has been changed from POST to GET

## [1.2.0] - 2017-08-10
### Changed
- Remove runtime dependency on active_support
- Remove runtime dependency on libxml-ruby (native)

## [1.1.4] - 2017-07-03
### Fixed
- Fixed deprecated method before_filter for Rails 5 applications

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
