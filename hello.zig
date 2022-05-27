// To compile, run `zig build-lib -target wasm32-freestanding -O ReleaseSmall --strip -fsingle-threaded -dynamic hello.zig`
//                 where `-target` specifies that we want 32-bit WebAssembly and our code doesn't depend on any OS,
//                 `-O ReleaseSmall` optimizes for small size,
//                 `--strip` omits debug symbols,
//                 `-fsingle-threaded` specifies that our code is single-threaded,
//                 `-dynamic` specifies that we want to dynamically link to get a Wasm binary

const std = @import("std");

/// This is a binding to the function we supply in JavaScript that returns
/// an exclamation mark, for demonstration purposes.
extern fn getExclamationMark() u8;

/// Reads a greetee string from memory and returns an address
/// to a greeting.
///
/// Two observations:
/// - wasm32 does not support returning more than 32 bits
///   which means returning the resulting string as e.g.
///   `extern struct { ptr: [*]u8, len: usize }` is not possible
///   because the size of that `struct` is 64 bits.
/// - Trying to take references to result's pointer and length
///   as parameters is not possible either because
///   JavaScript does not support references to values in this way.
///
/// Because of that I chose to zero-terminate the resulting string
/// and return the address to that.
/// There are other ways to solve this too.
export fn hello(
    greetee_pointer: [*]const u8,
    greetee_length: usize,
) ?[*:0]const u8 {
    const allocator = std.heap.page_allocator;
    const greetee = greetee_pointer[0..greetee_length];
    const exclamation_mark = getExclamationMark();

    // Allocate memory for a new string, format the string,
    // and store it in the Wasm module's memory.
    return std.fmt.allocPrintZ(
        allocator,
        "hello {s}{c}",
        .{greetee, exclamation_mark},
    ) catch null;
}
