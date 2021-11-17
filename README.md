# Excv

Excv (Elixir Computer Vision) is a bridge between OpenCV and Nx.

## Installation

In order to use `Excv`, you will need Elixir, OpenCV, and `pkg-config` installed. 
Then create an Elixir project via the `mix` build tool:

```
$ mix new my_app
```

Then you can add `Excv` as dependency in your `mix.exs`. At the moment you will have to use a Git dependency while we work on our first release:

```elixir
def deps do
  [
    {:excv, "~> 0.1.0-dev", github: "zeam-vm/excv", branch: "main"}
  ]
end
```

## License

Copyright (c) 2021 Susumu Yamazaki

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Acknowledgement

This research is supported by Adaptable and Seamless Technology transfer
Program through Target-driven R&D (A-STEP) from Japan Science and Technology
Agency (JST) Grant Number JPMJTM20H1.
