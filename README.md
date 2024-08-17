# CoreML per-op profiling with Swift

See https://github.com/freedomtan/coreml_modelc_profling/, for how this works.

Apple's official API for doing per-op profiling is to use [MLComputePlan](https://developer.apple.com/documentation/coreml/mlcomputeplan-85vdw?language=objc), which reports relative time usage only. Sometimes that is not enough. It would be nice if we can do something like [deCoreML](https://github.com/FL33TW00D/deCoreML) from @FL33TW00D on iPhone/iPad.
