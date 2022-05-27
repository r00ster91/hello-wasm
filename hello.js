const fs = require("fs");
const wasmSource = fs.readFileSync("hello.wasm");

WebAssembly.instantiate(new Uint8Array(wasmSource), {
    env: {
        // This exports the function to our Wasm module
        getExclamationMark: () => '!'.codePointAt(0)
    }
}).then(result => {
    const greetee = {
        content: "world",
        length: 5,
        address: 0, // The address that we will store the string at
    };

    // Write out the string as bytes at the address
    const encoder = new TextEncoder();
    let memory = new Uint8Array(result.instance.exports.memory.buffer);
    memory.set(encoder.encode(greetee.content), greetee.address);

    const greetingAddress = result.instance.exports.hello(greetee.address, greetee.length);

    memory = new Uint8Array(result.instance.exports.memory.buffer);

    // Find the zero terminator in our string to figure out the string's length
    const greetingLength = memory.indexOf(0, greetingAddress);

    const greetingBytes = memory.slice(greetingAddress, greetingLength);

    const decoder = new TextDecoder();
    const greetingString = decoder.decode(greetingBytes)

    console.log(greetingString);
});