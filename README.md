# CoreML per-op profiling with Swift

See https://github.com/freedomtan/coreml_modelc_profling/, for how this works.

Apple's official API for doing per-op profiling is to use [MLComputePlan](https://developer.apple.com/documentation/coreml/mlcomputeplan-85vdw?language=objc), which reports relative time usage only. Sometimes that is not enough. It would be nice if we can do something like [deCoreML](https://github.com/FL33TW00D/deCoreML) from @FL33TW00D on iPhone/iPad.

## screenshot
|analitics.mil|simple csv|
|---|---|
|<img src="https://github.com/user-attachments/assets/4bf2c135-3142-479a-9ac5-6162145cb6d7"  width="200" />|<img src="https://github.com/user-attachments/assets/b171862c-c83e-4863-b80a-ef07ee30be8a" width="200" />|
