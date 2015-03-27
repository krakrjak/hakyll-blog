---
title: Speed Metrics for Nofib and GHC
date: 2015-03-27
---

# Homeowner Complaints
+ Gotta Run them All
+ Numbers are back of the envelope at best
+ Reproducibility Concerns


# Foundation and Facing Uplift

Lean on existing build system.  Create `nofibs-runner` application front end to run tests.  Tests could be run individually, as a suite or as an entire collection.  This test runner application would allow for a unified interface into the benchmarking suite as a whole.  Instead of modifying build files, flags would be passed to `nofibs-runner`.
