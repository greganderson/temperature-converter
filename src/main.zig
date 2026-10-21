const std = @import("std");

const Conversion = enum {
    celsius_to_fahrenheit,
    fahrenheit_to_celsius,
};

pub fn main(init: std.process.Init) !void {
    var output_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &output_buffer);
    const stdout = &stdout_writer.interface;

    var input_buffer: [1024]u8 = undefined;
    var stdin_reader = std.Io.File.stdin().reader(init.io, &input_buffer);
    const stdin = &stdin_reader.interface;

    const choice = try getChoice(stdin, stdout);

    const degrees = try getFloat(stdin, stdout, "Degrees: ");

    switch (choice) {
        .celsius_to_fahrenheit => {
            const fahr = @round(celsiusToFahrenheit(degrees));
            try stdout.print("{d} C -> {d} F\n", .{ degrees, fahr });
        },
        .fahrenheit_to_celsius => {
            const cels = @round(fahrenheitToCelsius(degrees));
            try stdout.print("{d} F -> {d} C\n", .{ degrees, cels });
        },
    }

    try stdout.flush();
}

fn celsiusToFahrenheit(cels: f32) f32 {
    return (cels * 9 / 5) + 32;
}

fn fahrenheitToCelsius(fahr: f32) f32 {
    return (5 * (fahr - 32)) / 9;
}

fn getChoice(stdin: *std.Io.Reader, stdout: *std.Io.Writer) !Conversion {
    const prompt =
        \\What would you like to convert?
        \\1. Celsius to fahrenheit
        \\2. Fahrenheit to celsius
        \\Selection: 
    ;

    while (true) {
        const choice = try getInt(stdin, stdout, prompt);

        if (choice == 1) {
            return .celsius_to_fahrenheit;
        } else if (choice == 2) {
            return .fahrenheit_to_celsius;
        }

        try stdout.writeAll("Invalid choice.\n");
    }
}

fn getInput(stdin: *std.Io.Reader, stdout: *std.Io.Writer, prompt: []const u8) ![]const u8 {
    try stdout.writeAll(prompt);
    try stdout.flush();
    const line = try stdin.takeDelimiter('\n') orelse return error.EndOfStream;
    return std.mem.trim(u8, line, " \r\t");
}

fn getFloat(stdin: *std.Io.Reader, stdout: *std.Io.Writer, prompt: []const u8) !f32 {
    while (true) {
        const raw_value = try getInput(stdin, stdout, prompt);
        const value = std.fmt.parseFloat(f32, raw_value) catch {
            try stdout.writeAll("Invalid input.\n");
            continue;
        };

        if (!std.math.isFinite(value)) {
            try stdout.writeAll("Please enter a finite number.\n");
            continue;
        }

        return value;
    }
}

fn getInt(stdin: *std.Io.Reader, stdout: *std.Io.Writer, prompt: []const u8) !u8 {
    while (true) {
        const raw_value = try getInput(stdin, stdout, prompt);
        return std.fmt.parseInt(u8, raw_value, 10) catch {
            try stdout.writeAll("Invalid input.\n");
            continue;
        };
    }
}
