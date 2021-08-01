#!/bin/bash

swiftlint

swiftformat . --lint

swift test --sanitize address
swift test --sanitize thread
swift test --sanitize undefined
