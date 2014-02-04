# Overview

For instructions on upgrading to newer versions, visit
[mongoid.org](http://mongoid.org/en/mongoid/docs/upgrading.html).

## 1.0.0

### Major Changes (Backwards Incompatible)

* Rename `#with` and `#use` to `#with_tenant` and `#use_tenant` because it conflicts with mongoid.
* Replace `#without_scope` to `#tenant_scope`.
* Support Mongoid 3/4.

## 0.2.0

* Add [request_store](https://github.com/steveklabnik/request_store) as dependency.
* Add `#without_scope`.
* Support ActiveRecord 4.

## 0.1.0

* First Release
* Support ActiveRecord 3.
* Add `tenany/matchers`.