package utils;

import utest.Async;

interface IReadableTests {
    function test_reading(async:Async):Void;
    function test_reading_null_callback(async:Async):Void;
    function test_reading_null_buffer(async:Async):Void;
    function test_reading_negative_offset(async:Async):Void;
    function test_reading_large_offset(async:Async):Void;
    function test_reading_negative_length(async:Async):Void;
    function test_reading_invalid_range_due_to_large_length(async:Async):Void;
    function test_reading_invalid_range_due_to_offset(async:Async):Void;
}