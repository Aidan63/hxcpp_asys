package utils;

import utest.Async;

interface IWritableTests {
    function test_writing(async:Async):Void;
    function test_writing_null_callback(async:Async):Void;
    function test_writing_null_buffer(async:Async):Void;
    function test_writing_negative_offset(async:Async):Void;
    function test_writing_large_offset(async:Async):Void;
    function test_writing_negative_length(async:Async):Void;
    function test_writing_invalid_range_due_to_large_length(async:Async):Void;
    function test_writing_invalid_range_due_to_offset(async:Async):Void;
}