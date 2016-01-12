Client Tools Omnibus project (Deprecated)
============================

DO NOT SUBMIT PATCHES OR CONTRIBUTE TO THIS REPOSITORY.

The omnibus project definitions for Chef, ChefDK and Push Jobs client used to
live in this repo. They have now been migrated into their primary git
repositories under an `omnibus` directory.

* (Chef Client omnibus directory)[https://github.com/chef/chef/tree/master/omnibus]
* (ChefDK omnibus directory)[https://github.com/chef/chef-dk/tree/master/omnibus]
* (Push Jobs Client omnibus directory)[https://github.com/chef/opscode-pushy-client/tree/master/omnibus]

Jenkins test scripts were moved into a corresponding `ci` directory under each
project.

* (Chef Client ci directory)[https://github.com/chef/chef/tree/master/ci]
* (ChefDK ci directory)[https://github.com/chef/chef-dk/tree/master/ci]

All common software definitions were moved into the
(omnibus-software)[https://github.com/chef/omnibus-software] git repository.

This repository has been left here to support legacy chef-11 builds and other
historical builds.

License
-------
```text
Copyright 2012-2014 Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
