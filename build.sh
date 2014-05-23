#!/bin/bash

function get-dart-dependencies {
	echo "get-dart-dependencies"
	pub get || { echo 'get-dart-dependencies failed' ; exit 1; }
}

function test-dart-sources {
	echo "test-dart-sources"
	dart test/trace_tests.dart || { echo 'test-dart-sources failed' ; exit 1; }
}


get-dart-dependencies 
test-dart-sources

pub publish --force
